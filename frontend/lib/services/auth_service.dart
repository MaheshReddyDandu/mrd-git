import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'base_api_service.dart';

class AuthService extends BaseApiService {
  // Auth endpoints
  static Future<List<dynamic>> fetchTenants() async {
    print('Fetching tenants from: $baseUrl/admin/tenants');
    final response = await http.get(
      Uri.parse('$baseUrl/admin/tenants'),
      headers: headers,
    );
    print('FetchTenants response status: ${response.statusCode}');
    print('FetchTenants response body: ${response.body}');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch tenants: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String tenantId,
  }) async {
    try {
      print('Attempting login for user: $email');
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/auth/login'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode({
          'email': email,
          'password': password,
          'tenant_id': tenantId,
        }),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await BaseApiService.setToken(data['access_token']);
        return data;
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
    required String tenantId,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/auth/register'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode({
          'email': email,
          'password': password,
          'username': username,
          'tenant_id': tenantId,
          'first_name': firstName,
          'last_name': lastName,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await BaseApiService.setToken(data['access_token']);
        return data;
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/auth/logout'),
        headers: BaseApiService.requestHeaders,
      );
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await BaseApiService.clearToken();
    }
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrlValue}/auth/me'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get current user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting current user: $e');
    }
  }

  static Future<Map<String, dynamic>> refreshToken() async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/auth/refresh'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await BaseApiService.setToken(data['access_token']);
        return data;
      } else {
        throw Exception('Token refresh failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Token refresh error: $e');
    }
  }

  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
    required String tenantId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/auth/forgot-password'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode({
          'email': email,
          'tenant_id': tenantId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Forgot password failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Forgot password error: $e');
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/auth/reset-password'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode({
          'token': token,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Password reset failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Password reset error: $e');
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/auth/change-password'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Password change failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Password change error: $e');
    }
  }
} 