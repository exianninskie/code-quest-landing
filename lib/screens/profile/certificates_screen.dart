import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/game_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/certificate_card.dart';

class CertificatesScreen extends ConsumerWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chaptersProvider);
    final unlockedIdsAsync = ref.watch(unlockedChapterIdsProvider(null));
    final chapterXpAsync = ref.watch(chapterXpProvider);
    final user = ref.watch(currentUserProvider);
    final username = user?.userMetadata?['username'] ?? 'Adventurer';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Hall of Certifications',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: chaptersAsync.when(
        data: (chapters) {
          return unlockedIdsAsync.when(
            data: (unlockedIds) {
              final completedChapters = chapters.where((c) => unlockedIds.contains(c.id)).toList();

              if (completedChapters.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_person_rounded, size: 64, color: Colors.white24),
                      const SizedBox(height: 16),
                      Text(
                        'No Certifications Yet',
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Complete all puzzles in a chapter to earn your legendary certificate.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white38),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return chapterXpAsync.when(
                data: (xpMap) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: completedChapters.length,
                        itemBuilder: (context, index) {
                          final chapter = completedChapters[index];
                          final xp = xpMap[chapter.id] ?? 0;
                          
                          String assetImage = 'assets/images/chapter_library.png';
                          if (chapter.concept == 'strings') {
                            assetImage = 'assets/images/chapter_weaver_loom.png';
                          } else if (chapter.concept == 'loops') {
                            assetImage = 'assets/images/chapter_eternal_staircase.png';
                          } else if (chapter.concept == 'conditionals') {
                            assetImage = 'assets/images/chapter_forest.png';
                          } else if (chapter.concept == 'functions') {
                            assetImage = 'assets/images/chapter_spellbook.png';
                          }
    
                          return CertificateCard(
                            username: username,
                            chapterTitle: chapter.title,
                            chapterXp: xp,
                            concept: chapter.concept,
                            assetImage: assetImage,
                          );
                        },
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error loading XP: $e')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error loading progress')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading chapters')),
      ),
    );
  }
}
