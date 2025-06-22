import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class LeaveService extends BaseApiService {
  // Leave Management endpoints
  static Future<List<Map<String, dynamic>>> listLeaveTypes() async {
    try {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrlValue}/leave/types'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to list leave types: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error listing leave types: $e');
    }
  }

  static Future<Map<String, dynamic>> createLeaveType(Map<String, dynamic> leaveTypeData) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/leave/types'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode(leaveTypeData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create leave type: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating leave type: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getLeaveRequests({
    String? status,
    String? userId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (userId != null) queryParams['user_id'] = userId;

      final uri = Uri.parse('${BaseApiService.baseUrlValue}/leave/requests')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get leave requests: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting leave requests: $e');
    }
  }

  static Future<Map<String, dynamic>> requestLeave(Map<String, dynamic> leaveData) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/leave/requests'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode(leaveData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to request leave: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error requesting leave: $e');
    }
  }

  static Future<Map<String, dynamic>> approveLeave({
    required String requestId,
    required String action,
    String? comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/leave/requests/$requestId/approve'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode({
          'action': action,
          'comment': comment,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to approve leave: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error approving leave: $e');
    }
  }

  static Future<Map<String, dynamic>> getLeaveBalance({
    String? userId,
    String? year,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (userId != null) queryParams['user_id'] = userId;
      if (year != null) queryParams['year'] = year;

      final uri = Uri.parse('${BaseApiService.baseUrlValue}/leave/balance')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get leave balance: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting leave balance: $e');
    }
  }

  static Future<Map<String, dynamic>> cancelLeaveRequest(String requestId) async {
    try {
      final response = await http.delete(
        Uri.parse('${BaseApiService.baseUrlValue}/leave/requests/$requestId'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to cancel leave request: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error canceling leave request: $e');
    }
  }
} 