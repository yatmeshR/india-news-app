import 'package:flutter/material.dart';

/// Paper design handoff. Register the bundled fonts using pubspec-fonts.yaml.
/// Theme starter, not a compiled app. Honour MediaQuery.textScalerOf(context);
/// never clamp a user's system scaling to fit a card.
abstract final class NewsTheme {
  static const spacing = <double>[4, 8, 12, 16, 20, 24, 32, 40, 48];
  static const cardRadius = 12.0;
  static const sheetRadius = 20.0;
  static const touchTarget = 48.0;
  static const storySlide = Duration(milliseconds: 250);
  static const bookmarkFill = Duration(milliseconds: 160);

  static ThemeData build({
    required Brightness brightness,
    String languageCode = 'en',
  }) {
    final dark = brightness == Brightness.dark;
    final hindi = languageCode == 'hi';
    final background = Color(dark ? 0xFF0F1217 : 0xFFF6F3EC);
    final surface = Color(dark ? 0xFF181C23 : 0xFFFFFFFF);
    final text = Color(dark ? 0xFFF2EFE8 : 0xFF14181F);
    final muted = Color(dark ? 0xFFA9B0BD : 0xFF4F5666);
    final border = Color(dark ? 0xFF2A303A : 0xFFE1DBCD);
    final accent = Color(dark ? 0xFFFF8A78 : 0xFFC5301F);
    final tonal = Color(dark ? 0xFF422720 : 0xFFFCE6E1);
    final link = Color(dark ? 0xFF5CC8C0 : 0xFF0E6B66);
    final sans = hindi ? 'Noto Sans Devanagari' : 'DM Sans';
    final serif = hindi ? 'Noto Serif Devanagari' : 'Libre Baskerville';

    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
    ).copyWith(
      primary: accent,
      onPrimary: Color(dark ? 0xFF3D0800 : 0xFFFFFFFF),
      primaryContainer: tonal,
      onPrimaryContainer: text,
      secondary: link,
      onSecondary: Color(dark ? 0xFF003733 : 0xFFFFFFFF),
      surface: surface,
      onSurface: text,
      onSurfaceVariant: muted,
      outline: muted,
      outlineVariant: border,
      surfaceContainerLowest: background,
      surfaceContainerLow: surface,
      surfaceContainer: surface,
      surfaceContainerHigh: surface,
      surfaceContainerHighest: surface,
      error: Color(dark ? 0xFFFFB4A8 : 0xFFA5281A),
      onError: Color(dark ? 0xFF3D0800 : 0xFFFFFFFF),
      surfaceTint: Colors.transparent,
    );
    TextStyle heading(double size, double lineHeight) => TextStyle(
      fontFamily: serif,
      fontFamilyFallback: const ['Noto Serif Devanagari'],
      fontWeight: hindi ? FontWeight.w600 : FontWeight.w700,
      fontSize: size,
      height: lineHeight / size,
      letterSpacing: hindi ? 0 : -0.5,
      color: text,
    );
    TextStyle body(double size, double lineHeight,
        {FontWeight weight = FontWeight.w400, Color? color}) => TextStyle(
      fontFamily: sans,
      fontFamilyFallback: const ['Noto Sans Devanagari'],
      fontWeight: weight,
      fontSize: size,
      height: lineHeight / size,
      color: color ?? text,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: sans,
      fontFamilyFallback: const ['Noto Sans Devanagari'],
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      textTheme: TextTheme(
        headlineLarge: heading(29, hindi ? 44 : 38),
        headlineSmall: heading(24, hindi ? 34 : 30),
        titleMedium: heading(17, hindi ? 29 : 25),
        bodyLarge: body(16, hindi ? 25 : 23),
        bodyMedium: body(14, hindi ? 23 : 21),
        bodySmall: body(12, hindi ? 20 : 18, color: muted),
        labelLarge: body(14, hindi ? 22 : 20, weight: FontWeight.w600),
      ),
      iconTheme: IconThemeData(color: text, size: 24),
      dividerTheme: DividerThemeData(color: border, thickness: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: background,
        indicatorColor: tonal,
        elevation: 0,
        height: 72,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          side: BorderSide(color: border),
          shape: const StadiumBorder(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: link, width: 2),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}
