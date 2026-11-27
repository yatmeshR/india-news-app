import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../state/settings_provider.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72});
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'News App',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFC5301F),
          borderRadius: BorderRadius.circular(size * .22),
        ),
        alignment: Alignment.center,
        child: Text(
          'N',
          style: TextStyle(
            fontFamily: 'Libre Baskerville',
            fontWeight: FontWeight.w700,
            fontSize: size * .5,
            color: Colors.white,
            decorationColor: scheme.surface,
          ),
        ),
      ),
    );
  }
}

/// Brand wordmark used in the feed top bar and splash.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.size = 24});
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 3, height: size, color: scheme.primary),
      const SizedBox(width: 8),
      Text(
        'News App',
        style: TextStyle(
          fontFamily: 'Libre Baskerville',
          fontWeight: FontWeight.w700,
          fontSize: size,
          letterSpacing: -.5,
          color: scheme.onSurface,
        ),
      ),
    ]);
  }
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      final onboarded = ref.read(settingsProvider).onboarded;
      context.go(onboarded ? Routes.feed : Routes.welcome);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const AppLogo(size: 88),
          const SizedBox(height: 24),
          const Wordmark(size: 32),
          const SizedBox(height: 8),
          Text(s('tagline'),
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: scheme.onSurfaceVariant)),
        ]),
      ),
    );
  }
}
