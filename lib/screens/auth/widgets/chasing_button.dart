import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChasingButton extends StatefulWidget {
  final VoidCallback onPressed;
  final VoidCallback? onBadgeEarned;
  final Widget child;
  final bool enabled;

  const ChasingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.onBadgeEarned,
    this.enabled = true,
  });

  @override
  State<ChasingButton> createState() => _ChasingButtonState();
}

class _ChasingButtonState extends State<ChasingButton> {
  bool _isChasing = false;
  bool _hasUnlocked = false;
  Timer? _timer;
  DateTime? _chaseStartTime;
  
  // For the "Ghost" button in the overlay
  OverlayEntry? _overlayEntry;
  final GlobalKey _buttonKey = GlobalKey();
  
  // Position for the jumping button
  double _top = 0;
  double _left = 0;
  double _width = 0;
  double _height = 0;

  bool _chaseCompleted = false;

  void _startChase() {
    if (!widget.enabled || _hasUnlocked || _isChasing || _chaseCompleted) return;

    final RenderBox? renderBox = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _chaseStartTime = DateTime.now();
    
    setState(() {
      _isChasing = true;
      _top = position.dy;
      _left = position.dx;
      _width = size.width;
      _height = size.height;
    });

    _showOverlay();

    // End the chase after 15 seconds
    _timer = Timer(const Duration(seconds: 15), () {
      _stopChase();
    });
    
    // Initial jump!
    _jump();
  }

  void _showOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => StatefulBuilder(
        builder: (context, setOverlayState) {
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 150),
                curve: Curves.fastOutSlowIn,
                top: _top,
                left: _left,
                width: _width,
                height: _height,
                child: Material(
                  color: Colors.transparent,
                  child: MouseRegion(
                    onEnter: (_) {
                      _jump();
                      setOverlayState(() {});
                    },
                    child: GestureDetector(
                      onTapDown: (_) {
                        _jump();
                        setOverlayState(() {});
                      },
                      child: ElevatedButton(
                        onPressed: () {
                          // Mandatory miss during the 10s
                          _jump();
                          setOverlayState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _jump() {
    final size = MediaQuery.of(context).size;
    final random = Random();
    
    // Calculate a random position that keeps the button on screen
    _top = random.nextDouble() * (size.height - _height - 100) + 50;
    _left = random.nextDouble() * (size.width - _width - 100) + 50;
    
    // Update the overlay if it exists
    _overlayEntry?.markNeedsBuild();
  }

  void _stopChase() {
    _timer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isChasing = false;
        _chaseCompleted = true;
      });
    }
  }

  void _handleFinalClick() {
    if (_isChasing) return; // Should be handled by overlay, but safe-guard
    
    if (!_hasUnlocked && _chaseStartTime != null) {
      _hasUnlocked = true;
      widget.onBadgeEarned?.call();
      _showAchievementDialog();
    } else {
      widget.onPressed();
    }
  }

  void _showAchievementDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFFFD700), width: 1),
        ),
        title: Row(
          children: [
            const Text('🏆 ', style: TextStyle(fontSize: 24)),
            Expanded(
              child: Text(
                'Achievement Unlocked',
                style: GoogleFonts.spaceGrotesk(
                  color: const Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '"The Button Chaser"\n\nIf you can catch a button, you can definitely handle what\'s waiting for you inside.',
          style: GoogleFonts.spaceGrotesk(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onPressed();
            },
            child: Text(
              "LET'S GO!",
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isChasing ? 0.0 : 1.0,
      child: MouseRegion(
        onEnter: (_) => _startChase(),
        child: GestureDetector(
          onTapDown: (_) => _startChase(),
          child: SizedBox(
            key: _buttonKey,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.enabled ? _handleFinalClick : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
