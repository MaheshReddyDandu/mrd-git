import 'package:http/http.dart' as http;
import 'dart:convert';
import 'base_api_service.dart';

class ClientService extends BaseApiService {
  static Future<List<Map<String, dynamic>>> getClients() async {
    try {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrlValue}/clients'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get clients: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting clients: $e');
    }
  }

  static Future<Map<String, dynamic>> createClient(Map<String, dynamic> clientData) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrlValue}/clients'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode(clientData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create client: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating client: $e');
    }
  }

  static Future<Map<String, dynamic>> getClient(String clientId) async {
    try {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrlValue}/clients/$clientId'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get client: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting client: $e');
    }
  }

  static Future<Map<String, dynamic>> updateClient(String clientId, Map<String, dynamic> clientData) async {
    try {
      final response = await http.put(
        Uri.parse('${BaseApiService.baseUrlValue}/clients/$clientId'),
        headers: BaseApiService.requestHeaders,
        body: jsonEncode(clientData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update client: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating client: $e');
    }
  }

  static Future<void> deleteClient(String clientId) async {
    try {
      final response = await http.delete(
        Uri.parse('${BaseApiService.baseUrlValue}/clients/$clientId'),
        headers: BaseApiService.requestHeaders,
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete client: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting client: $e');
    }
  }
} 