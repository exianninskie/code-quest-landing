import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'About the Creator',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // Background Image (same as profile screen)
          Positioned.fill(
            child: Image.asset(
              'assets/images/nexus_void_bg.png',
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

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    children: [
                      // Avatar with Premium Frame
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer Glow & Decorative Frame
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const SweepGradient(
                                colors: [
                                  Color(0xFFFFD700), // Gold
                                  Color(0xFFB4A8FF), // Purple
                                  Color(0xFF534AB7), // Deep Purple
                                  Color(0xFFFFD700), // Gold
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFFFD700).withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(4), // Frame thickness
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ).animate(onPlay: (c) => c.repeat()).shimmer(
                              duration: 3.seconds,
                              color: Colors.white.withOpacity(0.1)),

                          // Main Avatar
                          ClipOval(
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/creator_avatar.jpg'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).animate().scale(
                          delay: 200.ms,
                          curve: Curves.easeOutBack,
                          duration: 600.ms),
                      const Gap(24),

                      // Name
                      Text(
                        'Ninskie',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Master Architect & Creator',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFFB4A8FF),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Gap(20),

                      // Bio text box
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Text(
                          isMobile
                              ? "Welcome to Code Quest!\n\nI built this adventure to make learning code immersive, challenging, and epic.\n\n"
                                  "Every chapter, puzzle, and concept you encounter here was forged to bridge the gap between dry tutorials and the actual magic of software development. "
                                  "Whether you're just starting out or honing your craft, I hope you enjoy the journey as much as I enjoyed crafting it!\n\n"
                                  "Feel free to connect with me, explore my other projects, or just say hi!"
                              : "Welcome to Code Quest!\n\nI built this adventure to make learning code immersive, challenging, and epic.\n\n"
                                  "Every chapter, puzzle, and concept you encounter here was forged to bridge the gap between dry tutorials and the actual magic of software development. "
                                  "Whether you're just starting out or honing your craft, I hope you enjoy the journey as much as\nI enjoyed crafting it!\n\n"
                                  "Feel free to connect with me, explore my other projects,\nor just say hi!",
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 15,
                            height: 1.6,
                            color: Colors.white.withOpacity(0.85),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const Gap(16),

                      // Social Links
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SocialButton(
                            icon: Icons.code,
                            label: 'GitHub',
                            url: 'https://github.com/exianninskie/code-quest-landing',
                            onTap: () =>
                                _launchUrl('https://github.com/exianninskie/code-quest-landing'),
                          ),
                          const Gap(16),
                          _SocialButton(
                            icon: Icons.forum_outlined,
                            label: 'Discord',
                            url: 'https://discord.gg/badd4mqp',
                            onTap: () =>
                                _launchUrl('https://discord.gg/badd4mqp'),
                          ),
                        ],
                      ),
                      const Gap(24),

                      // Donation Button
                      SizedBox(
                        width: 200,
                        child: OutlinedButton(
                          onPressed: () =>
                              _launchUrl('https://paypal.me/NinnaMargarethaW'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(
                                color: Color(0xFFFFD700), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor:
                                const Color(0xFFFFD700).withOpacity(0.05),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.local_fire_department_rounded,
                                  color: Color(0xFFFFD700), size: 18),
                              const Gap(8),
                              Text(
                                'BESTOW',
                                style: GoogleFonts.spaceGrotesk(
                                  color: const Color(0xFFFFD700),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(28),

                      // Legal Links
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _LegalLink(
                            label: 'Privacy Policy',
                            onTap: () =>
                                context.push('/home/profile/privacy-policy'),
                          ),
                          const Gap(12),
                          Text(
                            '•',
                            style: TextStyle(
                              color: const Color(0xFFFFD700).withOpacity(0.3),
                              fontSize: 12,
                            ),
                          ),
                          const Gap(12),
                          _LegalLink(
                            label: 'Terms of Service',
                            onTap: () =>
                                context.push('/home/profile/terms-of-service'),
                          ),
                        ],
                      ),
                      const Gap(12),


                      // Copyright Notice
                      Text(
                        '© 2026 Ninskie. All rights reserved.',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          color: const Color(0xFFFFD700).withOpacity(0.5),
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(24),
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

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.url,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF534AB7).withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF534AB7).withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const Gap(8),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _LegalLink({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            color: const Color(0xFFFFD700).withOpacity(0.7),
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: const Color(0xFFFFD700).withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}
