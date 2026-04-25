import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ChapterCompleteScreen extends StatelessWidget {
  const ChapterCompleteScreen({
    super.key,
    required this.chapterId,
    required this.xpEarned,
  });

  final String chapterId;
  final int xpEarned;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C20),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background ambient glows
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF534AB7).withOpacity(0.3),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF534AB7).withOpacity(0.5), blurRadius: 100),
                ],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
                duration: 3.seconds,
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
              ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1D9E75).withOpacity(0.2),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF1D9E75).withOpacity(0.4), blurRadius: 100),
                ],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
                duration: 4.seconds,
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.2, 1.2),
              ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Epic badge
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF534AB7), Color(0xFF1D9E75)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1D9E75).withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 10,
                        )
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.emoji_events_rounded, size: 70, color: Colors.white),
                    ),
                  )
                      .animate()
                      .scale(duration: 800.ms, curve: Curves.elasticOut)
                      .then()
                      .shimmer(duration: 1.seconds),

                  const Gap(32),

                  // Title Text
                  Text(
                    'CHAPTER COMPLETE!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .slideY(begin: 0.3, curve: Curves.easeOutBack),

                  const Gap(16),

                  // Subtitle
                  Text(
                    'You have mastered this realm of code and proven your worth to the Keeper.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 600.ms),

                  const Gap(48),

                  // XP Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'TOTAL XP EARNED',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFD700),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Gap(8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.bolt, color: Color(0xFFFFD700), size: 40)
                                .animate(onPlay: (controller) => controller.repeat())
                                .shimmer(duration: 2.seconds),
                            const Gap(8),
                            Text(
                              '+$xpEarned',
                              style: GoogleFonts.outfit(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            )
                                .animate()
                                .scale(delay: 1.seconds, duration: 600.ms, curve: Curves.elasticOut),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),

                  const Spacer(),

                  // Return Home Button
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF534AB7),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 60),
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Return to Map',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ).animate().fadeIn(delay: 1.5.seconds).moveY(begin: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
