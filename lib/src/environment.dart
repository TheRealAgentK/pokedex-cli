import 'dart:io';

/// Wraps access to environment variables.
/// Allows faking for testing.
class Environment {
  static const String baseUrlKey = 'POKEDEX_BASE_URL';

  final String? baseUrl;

  static Environment? _instance;

  static Environment get instance {
    _instance ??= Environment._init();
    return _instance!;
  }

  /// For testing purposes
  static void setInstance(Environment instance) {
    _instance = instance;
  }

  Environment({required this.baseUrl});

  String? operator [](String key) {
    switch (key) {
      case baseUrlKey:
        return baseUrl;
      default:
        throw ArgumentError('Unknown environment variable: $key');
    }
  }

  factory Environment._init() {
    final baseUrl = Platform.environment[baseUrlKey];
    return Environment(baseUrl: baseUrl);
  }
}
