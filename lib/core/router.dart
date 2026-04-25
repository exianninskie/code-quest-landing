import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/game/chapter_screen.dart';
import '../screens/game/puzzle_screen.dart';
import '../screens/game/chapter_complete_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/certificates_screen.dart';
import '../screens/profile/about_screen.dart';
import '../screens/profile/legal_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../services/auth_service.dart';

part 'router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isAboutRoute = state.matchedLocation.startsWith('/about');
      final isLegalRoute = state.matchedLocation.contains('privacy-policy') || 
                          state.matchedLocation.contains('terms-of-service');
      final isPublicRoute = isAboutRoute || isLegalRoute;

      if (!isLoggedIn && !isAuthRoute && !isPublicRoute) return '/auth/login';
      if (isLoggedIn && (isAuthRoute || state.matchedLocation == '/')) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'chapter/:id',
            builder: (_, state) => ChapterScreen(
              key: ValueKey(state.pathParameters['id']!),
              chapterId: state.pathParameters['id']!,
            ),
            routes: [
              GoRoute(
                path: 'complete',
                builder: (_, state) {
                  final extra = state.extra as int?;
                  return ChapterCompleteScreen(
                    chapterId: state.pathParameters['id']!,
                    xpEarned: extra ?? 0,
                  );
                },
              ),
              GoRoute(
                path: 'puzzle/:puzzleId',
                builder: (_, state) => PuzzleScreen(
                  key: ValueKey('${state.pathParameters['id']!}-${state.pathParameters['puzzleId']!}'),
                  chapterId: state.pathParameters['id']!,
                  puzzleId: state.pathParameters['puzzleId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'profile',
            builder: (_, __) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'certificate',
                builder: (_, __) => const CertificatesScreen(),
              ),
              GoRoute(
                path: 'soul-link',
                builder: (_, __) => const ChatScreen(),
              ),
              GoRoute(
                path: 'privacy-policy',
                builder: (context, state) => const LegalScreen(
                  title: '',
                  assetPath: 'assets/docs/privacy_policy.md',
                ),
              ),
              GoRoute(
                path: 'terms-of-service',
                builder: (context, state) => const LegalScreen(
                  title: '',
                  assetPath: 'assets/docs/terms_of_service.md',
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/about',
        builder: (_, __) => const AboutScreen(),
      ),
    ],
  );
}
