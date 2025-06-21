import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedDepartmentId;
  String? _selectedUserId;
  String? _selectedStatus;
  List<dynamic> _departments = [];
  List<dynamic> _users = [];
  List<dynamic> _results = [];
  bool _isLoading = false;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final userData = await ApiService.getCurrentUser();
    final departments = await ApiService.listDepartments(userData['tenant_id']);
    final users = await ApiService.listUsers(userData['tenant_id']);
    setState(() {
      _userData = userData;
      _departments = departments;
      _users = users;
    });
  }

  Future<void> _fetchReport() async {
    setState(() => _isLoading = true);
    try {
      final results = await ApiService.getAttendanceReport(
        _userData!['tenant_id'],
        startDate: _startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : null,
        endDate: _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : null,
        departmentId: _selectedDepartmentId,
        employeeId: _selectedUserId,
        status: _selectedStatus,
      );
      setState(() => _results = results);
    } catch (e) {
      setState(() => _results = []);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch report: $e')));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _exportCsv() async {
    final params = <String, String>{'format': 'csv'};
    if (_startDate != null) params['start_date'] = DateFormat('yyyy-MM-dd').format(_startDate!);
    if (_endDate != null) params['end_date'] = DateFormat('yyyy-MM-dd').format(_endDate!);
    if (_selectedDepartmentId != null) params['department_id'] = _selectedDepartmentId!;
    if (_selectedUserId != null) params['employee_id'] = _selectedUserId!;
    if (_selectedStatus != null) params['status'] = _selectedStatus!;
    final uri = Uri.parse('${ApiService.baseUrl}/tenants/${_userData!['tenant_id']}/attendance-report').replace(queryParameters: params);
    if (kIsWeb) {
      // For web, open the CSV in a new tab
      html.window.open(uri.toString(), '_blank');
    } else {
      // For mobile/desktop, download and open (implementation may vary)
      // TODO: Implement file download for mobile/desktop
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV export is only supported on web for now.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportCsv,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: InputDatePickerFormField(
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDate: _startDate ?? DateTime.now(),
                    onDateSubmitted: (date) => setState(() => _startDate = date),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InputDatePickerFormField(
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDate: _endDate ?? DateTime.now(),
                    onDateSubmitted: (date) => setState(() => _endDate = date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedDepartmentId,
              items: _departments.map<DropdownMenuItem<String>>((dept) {
                return DropdownMenuItem<String>(
                  value: dept['id'],
                  child: Text(dept['name']),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedDepartmentId = value),
              decoration: const InputDecoration(labelText: 'Department'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedUserId,
              items: _users.map<DropdownMenuItem<String>>((user) {
                return DropdownMenuItem<String>(
                  value: user['id'],
                  child: Text(user['name']),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedUserId = value),
              decoration: const InputDecoration(labelText: 'User'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              items: const [
                DropdownMenuItem(value: null, child: Text('All Statuses')),
                DropdownMenuItem(value: 'Present', child: Text('Present')),
                DropdownMenuItem(value: 'Late', child: Text('Late')),
                DropdownMenuItem(value: 'Absent', child: Text('Absent')),
              ],
              onChanged: (value) => setState(() => _selectedStatus = value),
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _fetchReport,
              child: const Text('Generate Report'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final row = _results[index];
                        return ListTile(
                          title: Text('${row['employee']} - ${row['date']}'),
                          subtitle: Text('Dept: ${row['department'] ?? '-'} | Status: ${row['status'] ?? '-'}'),
                          trailing: Text(row['clock_in'] != null ? 'In: ${row['clock_in']}' : ''),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
} 