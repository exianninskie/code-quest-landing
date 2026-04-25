import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/game_service.dart';
import '../../services/chat_service.dart';
import '../../widgets/xp_badge.dart';
import '../../core/theme.dart';

class ChapterScreen extends ConsumerWidget {
  const ChapterScreen({super.key, required this.chapterId});
  final String chapterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pos = int.tryParse(chapterId);
    final chapterAsync = pos != null 
        ? ref.watch(chapterByPositionProvider(pos))
        : ref.watch(chapterWithPuzzlesProvider(chapterId));
    final solvedIdsAsync = ref.watch(solvedPuzzleIdsProvider);

    return chapterAsync.when(
      data: (chapter) {
        final color = AppTheme.conceptColor(chapter.concept);
        final solvedIds = solvedIdsAsync.valueOrNull ?? {};

        // Broadcast current location (Chapter Number only) to Soul Link
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(chatServiceProvider).updateCurrentLocation('Chapter ${chapter.position}');
        });

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // ── Hero App Bar with Image ──
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Chapter Image
                      Builder(builder: (context) {
                        String? localAsset;
                        if (chapter.concept == 'variables') {
                          localAsset = 'assets/images/chapter_library.png';
                        } else if (chapter.concept == 'strings') {
                          localAsset = 'assets/images/chapter_weaver_loom.png';
                        } else if (chapter.concept == 'loops') {
                          localAsset = 'assets/images/chapter_eternal_staircase.png';
                        } else if (chapter.concept == 'conditionals') {
                          localAsset = 'assets/images/chapter_forest.png';
                        } else if (chapter.concept == 'functions') {
                          localAsset = 'assets/images/chapter_spellbook.png';
                        }

                        if (chapter.imageUrl != null && chapter.imageUrl!.isNotEmpty) {
                          return Image.network(
                            chapter.imageUrl!,
                            fit: BoxFit.cover,
                          );
                        } else if (localAsset != null) {
                          return Image.asset(
                            localAsset,
                            fit: BoxFit.cover,
                          );
                        } else {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  color.withOpacity(0.8),
                                  color.withOpacity(0.4),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                _conceptIcon(chapter.concept),
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }
                      }),
                      // Overlay gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Theme.of(context).scaffoldBackgroundColor,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: XpBadge(),
                    ),
                  ),
                ],
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black26,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      // Story header
                      Text(
                        'Chapter ${chapter.position} - ${chapter.concept.toUpperCase()}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const Gap(8),
                      Text(
                        chapter.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ).animate().fadeIn(),
                      const Gap(16),
                      Text(
                        chapter.story,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.7,
                              color: Colors.white.withOpacity(0.8),
                            ),
                      ).animate().fadeIn(delay: 150.ms),

                      const Gap(32),
                      _ChapterLeaderboard(chapterId: chapter.id, themeColor: color),
                      const Gap(32),
                      
                      const Divider(color: Colors.white12),
                      const Gap(24),

                      Text(
                        'Puzzles',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                      ),
                      const Gap(16),

                      // Puzzle list
                      for (int i = 0; i < chapter.puzzles.length; i++) ...[
                        Builder(builder: (context) {
                          final puzzle = chapter.puzzles[i];
                          final isSolved = solvedIds.contains(puzzle.id);
                          
                          // A puzzle is unlocked if:
                          // 1. It is the first puzzle (i == 0)
                          // 2. OR the previous puzzle is solved
                          final isUnlocked = i == 0 || solvedIds.contains(chapter.puzzles[i - 1].id);
                          
                          // A puzzle is 'next' if it's unlocked but not yet solved
                          final isNext = isUnlocked && !isSolved;

                          return _buildPuzzleTile(
                            context,
                            puzzle,
                            chapter,
                            i,
                            color,
                            solvedIds,
                            isUnlocked,
                            isNext,
                          );
                        }),
                        const Gap(12),
                      ],
                      const Gap(40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildPuzzleTile(
    BuildContext context,
    dynamic puzzle,
    dynamic chapter,
    int index,
    Color color,
    Set<String> solvedIds,
    bool isUnlocked,
    bool isNext,
  ) {
    final isSolved = solvedIds.contains(puzzle.id);

    Widget tile = Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNext
            ? color.withOpacity(0.6)
            : (isSolved 
                ? const Color(0xFF1D9E75).withOpacity(0.5) 
                : isUnlocked ? color.withOpacity(0.2) : Colors.transparent),
          width: (isSolved || isNext) ? 2.0 : 1.0,
        ),
        boxShadow: isNext ? [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 2,
          )
        ] : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isSolved 
              ? const Color(0xFFE1F5EE) 
              : (isNext ? color.withOpacity(0.2) : color.withOpacity(0.1)),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isSolved
              ? const Icon(Icons.check_rounded, color: Color(0xFF1D9E75), size: 24)
              : Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: isNext ? Colors.white : color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ),
        ),
        title: Row(
          children: [
            Text(
              'Puzzle ${index + 1}',
              style: TextStyle(
                fontWeight: isUnlocked ? FontWeight.w600 : FontWeight.w400,
                color: isUnlocked ? Colors.white : Colors.white24,
              ),
            ),
            if (isNext) ...[
              const Gap(8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'NEXT',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          isSolved ? 'Victory Recorded' : (isNext ? 'Required Quest' : (isUnlocked ? 'Available' : 'Locked')),
          style: TextStyle(
            fontSize: 12,
            color: isSolved 
              ? const Color(0xFF1D9E75) 
              : (isNext ? color : Colors.white30),
          ),
        ),
        trailing: Icon(
          isUnlocked ? Icons.arrow_forward_ios : Icons.lock_outline_rounded,
          size: 14,
          color: isUnlocked ? Colors.white30 : Colors.white10,
        ),
        onTap: isUnlocked 
          ? () => context.go('/home/chapter/${chapter.position}/puzzle/${index + 1}') 
          : null,
      ),
    );

    if (isNext) {
      tile = tile.animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 2.seconds, color: Colors.white10);
    }

    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.4,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: tile,
      ).animate(delay: (index * 60).ms).fadeIn().slideX(begin: 0.1),
    );
  }

  IconData _conceptIcon(String concept) {
    return switch (concept) {
      'variables' => Icons.inventory_2_outlined,
      'conditionals' => Icons.alt_route_rounded,
      'loops' => Icons.sync_rounded,
      'functions' => Icons.auto_fix_high_rounded,
      'arrays' => Icons.list_alt_rounded,
      'strings' => Icons.gesture_rounded,
      _ => Icons.bolt_rounded,
    };
  }
}

class _ChapterLeaderboard extends ConsumerWidget {
  const _ChapterLeaderboard({required this.chapterId, required this.themeColor});
  final String chapterId;
  final Color themeColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(chapterLeaderboardProvider(chapterId));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: themeColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: themeColor, size: 24),
              const Gap(10),
              Text(
                'Hall of Legends',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Gap(20),
          leaderboardAsync.when(
            data: (players) {
              if (players.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Be the first to claim a spot!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: List.generate(players.length, (index) {
                  final player = players[index];
                  final name = player['username'] ?? 'Anonymous';
                  final xp = player['total_chapter_xp'] ?? 0;
                  final avatar = player['avatar_url'];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        // Rank
                        SizedBox(
                          width: 28,
                          child: Text(
                            switch (index) {
                              0 => '🥇',
                              1 => '🥈',
                              2 => '🥉',
                              _ => '',
                            },
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const Gap(8),
                        // Avatar
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: themeColor.withOpacity(0.1),
                          backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                          child: avatar == null
                              ? Text(
                                  name[0].toUpperCase(),
                                  style: TextStyle(fontSize: 10, color: themeColor),
                                )
                              : null,
                        ),
                        const Gap(12),
                        // Name
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // XP earned in chapter
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$xp XP',
                            style: TextStyle(
                              color: themeColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.05);
                }),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (e, _) => Text('Failed to load legends'),
          ),
        ],
      ),
    );
  }
}
