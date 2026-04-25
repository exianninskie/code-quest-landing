import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'widgets/chasing_button.dart';

class LoginMobile extends StatelessWidget {
  const LoginMobile({
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            Center(
              child: const Text(
                '⚔️',
                style: TextStyle(fontSize: 80),
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

            const Gap(12),

            Text(
              'Code Quest',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
            ).animate().fadeIn(delay: 200.ms),

            Text(
              'Learn to code through adventure',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.5),
                  ),
            ).animate().fadeIn(delay: 300.ms),

            const Gap(40),

            if (isSignUp) ...[
              TextField(
                controller: usernameCtrl,
                onChanged: (_) => (context as Element).markNeedsBuild(),
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ).animate().fadeIn(delay: 100.ms),
              const Gap(12),
            ],

            TextField(
              controller: emailCtrl,
              onChanged: (_) => (context as Element).markNeedsBuild(),
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const Gap(12),
            TextField(
              controller: passwordCtrl,
              onChanged: (_) => (context as Element).markNeedsBuild(),
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),

            if (errorMessage != null) ...[
              const Gap(12),
              Text(
                errorMessage!,
                style: const TextStyle(color: Color(0xFFE24B4A)),
                textAlign: TextAlign.center,
              ),
            ],

            const Gap(20),
            
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
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

            const Gap(12),

            TextButton(
              onPressed: onToggleMode,
              child: Text(
                isSignUp
                    ? 'Already have an account? Sign in'
                    : 'New here? Create an account',
                style: TextStyle(color: cs.primary),
              ),
            ),
            const Gap(48),
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
            const Gap(12),
          ],
        ),
      ),
    );
  }
}
