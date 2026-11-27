import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/l10n/app_strings.dart';

/// Overridden in main() with the real instance, so every provider can read prefs synchronously.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPrefsProvider must be overridden'),
);

enum TextSizeSetting {
  small(0.9),
  normal(1.0),
  large(1.15),
  accessible(2.0);

  const TextSizeSetting(this.factor);
  final double factor;
}

@immutable
class Settings {
  const Settings({
    this.language = 'en',
    this.themeMode = ThemeMode.system,
    this.textSize = TextSizeSetting.normal,
    this.homeState,
    this.breakingAlerts = false,
    this.dailyDigest = false,
    this.digestMinutes = 8 * 60,
    this.onboarded = false,
  });

  final String language;
  final ThemeMode themeMode;
  final TextSizeSetting textSize;
  final String? homeState;
  final bool breakingAlerts;
  final bool dailyDigest;
  final int digestMinutes;
  final bool onboarded;

  TimeOfDay get digestTime => TimeOfDay(hour: digestMinutes ~/ 60, minute: digestMinutes % 60);

  Settings copyWith({
    String? language,
    ThemeMode? themeMode,
    TextSizeSetting? textSize,
    String? homeState,
    bool clearHomeState = false,
    bool? breakingAlerts,
    bool? dailyDigest,
    int? digestMinutes,
    bool? onboarded,
  }) =>
      Settings(
        language: language ?? this.language,
        themeMode: themeMode ?? this.themeMode,
        textSize: textSize ?? this.textSize,
        homeState: clearHomeState ? null : (homeState ?? this.homeState),
        breakingAlerts: breakingAlerts ?? this.breakingAlerts,
        dailyDigest: dailyDigest ?? this.dailyDigest,
        digestMinutes: digestMinutes ?? this.digestMinutes,
        onboarded: onboarded ?? this.onboarded,
      );
}

class SettingsNotifier extends Notifier<Settings> {
  late SharedPreferences _prefs;

  @override
  Settings build() {
    _prefs = ref.watch(sharedPrefsProvider);
    return Settings(
      language: _prefs.getString('language') ?? 'en',
      themeMode: ThemeMode.values.asNameMap()[_prefs.getString('themeMode')] ?? ThemeMode.system,
      textSize: TextSizeSetting.values.asNameMap()[_prefs.getString('textSize')] ??
          TextSizeSetting.normal,
      homeState: _prefs.getString('homeState'),
      breakingAlerts: _prefs.getBool('breakingAlerts') ?? false,
      dailyDigest: _prefs.getBool('dailyDigest') ?? false,
      digestMinutes: _prefs.getInt('digestMinutes') ?? 8 * 60,
      onboarded: _prefs.getBool('onboarded') ?? false,
    );
  }

  void _set(Settings next) {
    state = next;
    _prefs
      ..setString('language', next.language)
      ..setString('themeMode', next.themeMode.name)
      ..setString('textSize', next.textSize.name)
      ..setBool('breakingAlerts', next.breakingAlerts)
      ..setBool('dailyDigest', next.dailyDigest)
      ..setInt('digestMinutes', next.digestMinutes)
      ..setBool('onboarded', next.onboarded);
    final s = next.homeState;
    s == null ? _prefs.remove('homeState') : _prefs.setString('homeState', s);
  }

  void setLanguage(String v) => _set(state.copyWith(language: v));
  void setThemeMode(ThemeMode v) => _set(state.copyWith(themeMode: v));
  void setTextSize(TextSizeSetting v) => _set(state.copyWith(textSize: v));
  void setHomeState(String? v) =>
      _set(v == null ? state.copyWith(clearHomeState: true) : state.copyWith(homeState: v));
  void setBreakingAlerts(bool v) => _set(state.copyWith(breakingAlerts: v));
  void setDailyDigest(bool v) => _set(state.copyWith(dailyDigest: v));
  void setDigestTime(TimeOfDay t) => _set(state.copyWith(digestMinutes: t.hour * 60 + t.minute));
  void completeOnboarding() => _set(state.copyWith(onboarded: true));
}

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);

/// Localised UI copy for the current language.
final stringsProvider = Provider<AppStrings>(
  (ref) => AppStrings(ref.watch(settingsProvider.select((s) => s.language))),
);
