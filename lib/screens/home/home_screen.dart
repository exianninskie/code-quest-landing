import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_mobile.dart';
import 'home_web.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // We use LayoutBuilder to switch between Mobile and Web views
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 700) {
            return const HomeWeb();
          }
          return const HomeMobile();
        },
      ),
    );
  }
}
