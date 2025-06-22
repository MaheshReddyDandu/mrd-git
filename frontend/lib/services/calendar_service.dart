import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class CalendarService extends BaseApiService {
  // Calendar and Holiday endpoints
  static Future<List<Map<String, dynamic>>> getHolidays({
    String? year,
    String? month,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (year != null) queryParams['year'] = year;
      if (month != null) queryParams['month'] = month;

      final uri = Uri.parse('${BaseApiService.baseUrlValue}/calendar/holidays')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get holidays: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting holidays: $e');
    }
  }

  static Future<Map<String, dynamic>> createHoliday(Map<String, dynamic> holidayData) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/calendar/holidays'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode(holidayData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create holiday: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating holiday: $e');
    }
  }

  static Future<Map<String, dynamic>> updateHoliday(String holidayId, Map<String, dynamic> holidayData) async {
    try {
      final response = await http.put(
        Uri.parse('${BaseApiService.baseUrlValue}/calendar/holidays/$holidayId'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode(holidayData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update holiday: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating holiday: $e');
    }
  }

  static Future<void> deleteHoliday(String holidayId) async {
    try {
      final response = await http.delete(
        Uri.parse('${BaseApiService.baseUrlValue}/calendar/holidays/$holidayId'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete holiday: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting holiday: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> listWeekOffs() async {
    try {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrlValue}/calendar/week-offs'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to list week offs: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error listing week offs: $e');
    }
  }

  static Future<Map<String, dynamic>> createWeekOff(Map<String, dynamic> weekOffData) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/calendar/week-offs'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode(weekOffData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create week off: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating week off: $e');
    }
  }
} 