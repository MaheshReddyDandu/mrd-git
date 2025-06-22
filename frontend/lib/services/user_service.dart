import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class UserService extends BaseApiService {
  // User endpoints
  static Future<List<Map<String, dynamic>>> getUsers({
    String? role,
    String? departmentId,
    String? branchId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (role != null) queryParams['role'] = role;
      if (departmentId != null) queryParams['department_id'] = departmentId;
      if (branchId != null) queryParams['branch_id'] = branchId;

      final uri = Uri.parse('${BaseApiService.baseUrlValue}/users')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get users: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting users: $e');
    }
  }

  static Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/users'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  static Future<Map<String, dynamic>> getUser(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrlValue}/users/$userId'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting user: $e');
    }
  }

  static Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      final response = await http.put(
        Uri.parse('${BaseApiService.baseUrlValue}/users/$userId'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  static Future<void> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('${BaseApiService.baseUrlValue}/users/$userId'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  static Future<Map<String, dynamic>> addUserByAdmin(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/admin/users'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to add user by admin: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding user by admin: $e');
    }
  }

  // Role endpoints
  static Future<List<Map<String, dynamic>>> getRoles() async {
    try {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrlValue}/users/roles'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get roles: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting roles: $e');
    }
  }

  static Future<Map<String, dynamic>> createRole(Map<String, dynamic> roleData) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/users/roles'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode(roleData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create role: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating role: $e');
    }
  }

  static Future<Map<String, dynamic>> updateRole(String roleId, Map<String, dynamic> roleData) async {
    try {
      final response = await http.put(
        Uri.parse('${BaseApiService.baseUrlValue}/users/roles/$roleId'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode(roleData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update role: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating role: $e');
    }
  }

  static Future<void> deleteRole(String roleId) async {
    try {
      final response = await http.delete(
        Uri.parse('${BaseApiService.baseUrlValue}/users/roles/$roleId'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete role: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting role: $e');
    }
  }

  static Future<Map<String, dynamic>> adminAssignRole(String userId, String roleId) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/admin/users/$userId/assign-role'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode({'role_id': roleId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to assign role: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error assigning role: $e');
    }
  }
} 