import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../services/auth_service.dart';
import '../../services/game_service.dart';
import '../../core/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Trigger "heartbeat" to update last active timestamp
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(gameServiceProvider).updateLastActive(user.id);
      }
    });
  }

  String _formatLastActive(String? lastActiveAt) {
    if (lastActiveAt == null) return 'Joining the adventure...';
    try {
      final date = DateTime.parse(lastActiveAt).toLocal();
      final now = DateTime.now();
      final diff = now.difference(date);

      // Status window: 150s (2.5 min) to account for heartbeat frequency and clock drift
      if (diff.inSeconds < 150) return 'Online';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Recently active';
    }
  }

  Future<void> _handleUploadAvatar() async {
    setState(() => _isUploading = true);
    try {
      await ref.read(authServiceProvider).uploadAvatar();
      ref.invalidate(userProfileStreamProvider); // Force Riverpod to fetch the new URL
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final username = user?.userMetadata?['username'] ?? 'Adventurer';

    // Reactive stats from Supabase - using valueOrNull to persist data during loading
    final profileAsync = ref.watch(userProfileStreamProvider);
    final profile = profileAsync.valueOrNull;
    
    final totalXp = profile?['total_xp']?.toString() ?? '0';

    final puzzlesAsync = ref.watch(solvedPuzzleCountProvider);
    final puzzlesSolved = puzzlesAsync.valueOrNull?.toString() ?? '0';

    final chaptersAsync = ref.watch(chaptersProvider);
    final chaptersList = chaptersAsync.valueOrNull ?? [];
    
    final unlockedAsync = ref.watch(unlockedChapterIdsProvider(null));
    final unlockedIds = unlockedAsync.valueOrNull ?? [];
    
    // Status calculation
    final lastActiveAt = profile?['last_active_at'];
    final lastActiveStr = _formatLastActive(lastActiveAt);

    final auraAsync = ref.watch(userAuraColorProvider(null));
    final auraColor = auraAsync.valueOrNull ?? Colors.white;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => ref.read(authServiceProvider).signOut(),
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/profile_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          // Dark Overlay & Blur
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
            // Avatar with Premium Frame
            GestureDetector(
              onTap: _isUploading ? null : _handleUploadAvatar,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Glow & Decorative Frame
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          const Color(0xFFFFD700), // Gold
                          auraColor,
                          auraColor.withOpacity(0.5),
                          const Color(0xFFFFD700), // Gold
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(2.5), // Unified frame thickness
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 3.seconds, color: Colors.white.withOpacity(0.1)).boxShadow(
                        begin: BoxShadow(color: auraColor.withOpacity(0.2), blurRadius: 8, spreadRadius: 0),
                        end: BoxShadow(color: auraColor.withOpacity(0.6), blurRadius: 16, spreadRadius: 2),
                        duration: 2.seconds,
                        curve: Curves.easeInOut,
                      ),
                  
                  // Main Avatar
                  ClipOval(
                    child: SizedBox(
                      width: 85,
                      height: 85,
                      child: profileAsync.value?['avatar_url'] != null
                          ? CachedNetworkImage(
                              imageUrl: profileAsync.value!['avatar_url'],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: const Color(0xFF534AB7).withOpacity(0.1),
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.red.withOpacity(0.1),
                                child: const Icon(Icons.error_outline, color: Colors.red),
                              ),
                            )
                          : Container(
                              color: auraColor.withOpacity(0.15),
                              child: Center(
                                child: Text(
                                  username.isNotEmpty ? username[0].toUpperCase() : '?',
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: auraColor,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                  if (_isUploading)
                    Container(
                      width: 85,
                      height: 85,
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  // Camera Icon
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack, duration: 600.ms),
            const Gap(8),
            Text(
              username,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
            ),
            Text(
              user?.email ?? '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.4),
                  ),
            ),
            const Gap(4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const Gap(6),
                Text(
                  lastActiveStr,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.greenAccent.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                ),
              ],
            ).animate().fadeIn(delay: 400.ms),
            const Gap(4),
            // Button Chaser Badge
            _ButtonChaserBadge(
              isUnlocked: profile?['button_chaser_unlocked'] == true,
            ),
            const Gap(20),

            // Stats row
            Row(
              children: [
                _StatCard(label: 'Total XP', value: totalXp, icon: Icons.bolt),
                const Gap(8),
                _StatCard(
                    label: 'Solved',
                    value: puzzlesSolved,
                    icon: Icons.check_circle_outline),
                const Gap(8),
                _StatCard(
                    label: 'Chapters',
                    value: '${unlockedIds.length}/${chaptersList.length}',
                    icon: Icons.menu_book_outlined),
              ],
            ).animate().fadeIn().slideY(begin: 0.1),

            const Gap(20),

            // Badges Section
            Align(
              alignment: Alignment.center,
              child: Text(
                'CHAPTER BADGES',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            const Gap(5),
            
            chaptersAsync.when(
              data: (_) {
                final isLarge = MediaQuery.of(context).size.width > 700;
                
                if (isLarge) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: chaptersList.asMap().entries.map((entry) {
                        final index = entry.key;
                        final chapter = entry.value;
                        final isUnlocked = unlockedIds.contains(chapter.id);
                        return Expanded(
                          child: _ChapterBadge(
                            chapterName: chapter.title,
                            concept: chapter.concept,
                            isUnlocked: isUnlocked,
                            index: index,
                            isLarge: true,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }

                return SizedBox(
                  height: 100, // Existing height for mobile
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: chaptersList.asMap().entries.map((entry) {
                        final index = entry.key;
                        final chapter = entry.value;
                        final isUnlocked = unlockedIds.contains(chapter.id);
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: SizedBox(
                            width: 66,
                            child: _ChapterBadge(
                              chapterName: chapter.title,
                              concept: chapter.concept,
                              isUnlocked: isUnlocked,
                              index: index,
                              isLarge: false,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Center(child: Text('Error loading badges: $e')),
            ),
            const Gap(15),
            
            // Certificate Button
            Center(
              child: SizedBox(
                width: 280, // Shorter width as requested
                child: OutlinedButton(
                  onPressed: () => context.go('/home/profile/certificate'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10), // Reduced from 20
                    side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: const Color(0xFFFFD700).withOpacity(0.05),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD700), size: 20), // Reduced from 28
                      const Gap(8), // Reduced from 12
                      Text(
                        'GET YOUR CERTIFICATE HERE',
                        style: GoogleFonts.spaceGrotesk(
                          color: const Color(0xFFFFD700),
                          fontWeight: FontWeight.w900,
                          fontSize: 11, // Reduced from 14 to match badge names
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ).animate(onPlay: (c) => c.repeat()).shimmer(
                  duration: 2.seconds,
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                ),
              ),
            ),
            const Gap(16),
            
            // The Whispers Button
            Center(
              child: SizedBox(
                width: 280,
                child: TextButton(
                  onPressed: () => context.go('/home/profile/soul-link'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: const Color(0xFFB4A8FF).withOpacity(0.3), width: 1),
                    ),
                    backgroundColor: const Color(0xFFB4A8FF).withOpacity(0.05),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: Color(0xFFB4A8FF), size: 18),
                      const Gap(8),
                      Text(
                        'SOUL LINK',
                        style: GoogleFonts.spaceGrotesk(
                          color: const Color(0xFFB4A8FF),
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat()).shimmer(
                delay: 1.seconds,
                duration: 3.seconds,
                color: const Color(0xFFB4A8FF).withOpacity(0.2),
              ),
            ),
            const Gap(16),
            
            // About the Creator Button
            Center(
              child: SizedBox(
                width: 280,
                child: TextButton(
                  onPressed: () => context.push('/about'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Colors.white60, size: 16),
                      const Gap(8),
                      Text(
                        'ABOUT THE CREATOR',
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white60,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Gap(15),
            Center(
              child: Text(
                '© 2026 Ninskie. All rights reserved.',
                style: TextStyle(
                  fontSize: 10,
                  color: const Color(0xFFFFD700).withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            const Gap(10),
          ],
        ),
      ),
    ),
  ),
),
],
),
);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: const Color(0xFFB4A8FF)),
            const Gap(4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChapterBadge extends StatelessWidget {
  const _ChapterBadge({
    required this.chapterName,
    required this.concept,
    required this.isUnlocked,
    required this.index,
    this.isLarge = false,
  });

  final String chapterName;
  final String concept;
  final bool isUnlocked;
  final int index;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final conceptColor = AppTheme.conceptColor(concept);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isLarge ? 110 : 48, 
            maxHeight: isLarge ? 110 : 48,
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isUnlocked
                ? Colors.black.withOpacity(0.8)
                : Colors.black.withOpacity(0.5),
            border: Border.all(
              color: isUnlocked
                  ? conceptColor.withOpacity(0.8)
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              width: isUnlocked ? (isLarge ? 4.0 : 2.5) : 1,
            ),
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: conceptColor.withOpacity(0.4),
                      blurRadius: isLarge ? 25 : 15,
                      spreadRadius: isLarge ? 4 : 2,
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Icon(
              isUnlocked ? Icons.stars_rounded : Icons.lock_outline_rounded,
              size: isLarge ? 50 : 30,
              color: isUnlocked
                  ? conceptColor
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            ),
          ),
        ),
      ),
    ).animate(delay: (index * 100).ms).scale(
      begin: const Offset(0.5, 0.5), 
      duration: 400.ms, 
      curve: Curves.easeOutBack
    ).fadeIn(),
        
        const Gap(6),
        Text(
          chapterName.contains(' ') 
            ? '${chapterName.substring(0, chapterName.lastIndexOf(' '))}\n${chapterName.substring(chapterName.lastIndexOf(' ') + 1)}'
            : chapterName,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: isLarge ? 13 : 10,
            height: 1.2,
            fontWeight: isUnlocked ? FontWeight.w900 : FontWeight.w400,
            color: isUnlocked
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
        ).animate(delay: (index * 100).ms).fadeIn(),
      ],
    );
  }
}

class _ButtonChaserBadge extends StatelessWidget {
  const _ButtonChaserBadge({required this.isUnlocked});
  final bool isUnlocked;

  void _showBadgeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isUnlocked
                ? const Color(0xFFFFD700).withOpacity(0.6)
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        title: Row(
          children: [
            Icon(
              isUnlocked ? Icons.emoji_events_rounded : Icons.lock_outline_rounded,
              color: isUnlocked ? const Color(0xFFFFD700) : Colors.white30,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isUnlocked ? 'Button Chaser' : 'Locked Badge',
                style: GoogleFonts.spaceGrotesk(
                  color: isUnlocked ? const Color(0xFFFFD700) : Colors.white30,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          isUnlocked
              ? '"If you can catch a button, you can definitely handle what\'s waiting for you inside."\n\n— Earned by catching the elusive Start Adventure button.'
              : 'This badge is a mystery... Only those who begin their journey in a special way will uncover its secret.',
          style: GoogleFonts.spaceGrotesk(
            color: isUnlocked ? Colors.white70 : Colors.white24,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isUnlocked ? 'NICE!' : 'HMMMM...',
              style: GoogleFonts.spaceGrotesk(
                color: isUnlocked ? const Color(0xFFFFD700) : Colors.white30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBadgeDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isUnlocked
              ? const Color(0xFFFFD700).withOpacity(0.08)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnlocked
                ? const Color(0xFFFFD700).withOpacity(0.5)
                : Colors.white.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.15),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isUnlocked
                  ? Icons.emoji_events_rounded
                  : Icons.lock_outline_rounded,
              size: 14,
              color: isUnlocked
                  ? const Color(0xFFFFD700)
                  : Colors.white.withOpacity(0.15),
            ),
            const SizedBox(width: 6),
            Text(
              isUnlocked ? 'BUTTON CHASER' : '? ? ?',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: isUnlocked
                    ? const Color(0xFFFFD700)
                    : Colors.white.withOpacity(0.15),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).scale(
      begin: const Offset(0.8, 0.8),
      duration: 400.ms,
      curve: Curves.easeOutBack,
    );
  }
}
