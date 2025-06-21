import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<dynamic> _attendanceRecords = [];
  bool _isLoading = true;
  String? _error;
  bool _isClocking = false;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _summary;

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
      final attendance = await ApiService.listAttendance(tenantId);
      final summary = await ApiService.getAttendanceSummary(tenantId);
      setState(() {
        _userData = user;
        _attendanceRecords = attendance;
        _summary = summary.isNotEmpty ? summary.last : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _clockInOut(String type) async {
    setState(() => _isClocking = true);
    try {
      final user = _userData ?? await ApiService.getCurrentUser();
      final tenantId = user['tenant_id'];
      final userId = user['id'];
      final now = DateTime.now();
      final attendance = {
        'tenant_id': tenantId,
        'user_id': userId,
        'date': now.toIso8601String(),
        'status': type == 'in' ? 'Present' : 'Present',
        'clock_in': type == 'in' ? now.toIso8601String() : null,
        'clock_out': type == 'out' ? now.toIso8601String() : null,
        'location': '', // Optionally add location
      };
      await ApiService.createAttendance(tenantId, attendance);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Clock ${type == 'in' ? 'In' : 'Out'} successful!')),
        );
        _loadData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isClocking = false);
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
    final isUser = (_userData?['roles'] as List?)?.any((r) => r['name'] == 'user') ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_summary != null)
              Card(
                child: ListTile(
                  title: const Text('Today\'s Attendance Summary'),
                  subtitle: Text('Present: ${_summary?['present'] ?? 0}, Late: ${_summary?['late'] ?? 0}, Absent: ${_summary?['absent'] ?? 0}'),
                ),
              ),
            if (isUser)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isClocking ? null : () => _clockInOut('in'),
                    icon: const Icon(Icons.login),
                    label: const Text('Clock In'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isClocking ? null : () => _clockInOut('out'),
                    icon: const Icon(Icons.logout),
                    label: const Text('Clock Out'),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Expanded(
              child: _attendanceRecords.isEmpty
                  ? const Center(child: Text('No attendance records found.'))
                  : ListView.separated(
                      itemCount: _attendanceRecords.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final rec = _attendanceRecords[i];
                        return ListTile(
                          leading: Icon(
                            rec['status'] == 'Present'
                                ? Icons.check_circle
                                : rec['status'] == 'Late'
                                    ? Icons.access_time
                                    : Icons.cancel,
                            color: rec['status'] == 'Present'
                                ? Colors.green
                                : rec['status'] == 'Late'
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                          title: Text(DateFormat('yyyy-MM-dd').format(DateTime.parse(rec['date']))),
                          subtitle: Text('In: ${rec['clock_in'] ?? '-'}  Out: ${rec['clock_out'] ?? '-'}'),
                          trailing: Text(rec['status'] ?? ''),
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