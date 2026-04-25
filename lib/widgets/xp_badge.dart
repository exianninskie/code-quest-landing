import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../services/auth_service.dart';

class XpBadge extends ConsumerWidget {
  const XpBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileStream = ref.watch(userProfileStreamProvider);

    final profile = profileStream.valueOrNull;
    
    // Don't show anything if we don't have a profile yet and it's loading/error
    if (profile == null) {
      return const SizedBox.shrink();
    }

    final totalXp = profile['total_xp'] ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.stars_rounded,
            size: 16,
            color: Color(0xFFFFD700),
          ),
          const Gap(6),
          Text(
            '$totalXp XP',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFFFD700),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
