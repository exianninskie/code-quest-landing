import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/puzzle.dart';
import '../../services/auth_service.dart';
import '../../services/game_service.dart';
import '../../services/chat_service.dart';
import '../../widgets/xp_badge.dart';

class PuzzleScreen extends ConsumerStatefulWidget {
  const PuzzleScreen({super.key, required this.chapterId, required this.puzzleId});
  final String chapterId;
  final String puzzleId;

  @override
  ConsumerState<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends ConsumerState<PuzzleScreen> {
  String? _selectedAnswer;
  bool _hasAnswered = false;
  bool _isCorrect = false;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }



  void _selectAnswer(Puzzle puzzle, String answer, String username) {
    if (_hasAnswered) return;

    // Extreme safety: Strip everything except letters and numbers for the final check
    String clean(String s) => s.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase().trim();
    final isCorrect = clean(answer) == clean(puzzle.correctAnswer);

    if (isCorrect) {
      setState(() {
        _selectedAnswer = answer;
        _hasAnswered = true;
        _isCorrect = true;
      });

      // Save progress to Supabase
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(gameServiceProvider).savePuzzleProgress(
              userId: user.id,
              puzzleId: puzzle.id,
              xpEarned: puzzle.xpReward,
              isCorrect: true,
            ).then((_) {
              // Vital: Invalidate the providers so ChapterScreen and state refresh immediately!
              ref.invalidate(solvedPuzzleIdsProvider);
              ref.invalidate(chapterWithPuzzlesProvider(puzzle.chapterId));
              ref.invalidate(unlockedChapterIdsProvider(null));
            });
      }
    } else {
      // Wrong answer
      setState(() {
        _selectedAnswer = answer;
        _isCorrect = false;
      });

      // Chapter 5 (Grotto) has an XP penalty (-10)
      // Identifying via concept 'debugging' which is unique and safer than position
      final user = ref.read(currentUserProvider);
      if (user != null && puzzle.storyContext.contains('Grotto')) { 
        ref.read(gameServiceProvider).savePuzzleProgress(
              userId: user.id,
              puzzleId: puzzle.id,
              xpEarned: -10,
              isCorrect: false,
            );
      }
      
      final hint = puzzle.hint.isNotEmpty 
          ? puzzle.hint 
          : "The code spirits are silent... look closer at the logic!";
          
      _showFailureDialog(username, hint, answer, isChapter5: puzzle.storyContext.contains('Grotto'));
    }
  }

  void _showFailureDialog(String username, String hint, String actual, {bool isChapter5 = false}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Failure',
      barrierColor: Colors.black.withOpacity(0.85),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF131124),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFF534AB7).withOpacity(0.6),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF534AB7).withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⚔️', style: TextStyle(fontSize: 56))
                      .animate()
                      .shake(hz: 4, curve: Curves.easeInOut),
                  const Gap(20),
                  Text(
                    'Behold there, $username!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Gap(12),
                  Text(
                    isChapter5
                        ? "The code spirits reject this offering. You lose 10 XP for this error! Try again to restore balance."
                        : "The code spirits reject this offering. You gave '$actual', but here is a hint to guide you:\n\n'$hint'",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.6,
                    ),
                  ),
                  const Gap(32),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF534AB7),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),
        );
      },
    );
  }

  void _handleNext(Puzzle currentPuzzle) async {
    try {
      final chapter = await ref.read(chapterWithPuzzlesProvider(currentPuzzle.chapterId).future);
      final puzzles = chapter.puzzles;
      final currentIndex = puzzles.indexWhere((p) => p.id == currentPuzzle.id);
      
      if (currentIndex != -1 && currentIndex < puzzles.length - 1) {
        // Next puzzle in the same chapter
        // We use position (1-indexed) in the URL, puzzles are ordered by position already
        final nextPuzzle = puzzles[currentIndex + 1];
        context.go('/home/chapter/${chapter.position}/puzzle/${nextPuzzle.position}');
      } else {
        // Calculate total XP for the entire chapter
        final int totalXp = puzzles.fold(0, (sum, p) => sum + p.xpReward);
        
        // No more puzzles, push to the epic Chapter Complete screen
        context.go('/home/chapter/${chapter.position}/complete', extra: totalXp);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error finding the next path: $e')),
        );
      }
    }
  }

  void _showHint(Puzzle puzzle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          puzzle.hint.isNotEmpty 
            ? puzzle.hint 
            : "Look closely at the logic... adventure rewards the observant!",
          style: GoogleFonts.spaceGrotesk(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF534AB7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final chPos = int.tryParse(widget.chapterId);
    final puzPos = int.tryParse(widget.puzzleId);

    final puzzleAsync = (chPos != null && puzPos != null)
        ? ref.watch(puzzleByPositionProvider(chPos, puzPos))
        : ref.watch(puzzleProvider(widget.puzzleId));
    
    final solvedIdsAsync = ref.watch(solvedPuzzleIdsProvider);
    final cs = Theme.of(context).colorScheme;

    return puzzleAsync.when(
      data: (puzzle) {
        final isAlreadySolved = solvedIdsAsync.valueOrNull?.contains(puzzle.id) ?? false;
        
        // Broadcast current location (Chapter Number only) to Soul Link
        final chapterAsync = (chPos != null)
            ? ref.watch(chapterByPositionProvider(chPos))
            : ref.watch(chapterWithPuzzlesProvider(puzzle.chapterId));
            
        chapterAsync.whenData((chapter) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(chatServiceProvider).updateCurrentLocation('Chapter ${chapter.position}');
          });
        });

        if (isAlreadySolved && !_hasAnswered) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _hasAnswered = true;
                    _isCorrect = true;
                    _selectedAnswer = puzzle.correctAnswer;
                    if (puzzle.type == PuzzleType.fillInTheBlank) {
                      _controller.text = puzzle.correctAnswer;
                    }
                  });
                }
          });
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.pop(),
            ),
            title: const Text('Quest in Progress'),
            centerTitle: false,
            actions: [
              if (!puzzle.storyContext.contains('Grotto'))
                IconButton(
                  icon: const Icon(Icons.lightbulb_outline, color: Color(0xFFFFD700)),
                  tooltip: 'Ask for a hint',
                  onPressed: () => _showHint(puzzle),
                ),
              const Gap(8),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withOpacity(0.6),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt, size: 14, color: Color(0xFFFFD700)),
                      const Gap(4),
                      Text(
                        '+${puzzle.xpReward} XP',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          color: const Color(0xFFFFD700),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(12),
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: XpBadge(),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Story context (Adventurer's Journal Style) ──
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1D36),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF534AB7).withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF534AB7).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          size: 20,
                          color: Color(0xFFCECBF6),
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "QUEST LOG",
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF534AB7),
                                letterSpacing: 1.2,
                              ),
                            ),
                            const Gap(6),
                            Text(
                              puzzle.storyContext.isNotEmpty 
                                ? puzzle.storyContext 
                                : "The path ahead is shrouded in mystery. Decipher the code to proceed...",
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                height: 1.5,
                                color: Colors.white.withOpacity(0.85),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),

                const Gap(32),

                // ── Code snippet ──
                const Gap(12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1830),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    puzzle.question,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFCECBF6),
                      height: 1.5,
                    ),
                  ),
                ).animate().fadeIn(delay: 150.ms),

                const Gap(24),

                // ── Answer choices ──
                Text(
                  isAlreadySolved ? 'You have already solved this trial:' : 'Choose your answer:',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: cs.onSurface.withOpacity(0.5),
                      ),
                ),
                const Gap(10),
                if (puzzle.type == PuzzleType.fillInTheBlank) ...[
                  TextField(
                    controller: _controller,
                    enabled: !_hasAnswered && !isAlreadySolved,
                    style: GoogleFonts.jetBrainsMono(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type the missing fragment...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                      filled: true,
                      fillColor: cs.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: cs.outline.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: cs.outline.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF534AB7)),
                      ),
                    ),
                    onSubmitted: (val) => _selectAnswer(puzzle, val, user?.userMetadata?['username'] ?? 'Adventurer'),
                  ),
                  const Gap(16),
                  if (!_hasAnswered && !isAlreadySolved)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _selectAnswer(puzzle, _controller.text, user?.userMetadata?['username'] ?? 'Adventurer'),
                        child: const Text('Submit Fragment'),
                      ),
                    ),
                ] else
                  ...List.generate(puzzle.options.length, (i) {
                    final option = puzzle.options[i];
                    final isSelected = _selectedAnswer == option;
                    final showCorrect = _hasAnswered && option == puzzle.correctAnswer;

                    Color? borderColor;
                    Color? bgColor;
                    if (showCorrect) {
                      borderColor = const Color(0xFF1D9E75);
                      bgColor = const Color(0xFFE1F5EE).withOpacity(0.1);
                    } else if (isSelected && !_isCorrect) {
                      borderColor = Colors.red.withOpacity(0.5);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: (_hasAnswered || isAlreadySolved) 
                          ? null 
                          : () => _selectAnswer(puzzle, option, user?.userMetadata?['username'] ?? 'Adventurer'),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: bgColor ?? cs.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: borderColor ??
                                  (isSelected
                                      ? const Color(0xFF534AB7)
                                      : cs.outline.withOpacity(0.3)),
                              width: (isSelected || showCorrect) ? 1.5 : 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 13,
                                    color: showCorrect
                                        ? const Color(0xFF5DCAA5)
                                        : cs.onSurface,
                                  ),
                                ),
                              ),
                              if (showCorrect)
                                const Icon(Icons.check_circle, color: Color(0xFF5DCAA5), size: 18),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                // ── Feedback ──
                if (_hasAnswered && _isCorrect) ...[
                  const Gap(16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1F5EE).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF5DCAA5).withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_rounded, color: Color(0xFF5DCAA5), size: 16),
                            const Gap(8),
                            const Text(
                              'Resolved!',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5DCAA5),
                              ),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFF534AB7)),
                                const Gap(4),
                                Text(
                                  'Quest Complete',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF534AB7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Gap(6),
                        Text(
                          puzzle.explanation,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.15),
                  const Gap(16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _handleNext(puzzle),
                      child: const Text('Continue the quest →'),
                    ),
                  ),
                ],
                const Gap(32),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Error: $err')),
      ),
    );
  }
}
