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

  static Future<List<dynamic>> listUsers(String tenantId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tenants/$tenantId/users'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to list users: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createUser(String tenantId, Map<String, dynamic> user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tenants/$tenantId/users'),
      headers: _headers,
      body: jsonEncode(user),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create user: ${response.body}');
    }
  }

  // Department endpoints
  static Future<List<dynamic>> listDepartments(String tenantId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/departments'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to list departments: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createDepartment(String tenantId, Map<String, dynamic> department) async {
    final response = await http.post(
      Uri.parse('$baseUrl/departments'),
      headers: _headers,
      body: jsonEncode(department),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create department: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateDepartment(String tenantId, String departmentId, Map<String, dynamic> department) async {
    final response = await http.put(
      Uri.parse('$baseUrl/departments/$departmentId'),
      headers: _headers,
      body: jsonEncode(department),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update department: ${response.body}');
    }
  }

  static Future<void> deleteDepartment(String tenantId, String departmentId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/departments/$departmentId'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete department: ${response.body}');
    }
  }

  // Branch endpoints
  static Future<List<dynamic>> listBranches(String tenantId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/branches'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to list branches: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createBranch(String tenantId, Map<String, dynamic> branch) async {
    final response = await http.post(
      Uri.parse('$baseUrl/branches'),
      headers: _headers,
      body: jsonEncode(branch),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create branch: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateBranch(String tenantId, String branchId, Map<String, dynamic> branch) async {
    final response = await http.put(
      Uri.parse('$baseUrl/branches/$branchId'),
      headers: _headers,
      body: jsonEncode(branch),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update branch: ${response.body}');
    }
  }

  static Future<void> deleteBranch(String tenantId, String branchId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/branches/$branchId'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete branch: ${response.body}');
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

  static Future<List<dynamic>> getEffectivePolicy(String tenantId, String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tenants/$tenantId/users/$userId/effective-policy'),
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
    required String roleId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/add-user'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'username': username,
        'role_id': roleId,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add user: ${response.body}');
    }
  }

  static Future<List<dynamic>> getRoles() async {
    final response = await http.get(
      Uri.parse('$baseUrl/roles'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch roles: ${response.body}');
    }
  }

  static Future<void> adminAssignRole(String userId, String roleId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/assign-role'),
      headers: _headers,
      body: jsonEncode({'user_id': userId, 'role_id': roleId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to assign role: ${response.body}');
    }
  }

  static Future<List<dynamic>> getAuditLogs({int skip = 0, int limit = 100}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/audit-logs?skip=$skip&limit=$limit'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch audit logs: ${response.body}');
    }
  }

  static Future<List<dynamic>> getAttendanceReport(String tenantId, {
    String? startDate,
    String? endDate,
    String? departmentId,
    String? employeeId,
    String? status,
  }) async {
    final params = <String, String>{};
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;
    if (departmentId != null) params['department_id'] = departmentId;
    if (employeeId != null) params['employee_id'] = employeeId;
    if (status != null) params['status'] = status;
    final uri = Uri.parse('$baseUrl/tenants/$tenantId/attendance-report').replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch attendance report: \\${response.body}');
    }
  }

  static Future<List<dynamic>> listNotifications(String tenantId, {bool onlyUnread = false}) async {
    final params = <String, String>{};
    if (onlyUnread) params['only_unread'] = 'true';
    final uri = Uri.parse('$baseUrl/tenants/$tenantId/notifications').replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch notifications: \\${response.body}');
    }
  }

  static Future<Map<String, dynamic>> markNotificationRead(String tenantId, String notificationId) async {
    final uri = Uri.parse('$baseUrl/tenants/$tenantId/notifications/$notificationId/read');
    final response = await http.post(uri, headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to mark notification as read: \\${response.body}');
    }
  }

  static Future<Map<String, dynamic>> adminUpdateTenant(String tenantId, Map<String, dynamic> tenantData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/tenants/$tenantId'),
      headers: _headers,
      body: jsonEncode(tenantData),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update tenant: ${response.body}');
    }
  }

  static Future<void> adminDeleteTenant(String tenantId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/tenants/$tenantId'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete tenant: ${response.body}');
    }
  }

  // Client CRUD endpoints
  static Future<List<dynamic>> listClients() async {
    final response = await http.get(
      Uri.parse('$baseUrl/clients'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to list clients: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createClient(Map<String, dynamic> client) async {
    final response = await http.post(
      Uri.parse('$baseUrl/clients'),
      headers: _headers,
      body: jsonEncode(client),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create client: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateClient(String clientId, Map<String, dynamic> client) async {
    final response = await http.put(
      Uri.parse('$baseUrl/clients/$clientId'),
      headers: _headers,
      body: jsonEncode(client),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update client: ${response.body}');
    }
  }

  static Future<void> deleteClient(String clientId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/clients/$clientId'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete client: ${response.body}');
    }
  }

  // Project CRUD endpoints
  static Future<List<dynamic>> listProjects() async {
    final response = await http.get(
      Uri.parse('$baseUrl/projects'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to list projects: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createProject(Map<String, dynamic> project) async {
    final response = await http.post(
      Uri.parse('$baseUrl/projects'),
      headers: _headers,
      body: jsonEncode(project),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create project: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateProject(String projectId, Map<String, dynamic> project) async {
    final response = await http.put(
      Uri.parse('$baseUrl/projects/$projectId'),
      headers: _headers,
      body: jsonEncode(project),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update project: ${response.body}');
    }
  }

  static Future<void> deleteProject(String projectId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/projects/$projectId'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete project: ${response.body}');
    }
  }
} 