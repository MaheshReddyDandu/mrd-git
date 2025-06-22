import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'base_api_service.dart';

class AuthService extends BaseApiService {
  static const String baseUrl = BaseApiService.baseUrl;
  static const String loginEndpoint = BaseApiService.loginEndpoint;
  static const String registerEndpoint = BaseApiService.registerEndpoint;

  // Auth endpoints
  static Future<List<dynamic>> fetchTenants() async {
    try {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrlValue}/tenants'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch tenants');
      }
    } catch (e) {
      throw Exception('Error fetching tenants: $e');
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password, String tenantId) async {
    print('Attempting login for email: $email');
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/auth/login'),
        headers: BaseApiService.requestHeaders,
        body: json.encode({
          'email': email,
          'password': password,
          'tenant_id': tenantId,
        }),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await BaseApiService.setToken(data['access_token']);
        return {
          'success': true,
          'data': data,
          'message': 'Login successful',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['detail'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
    required String tenantId,
    required String companyName,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/auth/register'),
        headers: BaseApiService.requestHeaders,
        body: json.encode({
          'email': email,
          'password': password,
          'username': username,
          'tenant_id': tenantId,
          'company_name': companyName,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        await BaseApiService.setToken(data['access_token']);
        return {
          'success': true,
          'data': data,
          'message': 'Registration successful',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['detail'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
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

  static Future<Map<String, dynamic>> forgotPassword(String email, String tenantId) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/auth/forgot-password'),
        headers: BaseApiService.requestHeaders,
        body: json.encode({
          'email': email,
          'tenant_id': tenantId,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password reset email sent',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['detail'] ?? 'Failed to send reset email',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
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
        body: json.encode({
          'token': token,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password reset successful',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['detail'] ?? 'Password reset failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password changed successfully',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['detail'] ?? 'Password change failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getTenants() async {
    try {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrlValue}/tenants'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch tenants',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
} 