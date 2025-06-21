import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, dynamic>? _stats;
  List<dynamic> _summary = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = await ApiService.getCurrentUser();
      final tenantId = user['tenant_id'];
      final stats = await ApiService.getDashboardStats(tenantId);
      final summary = await ApiService.getAttendanceSummary(tenantId);
      setState(() {
        _stats = stats;
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics & Reporting')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_stats != null)
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildStatCard('Users', _stats!['total_users']?.toString() ?? '0', Icons.people),
                  _buildStatCard('Departments', _stats!['total_departments']?.toString() ?? '0', Icons.apartment),
                  _buildStatCard('Branches', _stats!['total_branches']?.toString() ?? '0', Icons.location_city),
                  _buildStatCard('Attendance Records', _stats!['total_attendance_records']?.toString() ?? '0', Icons.access_time),
                ],
              ),
            const SizedBox(height: 24),
            Text('Attendance Summary', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Expanded(
              child: _summary.isEmpty
                  ? const Center(child: Text('No attendance summary available.'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Present')),
                          DataColumn(label: Text('Late')),
                          DataColumn(label: Text('Absent')),
                          DataColumn(label: Text('Total')),
                        ],
                        rows: _summary.map<DataRow>((row) {
                          return DataRow(cells: [
                            DataCell(Text(row['date'] != null ? DateFormat('yyyy-MM-dd').format(DateTime.parse(row['date'])) : '-')),
                            DataCell(Text(row['present']?.toString() ?? '0')),
                            DataCell(Text(row['late']?.toString() ?? '0')),
                            DataCell(Text(row['absent']?.toString() ?? '0')),
                            DataCell(Text(row['total_records']?.toString() ?? '0')),
                          ]);
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Container(
        width: 180,
        height: 100,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(value, style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 