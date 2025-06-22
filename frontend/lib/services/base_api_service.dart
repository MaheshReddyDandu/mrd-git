import 'package:shared_preferences/shared_preferences.dart';

class BaseApiService {
  static const String baseUrl = 'http://localhost:8000';
  static const String _tokenKey = 'auth_token';
  static String? _token;

  static Future<void> initialize() async {
    // Load token from shared preferences on app start
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    print('Loaded token from storage: ${_token != null ? _token!.substring(0, _token!.length > 10 ? 10 : _token!.length) + '...' : 'null'}');
  }

  static Future<void> setToken(String token) async {
    print('Setting token: ${token.substring(0, token.length > 10 ? 10 : token.length)}...');
    _token = token;
    
    // Save token to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    print('Token saved to storage');
  }

  static Future<void> clearToken() async {
    print('Clearing token');
    _token = null;
    
    // Remove token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    print('Token removed from storage');
  }

  static bool isAuthenticated() {
    return _token != null;
  }

  static Map<String, String> get headers {
    final headers = {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
    print('Request headers: $headers');
    return headers;
  }

  // Helper methods for subclasses
  static String get baseUrlValue => baseUrl;
  static Map<String, String> get requestHeaders => headers;
} 