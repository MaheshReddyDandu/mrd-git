import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8000';
  static String? _token;

  static void setToken(String token) {
    print('Setting token: ${token.substring(0, token.length > 10 ? 10 : token.length)}...');
    _token = token;
  }

  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
    print('Request headers: $headers');
    return headers;
  }

  // Auth endpoints
  static Future<Map<String, dynamic>> login(String email, String password) async {
    print('Making login request to: $baseUrl/auth/login');
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    print('Login response status: ${response.statusCode}');
    print('Login response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['access_token'];
      return data;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> register(
      String email, String username, String password) async {
    print('Making register request to: $baseUrl/auth/register');
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'username': username,
        'password': password,
      }),
    );
    print('Register response status: ${response.statusCode}');
    print('Register response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    print('Making getCurrentUser request to: $baseUrl/auth/me');
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _headers,
    );
    print('GetCurrentUser response status: ${response.statusCode}');
    print('GetCurrentUser response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user info: ${response.body}');
    }
  }

  // Admin endpoints
  static Future<List<dynamic>> getAllUsers() async {
    print('Making getAllUsers request to: $baseUrl/admin/users');
    final response = await http.get(
      Uri.parse('$baseUrl/admin/users'),
      headers: _headers,
    );
    print('GetAllUsers response status: ${response.statusCode}');
    print('GetAllUsers response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get users: ${response.body}');
    }
  }

  // Manager endpoints
  static Future<Map<String, dynamic>> getManagerDashboard() async {
    print('Making getManagerDashboard request to: $baseUrl/manager/dashboard');
    final response = await http.get(
      Uri.parse('$baseUrl/manager/dashboard'),
      headers: _headers,
    );
    print('GetManagerDashboard response status: ${response.statusCode}');
    print('GetManagerDashboard response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get dashboard: ${response.body}');
    }
  }

  // User endpoints
  static Future<Map<String, dynamic>> getUserProfile() async {
    print('Making getUserProfile request to: $baseUrl/user/profile');
    final response = await http.get(
      Uri.parse('$baseUrl/user/profile'),
      headers: _headers,
    );
    print('GetUserProfile response status: ${response.statusCode}');
    print('GetUserProfile response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get profile: ${response.body}');
    }
  }
} 