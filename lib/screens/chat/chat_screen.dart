import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';
import '../../services/game_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  void initState() {
    super.initState();
    // Immediately mark user as active when entering Soul Link
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(gameServiceProvider).updateLastActive(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider);
    final onlineUsersAsync = ref.watch(onlineUsersProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Soul Link', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white24),
            onPressed: () => _showClearConfirmation(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Chapter-themed Background (Mystic)
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/images/soul_link_lore.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Stack(
              children: [
                // AREA 2: SOUL LINK FEED (Forced Position - Upper Middle)
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.05, // Pull up to accommodate avatars
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Online users right above the chat box
                            SizedBox(
                              width: double.infinity,
                              child: _OnlineUsersSection(
                                  onlineUsersAsync: onlineUsersAsync),
                            ),
                            const Gap(16),
                            Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.33,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: messagesAsync.when(
                                data: (messages) {
                                  if (messages.isEmpty) {
                                    return Center(
                                      child: Text(
                                        'SILENCE...',
                                        style: GoogleFonts.spaceGrotesk(
                                          color: Colors.white10,
                                          letterSpacing: 2,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }
                                  return ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: messages.length,
                                    itemBuilder: (context, index) {
                                      final msg = messages[index];
                                      final isMe = msg['user_id'] == currentUser?.id;
                                      return _SleekMessageTile(
                                          message: msg, isMe: isMe);
                                    },
                                  );
                                },
                                loading: () => const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white10)),
                                error: (e, _) => const SizedBox(),
                              ),
                            ),
                            const Gap(12),
                            // Compact Template Section right below the chat box
                            SizedBox(
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  for (final template in [
                                    'Hey!',
                                    'GG!',
                                    'Thanks!',
                                    'See you!',
                                    'GLHF!',
                                    'Almost\nthere'
                                  ])
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 2),
                                        child: InkWell(
                                          onTap: () => ref
                                              .read(chatServiceProvider)
                                              .sendMessage(template),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            height: 48,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.1)),
                                            ),
                                            child: Center(
                                              child: Text(
                                                template,
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                style: GoogleFonts.spaceGrotesk(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.1),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ).animate().fadeIn(delay: 200.ms),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'PURGE CHAT?',
          style: GoogleFonts.cinzel(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will permanently delete all whispers from the Soul Link. Are you sure?',
          style: GoogleFonts.spaceGrotesk(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              ref.read(chatServiceProvider).deleteAllMessages();
              Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Chat purged.', style: GoogleFonts.spaceGrotesk()),
                    backgroundColor: Colors.redAccent.withOpacity(0.8),
                  ),
                );
              }
            },
            child: const Text('PURGE',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPublicProfile(BuildContext context, WidgetRef ref, String userId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PublicProfileModal(userId: userId),
    );
  }
}

class _OnlineUsersSection extends ConsumerWidget {
  final AsyncValue<List<Map<String, dynamic>>> onlineUsersAsync;

  const _OnlineUsersSection({
    required this.onlineUsersAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 105,
      child: onlineUsersAsync.when(
        data: (users) {
          if (users.isEmpty) return const SizedBox();
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return GestureDetector(
                onTap: () => (context.findAncestorStateOfType<_ChatScreenState>() as _ChatScreenState)._showPublicProfile(context, ref, user['id']),
                child: _SleekUserBadge(user: user),
              );
            },
          );
        },
        loading: () => const SizedBox(),
        error: (_, __) => const SizedBox(),
      ),
    );
  }
}

class _SleekUserBadge extends ConsumerWidget {
  final Map<String, dynamic> user;
  const _SleekUserBadge({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auraAsync = ref.watch(userAuraColorProvider(user['id']));
    final auraColor = auraAsync.valueOrNull ?? Colors.white;
    final avatar = user['avatar_url'];
    final username = user['username'] ?? 'User';

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: auraColor.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 1.5,
                ),
              ],
              border: Border.all(
                  color: auraColor,
                  width: 2.0),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF1A1A24),
              backgroundImage:
                  avatar != null ? CachedNetworkImageProvider(avatar) : null,
              child: avatar == null
                  ? Text(username[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white70))
                  : null,
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 2.seconds, color: Colors.white24),
          const Gap(4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const Gap(3),
              Text(
                'Online',
                style: GoogleFonts.spaceGrotesk(
                    color: Colors.greenAccent.withOpacity(0.8),
                    fontSize: 8,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Gap(2),
          Text(
            username.toLowerCase(),
            style: GoogleFonts.spaceGrotesk(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.w500),
          ),
        ],
      ).animate().fadeIn().scale(delay: 100.ms),
    );
  }
}

class _SleekMessageTile extends ConsumerWidget {
  final Map<String, dynamic> message;
  final bool isMe;

  const _SleekMessageTile({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = message['profiles'] ?? {};
    final avatar = profile['avatar_url'];
    final username = profile['username'] ?? 'User';
    final xp = profile['total_xp'] ?? 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => (context.findAncestorStateOfType<_ChatScreenState>() as _ChatScreenState)._showPublicProfile(context, ref, message['user_id']),
            child: _SmallAvatar(url: avatar, name: username, userId: message['user_id']),
          ),
          const Gap(12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                username,
                style: GoogleFonts.spaceGrotesk(
                  color: isMe ? const Color(0xFFB4A8FF) : Colors.white70,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const Gap(6),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white54, width: 0.8),
                ),
              ),
              const Gap(6),
              Text(
                '$xp XP',
                style: GoogleFonts.spaceGrotesk(
                  color: const Color(0xFFFFD700),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Gap(8),
          GestureDetector(
            onLongPress: isMe ? () => _showDeleteDialog(context, ref) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isMe
                    ? const Color(0xFF4A90E2).withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isMe
                      ? const Color(0xFF4A90E2).withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Text(
                message['content'],
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.3,
                ),
              ),
            ),
          ).animate().fadeIn().moveX(begin: -5),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('REMOVE SOUL LINK',
            style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        content: Text('This message will be permanently deleted.',
            style: GoogleFonts.inter(color: Colors.white54)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL',
                  style: TextStyle(color: Colors.white24))),
          TextButton(
            onPressed: () {
              ref.read(chatServiceProvider).deleteMessage(message['id']);
              Navigator.pop(context);
            },
            child: const Text('DELETE',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SmallAvatar extends ConsumerWidget {
  final String? url;
  final String name;
  final String userId;

  const _SmallAvatar({this.url, required this.name, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auraAsync = ref.watch(userAuraColorProvider(userId));
    final auraColor = auraAsync.valueOrNull ?? Colors.white10;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: auraColor.withOpacity(0.5), width: 1.5),
      ),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: const Color(0xFF1A1A24),
        backgroundImage: url != null ? CachedNetworkImageProvider(url!) : null,
        child: url == null
            ? Text(name[0].toUpperCase(),
                style: const TextStyle(fontSize: 10, color: Colors.white24))
            : null,
      ),
    );
  }
}

class _PublicProfileModal extends ConsumerWidget {
  final String userId;
  const _PublicProfileModal({required this.userId});

  Future<void> _launchDiscord() async {
    const url = 'https://discord.gg/badd4mqp';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(publicProfileProvider(userId));
    final unlockedAsync = ref.watch(unlockedChapterIdsProvider(userId));
    final chaptersAsync = ref.watch(chaptersProvider);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0C20),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: const Color(0xFFB4A8FF).withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: profileAsync.when(
        data: (profile) {
          final username = profile['username'] ?? 'Adventurer';
          final xp = profile['total_xp'] ?? 0;
          final avatar = profile['avatar_url'];
          final isButtonChaser = profile['button_chaser_unlocked'] == true;

          final auraAsync = ref.watch(userAuraColorProvider(userId));
          final auraColor = auraAsync.valueOrNull ?? Colors.white;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(24),
              
              // Avatar with Hero Aura (Pulse)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: auraColor, width: 2.0),
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: const Color(0xFF1A1A24),
                  backgroundImage: avatar != null ? CachedNetworkImageProvider(avatar) : null,
                  child: avatar == null
                      ? Text(username[0].toUpperCase(), style: const TextStyle(fontSize: 32, color: Colors.white))
                      : null,
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).boxShadow(
                begin: BoxShadow(color: auraColor.withOpacity(0.2), blurRadius: 8, spreadRadius: 0),
                end: BoxShadow(color: auraColor.withOpacity(0.6), blurRadius: 16, spreadRadius: 2),
                duration: 2.seconds,
                curve: Curves.easeInOut,
              ),
              
              const Gap(16),
              Text(
                username,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
              const Gap(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt_rounded, color: Color(0xFFFFD700), size: 18),
                  const Gap(4),
                  Text(
                    '$xp XP COLLECTED',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFFD700),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              
              const Gap(24),
              const Divider(color: Colors.white12),
              const Gap(24),
              
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'BADGES EARNED',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white38,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const Gap(16),
              
              // Badges Grid
              unlockedAsync.when(
                data: (ids) {
                  return chaptersAsync.when(
                    data: (allChapters) {
                      final unlockedChapters = allChapters.where((c) => ids.contains(c.id)).toList();
                      
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          // Button Chaser Badge
                          if (isButtonChaser)
                            _PublicBadge(
                              icon: Icons.emoji_events_rounded,
                              color: const Color(0xFFFFD700),
                              label: 'BUTTON CHASER',
                            ),
                          
                          // Latest Chapter Badge
                          if (unlockedChapters.isNotEmpty) ...[
                            Builder(builder: (context) {
                              // Sort by position DESC to get the latest
                              unlockedChapters.sort((a, b) => b.position.compareTo(a.position));
                              final latest = unlockedChapters.first;
                              final conceptColor = AppTheme.conceptColor(latest.concept);
                              
                              return _PublicBadge(
                                icon: Icons.stars_rounded,
                                color: conceptColor,
                                label: '${latest.title.toUpperCase()} MASTER',
                              );
                            }),
                          ],
                            
                          if (!isButtonChaser && ids.isEmpty)
                            Text(
                              'Journeying towards the first legend...',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.white24,
                              ),
                            ),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    error: (_, __) => const SizedBox(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                error: (_, __) => const SizedBox(),
              ),
              
              const Gap(40),
              
              // Discord Bridge
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _launchDiscord,
                  icon: const Icon(Icons.forum_rounded),
                  label: const Text('CONNECT ON DISCORD'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5865F2), // Discord Blue
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
        error: (e, _) => Center(child: Text('Error finding adventurer: $e')),
      ),
    );
  }
}

class _PublicBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _PublicBadge({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const Gap(6),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
