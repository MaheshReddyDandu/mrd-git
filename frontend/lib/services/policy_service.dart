import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class PolicyService extends BaseApiService {
  // Policy endpoints
  static Future<List<Map<String, dynamic>>> listPolicies() async {
    try {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrlValue}/policies'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to list policies: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error listing policies: $e');
    }
  }

  static Future<Map<String, dynamic>> createPolicy(Map<String, dynamic> policyData) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/policies'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode(policyData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create policy: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating policy: $e');
    }
  }

  static Future<Map<String, dynamic>> getPolicy(String policyId) async {
    try {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrlValue}/policies/$policyId'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get policy: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting policy: $e');
    }
  }

  static Future<Map<String, dynamic>> updatePolicy(String policyId, Map<String, dynamic> policyData) async {
    try {
      final response = await http.put(
        Uri.parse('${BaseApiService.baseUrlValue}/policies/$policyId'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode(policyData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update policy: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating policy: $e');
    }
  }

  static Future<void> deletePolicy(String policyId) async {
    try {
      final response = await http.delete(
        Uri.parse('${BaseApiService.baseUrlValue}/policies/$policyId'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete policy: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting policy: $e');
    }
  }

  // Policy Assignment endpoints
  static Future<Map<String, dynamic>> assignPolicy(Map<String, dynamic> assignmentData) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/policies/assign'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode(assignmentData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to assign policy: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error assigning policy: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getUserEffectivePolicies(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrlValue}/users/$userId/effective-policies'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get user effective policies: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting user effective policies: $e');
    }
  }
} 