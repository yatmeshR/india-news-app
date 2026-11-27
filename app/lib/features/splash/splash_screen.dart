import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../state/settings_provider.dart';

/// The Paper app icon (assets/images/logo.svg).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72});
  final double size;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        'assets/images/logo.svg',
        width: size,
        height: size,
        semanticsLabel: 'News App',
      );
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

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _total = Duration(milliseconds: 1400);
  late final AnimationController _c = AnimationController(vsync: this, duration: _total);
  Timer? _timer;

  late final Animation<double> _logoFade = CurvedAnimation(
    parent: _c,
    curve: const Interval(0, .35, curve: Curves.easeOut),
  );
  late final Animation<double> _logoScale = Tween(begin: .6, end: 1.0).animate(
    CurvedAnimation(parent: _c, curve: const Interval(0, .5, curve: Curves.easeOutBack)),
  );
  late final Animation<double> _wordFade = CurvedAnimation(
    parent: _c,
    curve: const Interval(.4, .75, curve: Curves.easeOut),
  );
  late final Animation<Offset> _wordSlide = Tween(begin: const Offset(0, .4), end: Offset.zero)
      .animate(CurvedAnimation(parent: _c, curve: const Interval(.4, .75, curve: Curves.easeOutCubic)));
  late final Animation<double> _tagFade = CurvedAnimation(
    parent: _c,
    curve: const Interval(.65, 1, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _timer = Timer(_total + const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final onboarded = ref.read(settingsProvider).onboarded;
      context.go(onboarded ? Routes.feed : Routes.welcome);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduced motion: show the finished frame immediately.
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.value = 1;
    } else if (!_c.isAnimating && _c.value == 0) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          FadeTransition(
            opacity: _logoFade,
            child: ScaleTransition(scale: _logoScale, child: const AppLogo(size: 88)),
          ),
          const SizedBox(height: 24),
          FadeTransition(
            opacity: _wordFade,
            child: SlideTransition(position: _wordSlide, child: const Wordmark(size: 32)),
          ),
          const SizedBox(height: 8),
          FadeTransition(
            opacity: _tagFade,
            child: Text(s('tagline'),
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: scheme.onSurfaceVariant)),
          ),
        ]),
      ),
    );
  }
}
