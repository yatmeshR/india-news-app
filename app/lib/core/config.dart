import 'package:flutter/foundation.dart';

abstract final class AppConfig {
  /// Production API (Render free plan). Builds use it by default.
  /// Local backend from the Android emulator (it reaches the host at 10.0.2.2):
  ///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://india-news-api.onrender.com',
  );

  /// When the API is unreachable and nothing is cached, show the three bundled
  /// sample stories instead of an error. On by default in debug builds only.
  static const allowSampleFallback = bool.fromEnvironment(
    'SAMPLE_FALLBACK',
    defaultValue: kDebugMode,
  );

  /// Render's free plan sleeps when idle; the first request can take 30-60 s to wake it.
  static const requestTimeout = Duration(seconds: 60);
  static const pageSize = 20;
}
