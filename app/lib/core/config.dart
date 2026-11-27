import 'package:flutter/foundation.dart';

abstract final class AppConfig {
  /// Android emulator reaches the host machine at 10.0.2.2.
  /// Override: flutter run --dart-define=API_BASE_URL=https://your-api.onrender.com
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  /// When the API is unreachable and nothing is cached, show the three bundled
  /// sample stories instead of an error. On by default in debug builds only.
  static const allowSampleFallback = bool.fromEnvironment(
    'SAMPLE_FALLBACK',
    defaultValue: kDebugMode,
  );

  static const requestTimeout = Duration(seconds: 10);
  static const pageSize = 20;
}
