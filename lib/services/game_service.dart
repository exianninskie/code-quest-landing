import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chapter.dart';
import '../models/puzzle.dart';
import '../models/progress.dart';
import 'auth_service.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';

part 'game_service.g.dart';

@riverpod
GameService gameService(GameServiceRef ref) {
  return GameService(ref.watch(supabaseProvider));
}

@riverpod
Future<List<Chapter>> chapters(ChaptersRef ref) {
  return ref.watch(gameServiceProvider).fetchChapters();
}

@riverpod
Future<Chapter> chapterWithPuzzles(ChapterWithPuzzlesRef ref, String chapterId) {
  return ref.watch(gameServiceProvider).fetchChapter(chapterId);
}

@riverpod
Future<Puzzle> puzzle(PuzzleRef ref, String puzzleId) {
  return ref.watch(gameServiceProvider).fetchPuzzle(puzzleId);
}

@riverpod
Future<Chapter> chapterByPosition(ChapterByPositionRef ref, int position) {
  return ref.watch(gameServiceProvider).fetchChapterByPosition(position);
}

@riverpod
Future<Puzzle> puzzleByPosition(PuzzleByPositionRef ref, int chapterPosition, int puzzlePosition) {
  return ref.watch(gameServiceProvider).fetchPuzzleByPosition(chapterPosition, puzzlePosition);
}

@riverpod
Future<int> solvedPuzzleCount(SolvedPuzzleCountRef ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Future.value(0);
  return ref.watch(gameServiceProvider).fetchSolvedPuzzleCount(user.id);
}

@riverpod
Future<List<String>> unlockedChapterIds(UnlockedChapterIdsRef ref, String? userId) {
  final effectiveUserId = userId ?? ref.watch(currentUserProvider)?.id;
  if (effectiveUserId == null) return Future.value([]);
  return ref.watch(gameServiceProvider).fetchUnlockedChapterIds(effectiveUserId);
}

@riverpod
Future<Map<String, dynamic>> publicProfile(PublicProfileRef ref, String userId) {
  return ref.watch(gameServiceProvider).fetchPublicProfile(userId);
}

@riverpod
Future<Color> userAuraColor(UserAuraColorRef ref, String? userId) async {
  final ids = await ref.watch(unlockedChapterIdsProvider(userId).future);
  final allChapters = await ref.watch(chaptersProvider.future);

  final unlockedChapters = allChapters.where((c) => ids.contains(c.id)).toList();
  if (unlockedChapters.isEmpty) return Colors.white;

  unlockedChapters.sort((a, b) => b.position.compareTo(a.position));
  return AppTheme.conceptColor(unlockedChapters.first.concept);
}

@riverpod
Future<Map<String, int>> chapterXp(ChapterXpRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  
  // Use raw select to get nested chapter_id and xp_earned
  final data = await ref.read(supabaseProvider)
      .from('player_progress')
      .select('xp_earned, puzzles!inner(chapter_id)')
      .eq('user_id', user.id)
      .eq('completed', true);
  
  final Map<String, int> xpMap = {};
  for (var row in data as List) {
    final chapterId = row['puzzles']['chapter_id'] as String;
    final xp = row['xp_earned'] as int;
    xpMap[chapterId] = (xpMap[chapterId] ?? 0) + xp;
  }
  return xpMap;
}

@riverpod
Future<List<Map<String, dynamic>>> chapterLeaderboard(ChapterLeaderboardRef ref, String chapterId) {
  return ref.watch(gameServiceProvider).fetchChapterLeaderboard(chapterId);
}

@riverpod
Future<Set<String>> solvedPuzzleIds(SolvedPuzzleIdsRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Future.value({});
  final progress = await ref.watch(gameServiceProvider).fetchUserProgress(user.id);
  return progress.where((p) => p.completed).map((p) => p.puzzleId).toSet();
}

class GameService {
  final SupabaseClient _client;
  GameService(this._client);

  // ──────────────────────────────────────────
  // Chapters
  // ──────────────────────────────────────────

  // Fetch only chapters 1-4 ordered by their position
  Future<List<Chapter>> fetchChapters() async {
    try {
      final data = await _client
          .from('chapters')
          .select()
          .order('position', ascending: true);

      return (data as List).map((e) => Chapter.fromJson(e)).toList();
    } catch (e) {
      // Return empty list instead of crashing, or rethrow with context
      print('Error fetching chapters: $e');
      return [];
    }
  }

  // Fetch a single chapter with its puzzles
  Future<Chapter> fetchChapter(String chapterId) async {
    final data = await _client
        .from('chapters')
        .select('*, puzzles(*)')
        .eq('id', chapterId)
        .order('position', referencedTable: 'puzzles', ascending: true)
        .single();

    return Chapter.fromJson(data);
  }

  Future<Chapter> fetchChapterByPosition(int position) async {
    final data = await _client
        .from('chapters')
        .select('*, puzzles(*)')
        .eq('position', position)
        .order('position', referencedTable: 'puzzles', ascending: true)
        .single();

    return Chapter.fromJson(data);
  }

  // ──────────────────────────────────────────
  // Puzzles
  // ──────────────────────────────────────────

  Future<Puzzle> fetchPuzzle(String puzzleId) async {
    final data =
        await _client.from('puzzles').select().eq('id', puzzleId).single();

    return Puzzle.fromJson(data);
  }

  Future<Puzzle> fetchPuzzleByPosition(int chapterPosition, int puzzlePosition) async {
    // First find the chapter to get its ID
    final chapterData = await _client
        .from('chapters')
        .select('id')
        .eq('position', chapterPosition)
        .single();
    
    final chapterId = chapterData['id'] as String;

    // Then find the puzzle by position within that chapter
    final data = await _client
        .from('puzzles')
        .select()
        .eq('chapter_id', chapterId)
        .eq('position', puzzlePosition)
        .single();

    return Puzzle.fromJson(data);
  }

  // ──────────────────────────────────────────
  // Player progress
  // ──────────────────────────────────────────

  // Save (or update) progress when a puzzle is completed
  Future<void> savePuzzleProgress({
    required String userId,
    required String puzzleId,
    required int xpEarned,
    required bool isCorrect,
  }) async {
    // Check if the user already solved this puzzle
    final existingData = await _client
        .from('player_progress')
        .select('completed')
        .eq('user_id', userId)
        .eq('puzzle_id', puzzleId)
        .maybeSingle();

    final bool wasAlreadyCompleted = existingData != null && existingData['completed'] == true;

    // upsert means: insert if not exists, update if exists
    await _client.from('player_progress').upsert({
      'user_id': userId,
      'puzzle_id': puzzleId,
      'completed': isCorrect,
      'xp_earned': xpEarned,
      'completed_at': DateTime.now().toIso8601String(),
    });

    // Update the user's total XP: 
    // 1. If they got it right for the FIRST time (+ rewarding XP)
    // 2. If they got it wrong (penalty XP - usually negative)
    if ((isCorrect && !wasAlreadyCompleted) || !isCorrect) {
      await _client.rpc('increment_user_xp', params: {
        'user_id_param': userId,
        'xp_amount': xpEarned,
      });
    }

    // Always update last active timestamp when a puzzle is attempted
    await updateLastActive(userId);
  }

  // Manually update the last active timestamp
  Future<void> updateLastActive(String userId) async {
    try {
      await _client.rpc('update_user_last_active', params: {
        'user_id_param': userId,
      });
    } catch (e) {
      // Log error but don't crash the app for a heartbeat
      print('Heartbeat Error: $e');
    }
  }

  // Fetch all progress for the current user
  Future<List<Progress>> fetchUserProgress(String userId) async {
    final data = await _client
        .from('player_progress')
        .select('*, puzzles(chapter_id)')
        .eq('user_id', userId);

    return (data as List).map((e) => Progress.fromJson(e)).toList();
  }

  // Fetch true count of uniquely solved puzzles
  Future<int> fetchSolvedPuzzleCount(String userId) async {
    final data = await _client
        .from('player_progress')
        .select('id')
        .eq('user_id', userId)
        .eq('completed', true);
    return (data as List).length;
  }

  // Fetch unique chapters where the user has solved ALL puzzles
  Future<List<String>> fetchUnlockedChapterIds(String userId) async {
    // 1. Fetch all chapters and their puzzle counts
    final chaptersData = await _client
        .from('chapters')
        .select('id, puzzles(id)');
    
    // 2. Fetch user's completed puzzles
    final progressData = await _client
        .from('player_progress')
        .select('puzzles!inner(chapter_id)')
        .eq('user_id', userId)
        .eq('completed', true);

    final List<String> unlockedIds = [];

    // 3. Count completed puzzles per chapter
    final Map<String, int> completedCount = {};
    for (var row in progressData as List) {
      final chapterId = row['puzzles']['chapter_id'] as String;
      completedCount[chapterId] = (completedCount[chapterId] ?? 0) + 1;
    }

    // 4. Verify chapter completion
    for (var chapter in chaptersData as List) {
      final chapterId = chapter['id'] as String;
      final totalPuzzles = (chapter['puzzles'] as List).length;
      final solvedPuzzles = completedCount[chapterId] ?? 0;

      // Chapter is only unlocked if all puzzles are solved
      if (totalPuzzles > 0 && solvedPuzzles >= totalPuzzles) {
        unlockedIds.add(chapterId);
      }
    }

    return unlockedIds;
  }

  // Fetch a specific user's public profile info
  Future<Map<String, dynamic>> fetchPublicProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .single();
    return Map<String, dynamic>.from(data);
  }

  // Fetch the leaderboard (top 20 players)
  Future<List<Map<String, dynamic>>> fetchLeaderboard() async {
    final data = await _client
        .from('profiles')
        .select('username, total_xp, avatar_url')
        .order('total_xp', ascending: false)
        .limit(20);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> fetchChapterLeaderboard(String chapterId) async {
    final data = await _client.rpc('get_chapter_leaderboard', params: {
      'chapter_id_param': chapterId,
    });
    return List<Map<String, dynamic>>.from(data);
  }
}
