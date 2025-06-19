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
  static Future<List<dynamic>> fetchTenants() async {
    print('Fetching tenants from: $baseUrl/admin/tenants');
    final response = await http.get(
      Uri.parse('$baseUrl/admin/tenants'),
      headers: _headers,
    );
    print('FetchTenants response status: ${response.statusCode}');
    print('FetchTenants response body: ${response.body}');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch tenants: ${response.body}');
    }
  }

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

  static Future<Map<String, dynamic>> register(String email, String username, String password, String tenantId) async {
    print('Making register request to: $baseUrl/auth/register');
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'username': username,
        'password': password,
        'tenant_id': tenantId,
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

  // Employee endpoints
  static Future<List<dynamic>> listEmployees(String tenantId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tenants/$tenantId/employees'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to list employees: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createEmployee(String tenantId, Map<String, dynamic> employee) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tenants/$tenantId/employees'),
      headers: _headers,
      body: jsonEncode(employee),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create employee: ${response.body}');
    }
  }

  // Attendance endpoints
  static Future<List<dynamic>> listAttendance(String tenantId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tenants/$tenantId/attendance'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to list attendance: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createAttendance(String tenantId, Map<String, dynamic> attendance) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tenants/$tenantId/attendance'),
      headers: _headers,
      body: jsonEncode(attendance),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create attendance: ${response.body}');
    }
  }

  // Policy endpoints
  static Future<List<dynamic>> listPolicies(String tenantId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tenants/$tenantId/policies'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to list policies: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createPolicy(String tenantId, Map<String, dynamic> policy) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tenants/$tenantId/policies'),
      headers: _headers,
      body: jsonEncode(policy),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create policy: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> assignPolicy(String tenantId, Map<String, dynamic> assignment) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tenants/$tenantId/policy-assignments'),
      headers: _headers,
      body: jsonEncode(assignment),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to assign policy: ${response.body}');
    }
  }

  static Future<List<dynamic>> getEffectivePolicy(String tenantId, String employeeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tenants/$tenantId/employees/$employeeId/effective-policy'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get effective policy: ${response.body}');
    }
  }

  // Regularization endpoints
  static Future<Map<String, dynamic>> submitRegularizationRequest(String tenantId, Map<String, dynamic> req) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tenants/$tenantId/regularization-requests'),
      headers: _headers,
      body: jsonEncode(req),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to submit regularization request: ${response.body}');
    }
  }

  static Future<List<dynamic>> listRegularizationRequests(String tenantId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tenants/$tenantId/regularization-requests'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to list regularization requests: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> approveRegularizationRequest(String tenantId, String requestId, Map<String, dynamic> approval) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tenants/$tenantId/regularization-requests/$requestId/approve'),
      headers: _headers,
      body: jsonEncode(approval),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to approve regularization request: ${response.body}');
    }
  }

  // Analytics endpoints
  static Future<List<dynamic>> getAttendanceSummary(String tenantId, {String period = 'daily'}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tenants/$tenantId/attendance-summary?period=$period'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get attendance summary: ${response.body}');
    }
  }

  static Future<List<dynamic>> getDepartmentAttendanceSummary(String tenantId, String departmentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tenants/$tenantId/departments/$departmentId/attendance-summary'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get department attendance summary: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getDashboardStats(String tenantId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tenants/$tenantId/dashboard-stats'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get dashboard stats: ${response.body}');
    }
  }

  // SaaS Admin endpoints
  static Future<List<dynamic>> adminListTenants() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/tenants'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to list tenants: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> adminAssignPlan(String tenantId, String plan) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/tenants/$tenantId/assign-plan'),
      headers: _headers,
      body: jsonEncode({'plan': plan}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to assign plan: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> adminTenantUsage(String tenantId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/tenants/$tenantId/usage'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get tenant usage: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to request password reset: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> resetPassword(String token, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: _headers,
      body: jsonEncode({
        'token': token,
        'new_password': newPassword,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to reset password: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/change-password'),
      headers: _headers,
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to change password: ${response.body}');
    }
  }

  // SaaS onboarding: signup client (first tenant+owner)
  static Future<Map<String, dynamic>> signupClient({
    required String tenantName,
    required String tenantContactEmail,
    required String ownerEmail,
    required String ownerUsername,
    required String ownerPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup-client'),
      headers: _headers,
      body: jsonEncode({
        'tenant_name': tenantName,
        'tenant_contact_email': tenantContactEmail,
        'owner_email': ownerEmail,
        'owner_username': ownerUsername,
        'owner_password': ownerPassword,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['access_token'] != null) _token = data['access_token'];
      return data;
    } else {
      throw Exception('Failed to signup client: ${response.body}');
    }
  }

  // Admin: add user (invite)
  static Future<Map<String, dynamic>> adminAddUser({
    required String email,
    required String username,
    required String roleName,
    required String tenantId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/add-user'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'username': username,
        'role_name': roleName,
        'tenant_id': tenantId,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add user: ${response.body}');
    }
  }
} 