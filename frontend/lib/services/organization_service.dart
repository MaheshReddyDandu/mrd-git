import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class OrganizationService extends BaseApiService {
  // Department endpoints
  static Future<List<Map<String, dynamic>>> getDepartments({
    String? branchId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (branchId != null) queryParams['branch_id'] = branchId;

      final uri = Uri.parse('${BaseApiService.baseUrlValue}/organization/departments')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get departments: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting departments: $e');
    }
  }

  static Future<Map<String, dynamic>> createDepartment(Map<String, dynamic> departmentData) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/organization/departments'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode(departmentData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create department: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating department: $e');
    }
  }

  static Future<Map<String, dynamic>> updateDepartment(String departmentId, Map<String, dynamic> departmentData) async {
    try {
      final response = await http.put(
        Uri.parse('${BaseApiService.baseUrlValue}/organization/departments/$departmentId'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode(departmentData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update department: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating department: $e');
    }
  }

  static Future<void> deleteDepartment(String departmentId) async {
    try {
      final response = await http.delete(
        Uri.parse('${BaseApiService.baseUrlValue}/organization/departments/$departmentId'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete department: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting department: $e');
    }
  }

  // Branch endpoints
  static Future<List<Map<String, dynamic>>> getBranches() async {
    try {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrlValue}/organization/branches'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get branches: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting branches: $e');
    }
  }

  static Future<Map<String, dynamic>> createBranch(Map<String, dynamic> branchData) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/organization/branches'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode(branchData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create branch: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating branch: $e');
    }
  }

  static Future<Map<String, dynamic>> updateBranch(String branchId, Map<String, dynamic> branchData) async {
    try {
      final response = await http.put(
        Uri.parse('${BaseApiService.baseUrlValue}/organization/branches/$branchId'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode(branchData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update branch: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating branch: $e');
    }
  }

  static Future<void> deleteBranch(String branchId) async {
    try {
      final response = await http.delete(
        Uri.parse('${BaseApiService.baseUrlValue}/organization/branches/$branchId'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete branch: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting branch: $e');
    }
  }
} 