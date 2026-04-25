import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'widgets/chasing_button.dart';

class LoginWeb extends StatelessWidget {
  const LoginWeb({
    super.key,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.usernameCtrl,
    required this.isSignUp,
    required this.loading,
    this.errorMessage,
    required this.onSubmit,
    required this.onToggleMode,
    this.onBadgeEarned,
  });

  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController usernameCtrl;
  final bool isSignUp;
  final bool loading;
  final String? errorMessage;
  final VoidCallback onSubmit;
  final VoidCallback onToggleMode;
  final VoidCallback? onBadgeEarned;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Check if form is filled for the prank logic
    final isFormFilled = emailCtrl.text.trim().isNotEmpty && 
                        passwordCtrl.text.isNotEmpty && 
                        (isSignUp ? usernameCtrl.text.trim().isNotEmpty : true);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Center(
                  child: const Text(
                    '⚔️',
                    style: TextStyle(fontSize: 64),
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

                const Gap(16),

                Text(
                  'Code Quest',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                ).animate().fadeIn(delay: 200.ms),

                const Gap(8),

                Text(
                  'Learn to code through adventure',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.4),
                        letterSpacing: 0.5,
                      ),
                ).animate().fadeIn(delay: 300.ms),

                const Gap(48),

                if (isSignUp) ...[
                  TextField(
                    controller: usernameCtrl,
                    onChanged: (_) => (context as Element).markNeedsBuild(),
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  const Gap(16),
                ],

                TextField(
                  controller: emailCtrl,
                  onChanged: (_) => (context as Element).markNeedsBuild(),
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined, size: 20),
                  ),
                ),
                const Gap(16),
                TextField(
                  controller: passwordCtrl,
                  onChanged: (_) => (context as Element).markNeedsBuild(),
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline, size: 20),
                  ),
                ),

                if (errorMessage != null) ...[
                  const Gap(16),
                  Text(
                    errorMessage!,
                    style: const TextStyle(
                        color: Color(0xFFE24B4A), fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],

                const Gap(32),

                if (isSignUp)
                  ChasingButton(
                    onPressed: loading ? () {} : onSubmit,
                    onBadgeEarned: onBadgeEarned,
                    enabled: !loading && isFormFilled,
                    child: const Text(
                      "START ADVENTURE",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: loading ? null : onSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'CONTINUE QUEST',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),

                const Gap(16),

                TextButton(
                  onPressed: onToggleMode,
                  child: Text(
                    isSignUp
                        ? 'Already have an account? Sign in'
                        : 'New here? Create an account',
                    style: TextStyle(
                      color: cs.primary.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ),
                const Gap(32),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
