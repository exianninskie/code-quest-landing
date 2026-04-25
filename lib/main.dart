import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'services/auth_service.dart';
import 'services/game_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // Initialize Supabase
  String supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
  if (supabaseUrl.endsWith('/')) {
    supabaseUrl = supabaseUrl.substring(0, supabaseUrl.length - 1);
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  runApp(
    // ProviderScope enables Riverpod state management throughout the app
    const ProviderScope(
      child: CodeQuestApp(),
    ),
  );
}

class CodeQuestApp extends ConsumerWidget {
  const CodeQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return UserActivityWrapper(
      child: MaterialApp.router(
        title: 'Code Quest',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class UserActivityWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const UserActivityWrapper({super.key, required this.child});

  @override
  ConsumerState<UserActivityWrapper> createState() => _UserActivityWrapperState();
}

class _UserActivityWrapperState extends ConsumerState<UserActivityWrapper> {
  DateTime? _lastUpdate;
  static const _throttleDuration = Duration(seconds: 10);

  void _handleInteraction() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final now = DateTime.now();
    if (_lastUpdate == null || now.difference(_lastUpdate!) > _throttleDuration) {
      _lastUpdate = now;
      // We don't await here because we don't want to block the UI thread 
      // or care about the result for a simple heartbeat
      ref.read(gameServiceProvider).updateLastActive(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _handleInteraction(),
      child: widget.child,
    );
  }
}
