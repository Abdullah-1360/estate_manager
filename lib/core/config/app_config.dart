import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiUrl => dotenv.env['API_URL'] ?? 'http://localhost:3000/api/v1';
  
  // Other configuration values can be added here
  static String get appName => dotenv.env['APP_NAME'] ?? 'Estate Manager';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  
  // Debug configuration
  static bool get isDebugMode => dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  
  // API configuration
  static int get apiTimeout => int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30') ?? 30;
  static int get maxRetries => int.tryParse(dotenv.env['MAX_RETRIES'] ?? '3') ?? 3;
  
  // Image configuration
  static int get maxImageSize => int.tryParse(dotenv.env['MAX_IMAGE_SIZE'] ?? '5') ?? 5; // MB
  static int get maxImagesPerProperty => int.tryParse(dotenv.env['MAX_IMAGES_PER_PROPERTY'] ?? '10') ?? 10;
  
  // Cache configuration
  static int get cacheExpiryMinutes => int.tryParse(dotenv.env['CACHE_EXPIRY_MINUTES'] ?? '30') ?? 30;
  
  /// Initialize the configuration
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }
  
  /// Get environment-specific configuration
  static Map<String, dynamic> getEnvironmentInfo() {
    return {
      'apiUrl': apiUrl,
      'appName': appName,
      'appVersion': appVersion,
      'isDebugMode': isDebugMode,
      'apiTimeout': apiTimeout,
      'maxRetries': maxRetries,
      'maxImageSize': maxImageSize,
      'maxImagesPerProperty': maxImagesPerProperty,
      'cacheExpiryMinutes': cacheExpiryMinutes,
    };
  }
  
  /// Check if running on emulator/simulator
  static bool get isEmulator {
    // This can be enhanced with platform-specific checks
    return apiUrl.contains('10.0.2.2') || apiUrl.contains('127.0.0.1');
  }
  
  /// Get the appropriate API URL based on platform
  static String getApiUrlForPlatform() {
    // You can add platform-specific logic here if needed
    return apiUrl;
  }
}