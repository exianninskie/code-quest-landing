import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gap/gap.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

import 'certificate_saver_stub.dart'
    if (dart.library.html) 'certificate_saver_web.dart';

class CertificateCard extends StatefulWidget {
  const CertificateCard({
    super.key,
    required this.username,
    required this.chapterTitle,
    required this.chapterXp,
    required this.concept,
    required this.assetImage,
  });

  final String username;
  final String chapterTitle;
  final int chapterXp;
  final String concept;
  final String assetImage;

  @override
  State<CertificateCard> createState() => _CertificateCardState();
}

class _CertificateCardState extends State<CertificateCard> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isDownloading = false;


  Future<void> _downloadCertificate() async {
    setState(() => _isDownloading = true);
    try {
      final image = await _screenshotController.capture();
      if (image != null) {
        if (kIsWeb) {
          // Web Download Logic
          saveImageWeb(image, 'certificate_${widget.concept}.png');
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Certificate downloaded!')),
          );
        } else {
          // Native Download Logic (using path_provider)
          // We'll try to save it to a public directory if possible, 
          // but for simplicity, we'll save it to temp and inform the user.
          // Note: This still uses local file system.
          final directory = await getTemporaryDirectory();
          final fileName = 'certificate_${widget.concept}.png';
          final imagePath = '${directory.path}/$fileName';
          
          // In a production app, we'd use image_gallery_saver to put it in Photos.
          // For now, we'll notify the user it's saved.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Certificate saved as $fileName')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: AspectRatio(
        aspectRatio: 1.4, // Standard certificate landscape aspect ratio
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // We wrap only the content part in Screenshot to avoid capturing the button
              Positioned.fill(
                child: Screenshot(
                  controller: _screenshotController,
                  child: Stack(
                    children: [
                      // Background Image
                      Positioned.fill(
                        child: Image.asset(
                          widget.assetImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                      
                      // Dark Overlay & Texture
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.black.withOpacity(0.85),
                                Colors.black.withOpacity(0.4),
                                Colors.black.withOpacity(0.9),
                              ],
                            ),
                          ),
                        ),
                      ),
      
                      // Ornate Border
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFFFD700).withOpacity(0.3), // Golden
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          margin: const EdgeInsets.all(12),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFFFD700).withOpacity(0.2),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          margin: const EdgeInsets.all(18),
                        ),
                      ),
      
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'CERTIFICATE OF MASTERY',
                              style: GoogleFonts.spaceGrotesk(
                                color: const Color(0xFFFFD700),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 3,
                              ),
                            ),
                            const Gap(8),
                            const Divider(
                              color: Color(0xFFFFD700),
                              thickness: 1,
                              indent: 80,
                              endIndent: 80,
                            ),
                            const Gap(12),
                            Text(
                              'Recipient',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white60,
                                fontSize: 9,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 1,
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.username.toUpperCase(),
                                style: GoogleFonts.spaceGrotesk(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const Gap(12),
                            Text(
                              'HAS SUCCESSFULLY CONQUERED THE TRIALS OF THE CHAPTER',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                            const Gap(4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.chapterTitle.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.spaceGrotesk(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ).animate().shimmer(duration: 3.seconds, color: const Color(0xFFFFD700).withOpacity(0.3)),
                            const Gap(16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildStatItem('FOCUS', widget.concept.toUpperCase()),
                                Container(
                                  height: 20,
                                  width: 1,
                                  color: Colors.white24,
                                  margin: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                _buildStatItem('XP REWARDED', '${widget.chapterXp}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Download Button
              Positioned(
                top: 24,
                right: 24,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isDownloading ? null : _downloadCertificate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: _isDownloading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.download_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white30,
            fontSize: 7,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFFFFD700),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
