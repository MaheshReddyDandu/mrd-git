import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../services/time_format_service.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:universal_io/io.dart' as universal_io;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:flutter/foundation.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<dynamic> _attendanceLogs = [];
  Map<String, dynamic>? _attendanceDetail;
  bool _isLoading = true;
  bool _isClocking = false;
  String? _error;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _currentSession;
  DateTime _selectedDate = DateTime.now();
  Timer? _clockTimer;
  DateTime _currentTime = DateTime.now();
  bool _isClockInEnabled = true;
  bool _isClockOutEnabled = false;
  String _sessionDuration = '00:00:00';
  Position? _currentPosition;
  bool _isLocationLoading = false;
  bool _showDetailedLogs = false;
  
  // New variables for enhanced functionality
  String _viewMode = 'week'; // 'day' or 'week'
  DateTime _weekStartDate = DateTime.now().subtract(const Duration(days: 6));
  DateTime _weekEndDate = DateTime.now();
  List<dynamic> _weekLogs = [];
  bool _isLoadingWeek = false;

  @override
  void initState() {
    super.initState();
    _startClock();
    _loadData();
    _checkLocationPermission();
    _loadWeekData();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
        _updateSessionDuration();
      });
    });
  }

  void _updateSessionDuration() {
    if (_currentSession != null && _currentSession!['is_clocked_in'] == true) {
      final clockInTime = DateTime.parse(_currentSession!['clock_in']);
      final duration = _currentTime.difference(clockInTime);
      final hours = duration.inHours.toString().padLeft(2, '0');
      final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
      setState(() {
        _sessionDuration = '$hours:$minutes:$seconds';
      });
    }
  }

  Future<void> _checkLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorSnackBar('Location permission is required for attendance marking');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        _showErrorSnackBar('Location permission is permanently denied. Please enable it in settings.');
      }
    } catch (e) {
      _showErrorSnackBar('Error checking location permission: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocationLoading = true);
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      setState(() {
        _currentPosition = position;
        _isLocationLoading = false;
      });
    } catch (e) {
      setState(() => _isLocationLoading = false);
      _showErrorSnackBar('Error getting location: $e');
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final user = await ApiService.getCurrentUser();
      final currentSession = await ApiService.getCurrentSession();
      final attendanceLogs = await ApiService.getMyAttendanceLogs(
        date: DateFormat('yyyy-MM-dd').format(_selectedDate)
      );
      
      // Load detailed attendance for today
      Map<String, dynamic>? attendanceDetail;
      try {
        attendanceDetail = await ApiService.getMyAttendanceDetail(
          DateFormat('yyyy-MM-dd').format(_selectedDate)
        );
      } catch (e) {
        // Detail might not exist for today
      }
      
      setState(() {
        _userData = user;
        _currentSession = currentSession;
        _attendanceLogs = attendanceLogs;
        _attendanceDetail = attendanceDetail;
        _isLoading = false;
        _updateButtonStates();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading data: $e');
    }
  }

  Future<void> _loadWeekData() async {
    setState(() => _isLoadingWeek = true);
    
    try {
      final weekLogs = await ApiService.getMyAttendanceLogsForRange(
        startDate: DateFormat('yyyy-MM-dd').format(_weekStartDate),
        endDate: DateFormat('yyyy-MM-dd').format(_weekEndDate),
      );
      
      setState(() {
        _weekLogs = weekLogs;
        _isLoadingWeek = false;
      });
    } catch (e) {
      setState(() => _isLoadingWeek = false);
      _showErrorSnackBar('Error loading week data: $e');
    }
  }

  void _updateButtonStates() {
    if (_currentSession != null) {
      setState(() {
        _isClockInEnabled = !_currentSession!['is_clocked_in'];
        _isClockOutEnabled = _currentSession!['is_clocked_in'];
      });
    }
  }

  Future<void> _clockInOut(String action) async {
    if (_isClocking) return;
    
    setState(() => _isClocking = true);
    
    try {
      // Get current location
      await _getCurrentLocation();
      
      if (_currentPosition == null) {
        _showErrorSnackBar('Unable to get location. Please try again.');
        return;
      }

      // Get device info
      final deviceInfo = kIsWeb ? 'Web' : '${universal_io.Platform.operatingSystem} ${universal_io.Platform.operatingSystemVersion}';
      
      // Get location address (reverse geocoding)
      String? locationAddress;
      try {
        final placemarks = await geocoding.placemarkFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          locationAddress = '${placemark.street}, ${placemark.locality}, ${placemark.country}';
        }
      } catch (e) {
        // Continue without address if reverse geocoding fails
      }

      await ApiService.clockInOut(
        action,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        locationAddress: locationAddress,
        deviceInfo: deviceInfo,
      );

      _showSuccessSnackBar('Clock ${action == 'clock_in' ? 'In' : 'Out'} successful!');
      await _loadData(); // Reload data to update session state
      await _loadWeekData(); // Reload week data
      
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() => _isClocking = false);
    }
  }

  Future<void> _loadAttendanceLogs() async {
    try {
      final logs = await ApiService.getMyAttendanceLogs(
        date: DateFormat('yyyy-MM-dd').format(_selectedDate)
      );
      
      // Load detailed attendance
      Map<String, dynamic>? attendanceDetail;
      try {
        attendanceDetail = await ApiService.getMyAttendanceDetail(
          DateFormat('yyyy-MM-dd').format(_selectedDate)
        );
      } catch (e) {
        // Detail might not exist for this date
      }
      
      setState(() {
        _attendanceLogs = logs;
        _attendanceDetail = attendanceDetail;
      });
    } catch (e) {
      _showErrorSnackBar('Error loading attendance logs: $e');
    }
  }

  void _showLocationOnMap(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps?q=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      _showErrorSnackBar('Could not open map');
    }
  }

  void _showRegularizationDialog(Map<String, dynamic> log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Regularization'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Request regularization for ${log['action'] == 'clock_in' ? 'Clock In' : 'Clock Out'}'),
            const SizedBox(height: 16),
            const Text('This will create a regularization request for approval.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitRegularizationRequest(log);
            },
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRegularizationRequest(Map<String, dynamic> log) async {
    try {
      await ApiService.submitRegularizationRequest(
        _userData!['tenant_id'],
        {
          'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
          'reason': 'Attendance regularization request',
          'requested_in': log['action'] == 'clock_in' ? log['timestamp'] : null,
          'requested_out': log['action'] == 'clock_out' ? log['timestamp'] : null,
        },
      );
      _showSuccessSnackBar('Regularization request submitted successfully!');
    } catch (e) {
      _showErrorSnackBar('Error submitting regularization request: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status?.toLowerCase()) {
      case 'on time':
        return Colors.green;
      case 'late':
        return Colors.orange;
      case 'very late':
        return Colors.red;
      case 'early':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status ?? 'Unknown',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Group logs by date for week view
  Map<String, List<dynamic>> _groupLogsByDate(List<dynamic> logs) {
    final grouped = <String, List<dynamic>>{};
    
    for (final log in logs) {
      final timestamp = DateTime.parse(log['timestamp']);
      final dateKey = DateFormat('yyyy-MM-dd').format(timestamp);
      
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(log);
    }
    
    // Sort logs within each date by timestamp
    for (final dateKey in grouped.keys) {
      grouped[dateKey]!.sort((a, b) {
        final timeA = DateTime.parse(a['timestamp']);
        final timeB = DateTime.parse(b['timestamp']);
        return timeA.compareTo(timeB);
      });
    }
    
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading attendance data...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Error: $_error', textAlign: TextAlign.center),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Time format toggle
          IconButton(
            onPressed: () async {
              await TimeFormatService.toggleTimeFormat();
              setState(() {}); // Rebuild to update time formats
            },
            icon: Icon(TimeFormatService.is24Hour ? Icons.access_time : Icons.schedule),
            tooltip: 'Toggle ${TimeFormatService.is24Hour ? '12-Hour' : '24-Hour'} Format',
          ),
          IconButton(
            onPressed: () {
              _loadData();
              _loadWeekData();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadData();
          await _loadWeekData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Live Clock Widget
              _buildLiveClockWidget(),
              
              const SizedBox(height: 24),
              
              // Clock In/Out Buttons
              _buildClockInOutWidget(),
              
              const SizedBox(height: 24),
              
              // Current Session Info
              if (_currentSession != null && _currentSession!['is_clocked_in'] == true)
                _buildCurrentSessionWidget(),
              
              const SizedBox(height: 24),
              
              // Today's Summary
              if (_attendanceDetail != null)
                _buildTodaySummaryWidget(),
              
              const SizedBox(height: 24),
              
              // View Mode Selector
              _buildViewModeSelector(),
              
              const SizedBox(height: 16),
              
              // Attendance Logs
              _buildAttendanceLogsWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveClockWidget() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.access_time,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(_currentTime),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              TimeFormatService.formatTime(_currentTime),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${TimeFormatService.formatDisplayName} Format',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClockInOutWidget() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Mark Attendance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isClockInEnabled && !_isClocking
                        ? () => _clockInOut('clock_in')
                        : null,
                    icon: const Icon(Icons.login),
                    label: const Text('Clock In'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isClockOutEnabled && !_isClocking
                        ? () => _clockInOut('clock_out')
                        : null,
                    icon: const Icon(Icons.logout),
                    label: const Text('Clock Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_isClocking) ...[
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Processing...'),
                ],
              ),
            ],
            if (_isLocationLoading) ...[
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Getting location...', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSessionWidget() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Current Session ${_currentSession!['session_number'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Clock In Time:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      TimeFormatService.formatDateTime(DateTime.parse(_currentSession!['clock_in'])),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Duration:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      _sessionDuration,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySummaryWidget() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Total Hours',
                  '${_attendanceDetail!['total_work_hours']?.toStringAsFixed(2) ?? '0.00'}',
                  Icons.access_time,
                ),
                _buildSummaryItem(
                  'Sessions',
                  '${_attendanceDetail!['total_sessions'] ?? 0}',
                  Icons.work,
                ),
                _buildSummaryItem(
                  'Status',
                  _attendanceDetail!['status'] ?? 'Unknown',
                  Icons.info,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildViewModeSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attendance Logs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _showDetailedLogs ? 'Detailed' : 'Simple',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Switch(
                      value: _showDetailedLogs,
                      onChanged: (value) {
                        setState(() {
                          _showDetailedLogs = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // View mode selector
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _viewMode = 'day';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _viewMode == 'day' 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey.shade200,
                      foregroundColor: _viewMode == 'day' 
                          ? Colors.white 
                          : Colors.black,
                    ),
                    child: const Text('Today'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _viewMode = 'week';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _viewMode == 'week' 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey.shade200,
                      foregroundColor: _viewMode == 'week' 
                          ? Colors.white 
                          : Colors.black,
                    ),
                    child: const Text('This Week'),
                  ),
                ),
              ],
            ),
            if (_viewMode == 'day') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _selectedDate = date);
                          await _loadAttendanceLogs();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('MMM dd, yyyy').format(_selectedDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.calendar_today, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _loadAttendanceLogs,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh logs',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceLogsWidget() {
    if (_viewMode == 'week') {
      return _buildWeekLogsWidget();
    } else {
      return _buildDayLogsWidget();
    }
  }

  Widget _buildDayLogsWidget() {
    if (_attendanceDetail == null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.history, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No attendance data for this date',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final sessions = _attendanceDetail!['sessions'] as List<dynamic>;
    final attendanceSummary = _attendanceDetail!['attendance'];

    if (sessions.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('No sessions recorded for this day.'),
          ),
        ),
      );
    }
    
    return Column(
      children: [
        _buildDaySummaryCard(attendanceSummary),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sessions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final session = sessions[index];
            return _buildSessionItem(session);
          },
        ),
      ],
    );
  }

  Widget _buildDaySummaryCard(Map<String, dynamic> summary) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem(
              'Total Hours',
              '${(summary['total_work_hours'] ?? 0.0).toStringAsFixed(2)}h',
              Icons.timelapse
            ),
            _buildSummaryItem(
              'Status',
              summary['status'] ?? 'N/A',
              Icons.check_circle_outline
            ),
          ],
        ),
      )
    );
  }

  Widget _buildSessionItem(Map<String, dynamic> session) {
    final clockIn = DateTime.parse(session['clock_in']).toLocal();
    final clockOut = session['clock_out'] != null ? DateTime.parse(session['clock_out']).toLocal() : null;
    final workHours = session['work_hours'] ?? 0.0;
    
    // Determine work mode from logs (assuming first log has it)
    String workMode = 'N/A';
    if (_attendanceLogs.isNotEmpty) {
      final firstLogForSession = _attendanceLogs.firstWhere(
        (log) => log['session_id'] == session['id'],
        orElse: () => null,
      );
      if (firstLogForSession != null) {
        workMode = firstLogForSession['work_mode'] ?? 'N/A';
      }
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Session ${session['session_number']}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    workMode,
                    style: TextStyle(color: Colors.blue.shade800, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                _buildLogDetail('Clock In', TimeFormatService.formatTime(clockIn), Icons.login, Colors.green),
                const Spacer(),
                if (clockOut != null)
                  _buildLogDetail('Clock Out', TimeFormatService.formatTime(clockOut), Icons.logout, Colors.red),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  const Text('Gross Hours', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                    '${workHours.toStringAsFixed(2)}h',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogDetail(String title, String time, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(time, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekLogsWidget() {
    if (_isLoadingWeek) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_weekLogs.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.history, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No attendance logs for this week',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final groupedLogs = _groupLogsByDate(_weekLogs);
    final sortedDates = groupedLogs.keys.toList()..sort((a,b) => b.compareTo(a)); // Sort descending

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedDates.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final logs = groupedLogs[date]!;
        final dateTime = DateTime.parse(date);

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            title: Row(
              children: [
                Text(
                  DateFormat('EEEE, MMM dd').format(dateTime),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${logs.length} entries',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
            children: logs.map((log) => _buildLogItem(log)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildLogItem(Map<String, dynamic> log) {
    final timestamp = DateTime.parse(log['timestamp']);
    final action = log['action'];
    final hasLocation = log['latitude'] != null && log['longitude'] != null;
    
    if (_showDetailedLogs) {
      return _buildDetailedLogItem(log);
    } else {
      return _buildSimpleLogItem(log);
    }
  }

  Widget _buildSimpleLogItem(Map<String, dynamic> log) {
    final timestamp = DateTime.parse(log['timestamp']);
    final action = log['action'];
    final hasLocation = log['latitude'] != null && log['longitude'] != null;
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: action == 'clock_in' ? Colors.green : Colors.red,
        child: Icon(
          action == 'clock_in' ? Icons.login : Icons.logout,
          color: Colors.white,
        ),
      ),
      title: Text(
        action == 'clock_in' ? 'Clock In' : 'Clock Out',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(TimeFormatService.formatTime(timestamp)),
          if (log['location_address'] != null)
            Text(
              log['location_address'],
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasLocation)
            IconButton(
              onPressed: () => _showLocationOnMap(
                log['latitude'].toDouble(),
                log['longitude'].toDouble(),
              ),
              icon: const Icon(Icons.map),
              tooltip: 'View on map',
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'regularize') {
                _showRegularizationDialog(log);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'regularize',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Request Regularization'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedLogItem(Map<String, dynamic> log) {
    final timestamp = DateTime.parse(log['timestamp']);
    final action = log['action'];
    final hasLocation = log['latitude'] != null && log['longitude'] != null;
    
    return ExpansionTile(
      leading: CircleAvatar(
        backgroundColor: action == 'clock_in' ? Colors.green : Colors.red,
        child: Icon(
          action == 'clock_in' ? Icons.login : Icons.logout,
          color: Colors.white,
        ),
      ),
      title: Row(
        children: [
          Text(
            action == 'clock_in' ? 'Clock In' : 'Clock Out',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          if (log['status'] != null) _buildStatusBadge(log['status']),
        ],
      ),
      subtitle: Text(TimeFormatService.formatTime(timestamp)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasLocation)
            IconButton(
              onPressed: () => _showLocationOnMap(
                log['latitude'].toDouble(),
                log['longitude'].toDouble(),
              ),
              icon: const Icon(Icons.map),
              tooltip: 'View on map',
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'regularize') {
                _showRegularizationDialog(log);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'regularize',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Request Regularization'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (log['shift_timing'] != null) ...[
                _buildDetailRow('Shift Timing', log['shift_timing']),
              ],
              if (log['shift_type'] != null) ...[
                _buildDetailRow('Shift Type', log['shift_type']),
              ],
              if (log['work_mode'] != null) ...[
                _buildDetailRow('Work Mode', log['work_mode']),
              ],
              if (log['policy_applied'] != null) ...[
                _buildDetailRow('Policy Applied', log['policy_applied']),
              ],
              if (log['device_info'] != null) ...[
                _buildDetailRow('Device', log['device_info']),
              ],
              if (log['location_address'] != null) ...[
                _buildDetailRow('Location', log['location_address']),
              ],
              if (hasLocation) ...[
                _buildDetailRow('Coordinates', '${log['latitude']}, ${log['longitude']}'),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
} 