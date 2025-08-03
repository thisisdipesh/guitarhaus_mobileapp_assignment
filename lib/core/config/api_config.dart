class ApiConfig {
  // Development URLs
  static const String localhost = 'http://localhost:3003/api/v1';
  static const String androidEmulator = 'http://10.0.2.2:3003/api/v1';
  static const String localNetwork = 'http://172.20.10.2:3003/api/v1';

  // Production URL (when you deploy the backend)
  static const String production = 'https://your-production-domain.com/api/v1';

  // Current active URL - change this based on your setup
  static const String baseUrl = localNetwork;

  // Timeout configurations
  static const int connectTimeout = 30; // seconds
  static const int receiveTimeout = 30; // seconds

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
  };
}
