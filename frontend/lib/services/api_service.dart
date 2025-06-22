import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000';
  static const String _tokenKey = 'auth_token';
  static String? _token;

  static Future<void> initialize() async {
    // Load token from shared preferences on app start
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    print('Loaded token from storage: ${_token != null ? _token!.substring(0, _token!.length > 10 ? 10 : _token!.length) + '...' : 'null'}');
  }

  static Future<void> setToken(String token) async {
    print('Setting token: ${token.substring(0, token.length > 10 ? 10 : token.length)}...');
    _token = token;
    
    // Save token to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    print('Token saved to storage');
  }

  static Future<void> clearToken() async {
    print('Clearing token');
    _token = null;
    
    // Remove token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    print('Token removed from storage');
  }

  static bool isAuthenticated() {
    return _token != null;
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
      await setToken(data['access_token']);
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

  static Future<Map<String, dynamic>> clockInOut(String action, {
    double? latitude,
    double? longitude,
    String? locationAddress,
    String? deviceInfo,
  }) async {
    final tz = await getUserTimezone();
    final response = await http.post(
      Uri.parse('$baseUrl/attendance/clock-in-out?timezone=$tz'),
      headers: _headers,
      body: jsonEncode({
        'action': action,
        'latitude': latitude,
        'longitude': longitude,
        'location_address': locationAddress,
        'device_info': deviceInfo,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to clock ${action}: ${response.body}');
    }
  }

  static Future<List<dynamic>> getMyAttendanceRecords({
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    final response = await http.get(
      Uri.parse('$baseUrl/attendance/my-records').replace(queryParameters: queryParams),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get attendance records: ${response.body}');
    }
  }

  static Future<List<dynamic>> getMyAttendanceLogs({String? date}) async {
    final tz = await getUserTimezone();
    final queryParams = <String, String>{'timezone': tz};
    if (date != null) queryParams['date'] = date;

    final response = await http.get(
      Uri.parse('$baseUrl/attendance/my-logs').replace(queryParameters: queryParams),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get attendance logs: ${response.body}');
    }
  }

  static Future<List<dynamic>> getMyAttendanceLogsForRange({
    String? startDate,
    String? endDate,
  }) async {
    final tz = await getUserTimezone();
    final queryParams = <String, String>{'timezone': tz};
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    final response = await http.get(
      Uri.parse('$baseUrl/attendance/my-logs').replace(queryParameters: queryParams),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get attendance logs: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getCurrentSession() async {
    final response = await http.get(
      Uri.parse('$baseUrl/attendance/current-session'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get current session: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getMyAttendanceDetail(String date) async {
    final response = await http.get(
      Uri.parse('$baseUrl/attendance/my-detail/$date'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get attendance detail: ${response.body}');
    }
  }

  // Policy endpoints
  static Future<List<dynamic>> listPolicies({String? policyType}) async {
    final queryParams = <String, String>{};
    if (policyType != null) queryParams['policy_type'] = policyType;
    final response = await http.get(
      Uri.parse('$baseUrl/policies').replace(queryParameters: queryParams),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to list policies: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createPolicy(Map<String, dynamic> policy) async {
    final response = await http.post(
      Uri.parse('$baseUrl/policies'),
      headers: _headers,
      body: jsonEncode(policy),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create policy: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updatePolicy(String policyId, Map<String, dynamic> policy) async {
    final response = await http.put(
      Uri.parse('$baseUrl/policies/$policyId'),
      headers: _headers,
      body: jsonEncode(policy),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update policy: ${response.body}');
    }
  }

  static Future<void> deletePolicy(String policyId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/policies/$policyId'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete policy: ${response.body}');
    }
  }

  // Calendar and Holiday endpoints
  static Future<List<dynamic>> listHolidays({int? year}) async {
    final queryParams = <String, String>{};
    if (year != null) queryParams['year'] = year.toString();

    final response = await http.get(
      Uri.parse('$baseUrl/holidays').replace(queryParameters: queryParams),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to list holidays: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createHoliday(Map<String, dynamic> holiday) async {
    final response = await http.post(
      Uri.parse('$baseUrl/holidays'),
      headers: _headers,
      body: jsonEncode(holiday),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create holiday: ${response.body}');
    }
  }

  static Future<List<dynamic>> listWeekOffs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/week-offs'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to list week offs: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createWeekOff(Map<String, dynamic> weekOff) async {
    final response = await http.post(
      Uri.parse('$baseUrl/week-offs'),
      headers: _headers,
      body: jsonEncode(weekOff),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create week off: ${response.body}');
    }
  }

  // Leave Management endpoints
  static Future<List<dynamic>> listLeaveTypes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/leave-types'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to list leave types: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createLeaveType(Map<String, dynamic> leaveType) async {
    final response = await http.post(
      Uri.parse('$baseUrl/leave-types'),
      headers: _headers,
      body: jsonEncode(leaveType),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create leave type: ${response.body}');
    }
  }

  static Future<List<dynamic>> listLeaveRequests({String? status}) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;

    final response = await http.get(
      Uri.parse('$baseUrl/leave-requests').replace(queryParameters: queryParams),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to list leave requests: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createLeaveRequest(Map<String, dynamic> leaveRequest) async {
    final response = await http.post(
      Uri.parse('$baseUrl/leave-requests'),
      headers: _headers,
      body: jsonEncode(leaveRequest),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create leave request: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> approveLeaveRequest(String requestId, String status, String approverId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/leave-requests/$requestId/approve'),
      headers: _headers,
      body: jsonEncode({
        'status': status,
        'approver_id': approverId,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to approve leave request: ${response.body}');
    }
  }

  // Policy Assignment endpoints
  static Future<Map<String, dynamic>> assignPolicy(Map<String, dynamic> assignment) async {
    final response = await http.post(
      Uri.parse('$baseUrl/policy-assignments'),
      headers: _headers,
      body: jsonEncode(assignment),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to assign policy: ${response.body}');
    }
  }

  static Future<List<dynamic>> getUserEffectivePolicies(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/effective-policies'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user effective policies: ${response.body}');
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

  // Client endpoints
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

  // Project endpoints
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

  // Legacy attendance endpoints (for backward compatibility)
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

  static Future<List<dynamic>> getAttendanceSummary(String tenantId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tenants/$tenantId/attendance-summary'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get attendance summary: ${response.body}');
    }
  }

  // Role endpoints
  static Future<List<dynamic>> listRoles() async {
    final response = await http.get(
      Uri.parse('$baseUrl/roles'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to list roles: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createRole(Map<String, dynamic> role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/roles'),
      headers: _headers,
      body: jsonEncode(role),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create role: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateRole(String roleId, Map<String, dynamic> role) async {
    final response = await http.put(
      Uri.parse('$baseUrl/roles/$roleId'),
      headers: _headers,
      body: jsonEncode(role),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update role: ${response.body}');
    }
  }

  static Future<void> deleteRole(String roleId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/roles/$roleId'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete role: ${response.body}');
    }
  }

  // User management endpoints
  static Future<List<dynamic>> getUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get users: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: _headers,
      body: jsonEncode(user),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  static Future<void> deleteUser(String userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$userId'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: ${response.body}');
    }
  }

  // Admin user management
  static Future<Map<String, dynamic>> addUserByAdmin(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/add-user'),
      headers: _headers,
      body: jsonEncode(userData),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add user: ${response.body}');
    }
  }

  // Password management
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: _headers,
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to process forgot password: ${response.body}');
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

  // Client signup
  static Future<Map<String, dynamic>> signupClient(Map<String, dynamic> signupData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup-client'),
      headers: _headers,
      body: jsonEncode(signupData),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['access_token'];
      return data;
    } else {
      throw Exception('Failed to signup client: ${response.body}');
    }
  }

  // Admin endpoints
  static Future<List<dynamic>> getRoles() async {
    final response = await http.get(
      Uri.parse('$baseUrl/roles'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get roles: ${response.body}');
    }
  }

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

  static Future<Map<String, dynamic>> adminUpdateTenant(String tenantId, Map<String, dynamic> tenant) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/tenants/$tenantId'),
      headers: _headers,
      body: jsonEncode(tenant),
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

  static Future<Map<String, dynamic>> adminAddUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/add-user'),
      headers: _headers,
      body: jsonEncode(userData),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add user: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> adminAssignRole(String userId, String roleId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/assign-role'),
      headers: _headers,
      body: jsonEncode({
        'user_id': userId,
        'role_id': roleId,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to assign role: ${response.body}');
    }
  }

  static Future<List<dynamic>> getAuditLogs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/audit-logs'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get audit logs: ${response.body}');
    }
  }

  static Future<List<dynamic>> getAttendanceReport(String tenantId, {String? startDate, String? endDate}) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    final response = await http.get(
      Uri.parse('$baseUrl/tenants/$tenantId/attendance-summary').replace(queryParameters: queryParams),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get attendance report: ${response.body}');
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

  static Future<Map<String, dynamic>> submitRegularizationRequest(String tenantId, Map<String, dynamic> request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tenants/$tenantId/regularization-requests'),
      headers: _headers,
      body: jsonEncode(request),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to submit regularization request: ${response.body}');
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
} 

