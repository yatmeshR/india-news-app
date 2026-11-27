import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/news_theme.dart';
import 'state/settings_provider.dart';

class NewsApp extends ConsumerWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final lang = ref.watch(settingsProvider.select((s) => s.language));
    final mode = ref.watch(settingsProvider.select((s) => s.themeMode));
    final textSize = ref.watch(settingsProvider.select((s) => s.textSize));

    return MaterialApp.router(
      title: 'News App',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: mode,
      theme: NewsTheme.build(brightness: Brightness.light, languageCode: lang),
      darkTheme: NewsTheme.build(brightness: Brightness.dark, languageCode: lang),
      locale: Locale(lang),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('en'), Locale('hi')],
      builder: (context, child) {
        // In-app text size multiplies the system font scale; it never clamps it.
        final system = MediaQuery.textScalerOf(context);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: textSize == TextSizeSetting.normal
                ? system
                : _ScaledTextScaler(system, textSize.factor),
          ),
          child: child!,
        );
      },
    );
  }
}

class _ScaledTextScaler extends TextScaler {
  const _ScaledTextScaler(this.base, this.factor);
  final TextScaler base;
  final double factor;

  @override
  double scale(double fontSize) => base.scale(fontSize) * factor;

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => scale(1);

  @override
  bool operator ==(Object other) =>
      other is _ScaledTextScaler && other.base == base && other.factor == factor;

  @override
  int get hashCode => Object.hash(base, factor);
}
