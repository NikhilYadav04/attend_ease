/// Pass --dart-define=ENV=prod (or staging) at build time to switch targets.
/// Default is 'dev' which points to the Android emulator loopback address.
///
/// Examples:
///   flutter run --dart-define=ENV=dev        (emulator)
///   flutter run --dart-define=ENV=prod       (production server)
class ApiConfig {
  static const String _env =
      String.fromEnvironment('ENV', defaultValue: 'dev');

  static const String _baseUrlDev = 'http://10.0.2.2:2000';
  static const String _baseUrlProd = 'https://api.attendease.com'; // TODO: replace with real prod URL

  static String get baseUrl {
    switch (_env) {
      case 'prod':
        return _baseUrlProd;
      default:
        return _baseUrlDev;
    }
  }

  static String get currentEnvironment => _env;

  static const int connectTimeout = 60000;
  static const int receiveTimeout = 60000;
}
