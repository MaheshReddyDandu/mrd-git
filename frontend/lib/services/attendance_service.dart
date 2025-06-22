import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'base_api_service.dart';

class AttendanceService extends BaseApiService {
  // Enhanced Attendance endpoints
  static Future<String> getUserTimezone() async {
    try {
      if (kIsWeb) {
        // Web: Use Intl or fallback
        return DateTime.now().timeZoneName;
      } else {
        // Mobile/Desktop: Use native_timezone package
        return await FlutterNativeTimezone.getLocalTimezone();
      }
    } catch (e) {
      return 'UTC';
    }
  }

  static Future<Map<String, dynamic>> clockIn({
    required double latitude,
    required double longitude,
    required String location,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/attendance/clock-in'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'location': location,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to clock in: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error clocking in: $e');
    }
  }

  static Future<Map<String, dynamic>> clockOut({
    required double latitude,
    required double longitude,
    required String location,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/attendance/clock-out'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'location': location,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to clock out: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error clocking out: $e');
    }
  }

  static Future<Map<String, dynamic>> getCurrentSession() async {
    try {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrlValue}/attendance/current-session'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get current session: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting current session: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getAttendanceLogs({
    String? startDate,
    String? endDate,
    String? userId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (userId != null) queryParams['user_id'] = userId;

      final uri = Uri.parse('${BaseApiService.baseUrlValue}/attendance/logs')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get attendance logs: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting attendance logs: $e');
    }
  }

  static Future<Map<String, dynamic>> getAttendanceDetail(String logId) async {
    try {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrlValue}/attendance/logs/$logId'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get attendance detail: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting attendance detail: $e');
    }
  }

  static Future<Map<String, dynamic>> requestRegularization({
    required String logId,
    required String reason,
    required String requestedTime,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/attendance/regularization'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode({
          'log_id': logId,
          'reason': reason,
          'requested_time': requestedTime,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to request regularization: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error requesting regularization: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getRegularizationRequests({
    String? status,
    String? userId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (userId != null) queryParams['user_id'] = userId;

      final uri = Uri.parse('${BaseApiService.baseUrlValue}/attendance/regularization')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get regularization requests: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting regularization requests: $e');
    }
  }

  static Future<Map<String, dynamic>> approveRegularization({
    required String requestId,
    required String action,
    String? comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/attendance/regularization/$requestId/approve'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode({
          'action': action,
          'comment': comment,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to approve regularization: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error approving regularization: $e');
    }
  }

  static Future<Map<String, dynamic>> getAttendanceStats({
    String? startDate,
    String? endDate,
    String? userId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (userId != null) queryParams['user_id'] = userId;

      final uri = Uri.parse('${BaseApiService.baseUrlValue}/attendance/stats')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get attendance stats: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting attendance stats: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getMyAttendanceRecords({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final uri = Uri.parse('${BaseApiService.baseUrlValue}/attendance/my-records')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get attendance records: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting attendance records: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getMyAttendanceLogs({String? date}) async {
    try {
      final queryParams = <String, String>{};
      if (date != null) queryParams['date'] = date;

      final uri = Uri.parse('${BaseApiService.baseUrlValue}/attendance/my-logs')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get attendance logs: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting attendance logs: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getMyAttendanceLogsForRange({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final uri = Uri.parse('${BaseApiService.baseUrlValue}/attendance/my-logs')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get attendance logs for range: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting attendance logs for range: $e');
    }
  }

  static Future<Map<String, dynamic>> getMyAttendanceDetail(String date) async {
    try {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrlValue}/attendance/my-detail/$date'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get attendance detail: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting attendance detail: $e');
    }
  }

  // Legacy attendance endpoints (for backward compatibility)
  static Future<List<Map<String, dynamic>>> listAttendance(String tenantId) async {
    try {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrlValue}/attendance/$tenantId'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to list attendance: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error listing attendance: $e');
    }
  }

  static Future<Map<String, dynamic>> createAttendance(String tenantId, Map<String, dynamic> attendance) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/attendance/$tenantId'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode(attendance),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create attendance: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating attendance: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getAttendanceSummary(String tenantId) async {
    try {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrlValue}/attendance/$tenantId/summary'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get attendance summary: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting attendance summary: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getAttendanceReport(String tenantId, {String? startDate, String? endDate}) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final uri = Uri.parse('${BaseApiService.baseUrlValue}/attendance/$tenantId/report')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get attendance report: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting attendance report: $e');
    }
  }
} 