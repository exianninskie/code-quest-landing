import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../models/chapter.dart';
import '../../services/auth_service.dart';
import '../../services/game_service.dart';
import '../../widgets/xp_badge.dart';
import '../../core/theme.dart';

class HomeWeb extends ConsumerWidget {
  const HomeWeb({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final chaptersAsync = ref.watch(chaptersProvider);
    final unlockedAsync = ref.watch(unlockedChapterIdsProvider(null));

    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Opacity(
            opacity: 0.4,
            child: Image.asset(
              'assets/images/bg_mystic.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: CustomScrollView(
                slivers: [
                  // ── App bar ──
                  SliverAppBar(
                    floating: true,
                    backgroundColor: Colors.transparent,
                    title: Row(
                      children: [
                        const Text(
                          '⚔️',
                          style: TextStyle(fontSize: 24),
                        ),
                        const Gap(12),
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                            children: const [
                              TextSpan(text: 'Code '),
                              TextSpan(
                                text: 'Quest',
                                style: TextStyle(color: Color(0xFFA855F7)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      const Center(
                        child: XpBadge(),
                      ),
                      const Gap(8),
                      IconButton(
                        icon: const Icon(Icons.person_outline,
                            color: Colors.white70),
                        onPressed: () => context.go('/home/profile'),
                      ),
                      const Gap(16),
                    ],
                  ),

                  // ── Hero greeting ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                                ),
                          ),
                          Text(
                            user?.userMetadata?['username'] ?? 'Adventurer',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium // Slightly larger for Web
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05),
                          const Gap(8),
                          Text(
                            'Conquer code, Forge legacy',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.5),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Chapters list ──
                  chaptersAsync.when(
                    data: (chapters) {
                      final unlockedIds = unlockedAsync.valueOrNull ?? [];

                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        sliver: SliverList.separated(
                          itemCount: chapters.length,
                          separatorBuilder: (_, __) => const Gap(16), // Larger gap for Web
                          itemBuilder: (context, index) {
                            final chapter = chapters[index];
                            final isUnlocked = index == 0 ||
                                chapter.isUnlockedByDefault ||
                                unlockedIds.contains(chapters[index - 1].id);

                            return _ChapterCardWeb(
                              chapter: chapter,
                              index: index,
                              isUnlocked: isUnlocked,
                            );
                          },
                        ),
                      );
                    },
                    loading: () => const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, stack) => SliverFillRemaining(
                      child: Center(
                          child: Text('Error loading chapters: $err')),
                    ),
                  ),

                  const SliverGap(48),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChapterCardWeb extends StatelessWidget {
  const _ChapterCardWeb(
      {required this.chapter, required this.index, required this.isUnlocked});
  final Chapter chapter;
  final int index;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.conceptColor(chapter.concept);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: isUnlocked ? () => context.go('/home/chapter/${chapter.position}') : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              // Concept badge circle
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isUnlocked
                        ? _conceptIcon(chapter.concept)
                        : Icons.lock_outline_rounded,
                    size: 28,
                    color: color,
                  ),
                ),
              ),
              const Gap(18),
              // Title + concept (Inline for Web)
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        chapter.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isUnlocked ? Colors.white : Colors.white70,
                              fontSize: 18,
                            ),
                          overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Gap(12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isUnlocked ? chapter.concept.toUpperCase() : 'Locked',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: color,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(20),
              Icon(
                isUnlocked ? Icons.arrow_forward_ios : Icons.lock,
                size: 16,
                color:
                    isUnlocked ? Colors.white.withOpacity(0.3) : Colors.white10,
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 80).ms).fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  IconData _conceptIcon(String concept) {
    return switch (concept) {
      'variables' => Icons.inventory_2_outlined,
      'conditionals' => Icons.alt_route_rounded,
      'loops' => Icons.sync_rounded,
      'debugging' => Icons.bug_report_rounded,
      'functions' => Icons.auto_fix_high_rounded,
      'arrays' => Icons.list_alt_rounded,
      _ => Icons.bolt_rounded,
    };
  }
}
