import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../services/auth_service.dart';
import 'login_mobile.dart';
import 'login_web.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  bool _isSignUp = true;
  bool _loading = false;
  bool _buttonChaserEarned = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      if (_isSignUp) {
        await auth.signUp(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          username: _usernameCtrl.text.trim(),
        );
        // Save Button Chaser badge if user caught the chasing button
        if (_buttonChaserEarned) {
          final user = ref.read(supabaseProvider).auth.currentUser;
          if (user != null) {
            await ref.read(supabaseProvider).from('profiles').upsert({
              'id': user.id,
              'button_chaser_unlocked': true,
              'username': _usernameCtrl.text.trim(),
            });
          }
        }
      } else {
        await auth.signIn(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
      }
      // Router will redirect to /home automatically on auth state change
    } catch (e) {
      String message = 'An unexpected error occurred';
      final errorStr = e.toString();
      
      if (errorStr.contains('over_email_send_rate_limit')) {
        message = 'Slow down, Adventurer! Too many attempts. Please wait a minute before trying again.';
      } else if (errorStr.contains('User already registered')) {
        message = 'This email is already in our records. Try signing in instead!';
      } else if (errorStr.contains('Invalid login credentials')) {
        message = 'The secret word or email is incorrect. Check them and try again!';
      } else if (errorStr.contains('Database error') || errorStr.contains('unexpected_failure')) {
        message = 'The realm is slightly unstable right now! Please try starting your adventure one more time.';
      } else {
        message = errorStr;
      }
      setState(() => _errorMessage = message);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 700) {
              return LoginWeb(
                emailCtrl: _emailCtrl,
                passwordCtrl: _passwordCtrl,
                usernameCtrl: _usernameCtrl,
                isSignUp: _isSignUp,
                loading: _loading,
                errorMessage: _errorMessage,
                onSubmit: _submit,
                onToggleMode: () => setState(() => _isSignUp = !_isSignUp),
                onBadgeEarned: () => _buttonChaserEarned = true,
              );
            }
            return LoginMobile(
              emailCtrl: _emailCtrl,
              passwordCtrl: _passwordCtrl,
              usernameCtrl: _usernameCtrl,
              isSignUp: _isSignUp,
              loading: _loading,
              errorMessage: _errorMessage,
              onSubmit: _submit,
              onToggleMode: () => setState(() => _isSignUp = !_isSignUp),
              onBadgeEarned: () => _buttonChaserEarned = true,
            );
          },
        ),
      ),
    );
  }
}
