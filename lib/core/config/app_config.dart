enum AppEnvironment { development, staging, production }

class AppConfig {
  static AppEnvironment environment = AppEnvironment.development;

  static String get baseUrl {
    switch (environment) {
      case AppEnvironment.development:
        return 'http://10.0.2.2:8000/api/';
      case AppEnvironment.staging:
        return 'https://api.staging.samiti.com/api/';
      case AppEnvironment.production:
        return 'https://api.samiti.com/api/';
    }
  }
}
