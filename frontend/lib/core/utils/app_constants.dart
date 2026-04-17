class AppConstants {
  static const String appName = 'Igisubizo Muhinzi';
  static const String appVersion = '1.0.0';
  
  // API Configuration - Use environment variable or default
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1', // Development default
  );
  
  // Production API URL (update this after deploying backend)
  // static const String apiBaseUrl = 'https://your-app.koyeb.app/api/v1';
  
  // Network Configuration
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds

  // Assets
  static const String translationPath = 'assets/translations';
  static const String admnistrativeDataPath = 'assets/data/administrative/data.json';
  static const String mapDataPath = 'assets/data/map/';

  // Design Tokens
  static const double borderRadius = 16.0;
  static const double cardElevation = 4.0;
  static const double padding = 16.0;
  
  // Localization
  static const List<String> supportedLanguages = ['en', 'fr', 'rw'];
  static const String defaultLanguage = 'rw';
}
