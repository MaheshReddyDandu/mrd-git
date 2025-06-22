import 'package:flutter/material.dart';
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
  bool _is24HourFormat = false;
  String _searchQuery = '';
  DateTime? _fromDate;
  DateTime? _toDate;
  List<dynamic> _weekLogs = [];
  bool _isLoadingWeek = false;
  List<dynamic> _filteredLogs = [];
  Map<String, bool> _expandedDates = {};
  String? _weekDataError;

  @override
  void initState() {
    super.initState();
    _startClock();
    _loadData();
    _checkLocationPermission();
    _loadRecentData();
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

  void _toggleTimeFormat() {
    setState(() => _is24HourFormat = !_is24HourFormat);
    TimeFormatService.set24HourFormat(_is24HourFormat);
  }

  void _updateSessionDuration() {
    if (_currentSession?['is_clocked_in'] == true && _currentSession?['clock_in'] != null) {
      final clockInTime = DateTime.parse(_currentSession!['clock_in']);
      final duration = _currentTime.difference(clockInTime);
      setState(() {
        _sessionDuration = '${duration.inHours.toString().padLeft(2, '0')}:'
            '${(duration.inMinutes % 60).toString().padLeft(2, '0')}:'
            '${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _checkLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permission required', Colors.red);
        }
      } else if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permission permanently denied', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error checking location permission: $e', Colors.red);
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
      _showSnackBar('Error getting location: $e', Colors.red);
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = await ApiService.getCurrentUser();
      final currentSession = await ApiService.getCurrentSession().catchError((e) => null);
      final attendanceLogs = await ApiService.getMyAttendanceLogs(
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      );
      final attendanceDetail = await ApiService.getMyAttendanceDetail(
        DateFormat('yyyy-MM-dd').format(_selectedDate),
      ).catchError((e) => null);

      setState(() {
        _userData = user;
        _currentSession = currentSession;
        _attendanceLogs = attendanceLogs;
        _attendanceDetail = attendanceDetail;
        _isLoading = false;
        _error = null;
        _updateButtonStates();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      _showSnackBar('Error loading data: $e', Colors.red);
    }
  }

  Future<void> _loadRecentData() async {
    setState(() {
      _isLoadingWeek = true;
      _weekDataError = null;
    });
    try {
      final startDate = DateTime.now().subtract(const Duration(days: 30));
      final endDate = DateTime.now();
      final weekLogs = await ApiService.getMyAttendanceLogsForRange(
        startDate: DateFormat('yyyy-MM-dd').format(startDate),
        endDate: DateFormat('yyyy-MM-dd').format(endDate),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('API request timed out');
      });

      if (kDebugMode) {
        print('Loaded ${weekLogs.length} attendance logs for range ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');
      }

      setState(() {
        _weekLogs = weekLogs;
        _filteredLogs = _applyFilters(weekLogs);
        _expandedDates = {
          for (var date in _groupLogsByDate(weekLogs).keys) date: date == DateFormat('yyyy-MM-dd').format(DateTime.now())
        };
        _isLoadingWeek = false;
        _weekDataError = null;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading recent data: $e');
      }
      setState(() {
        _isLoadingWeek = false;
        _weekDataError = e.toString();
      });
      _showSnackBar('Failed to load attendance records: $e', Colors.red);
    }
  }

  void _updateButtonStates() {
    setState(() {
      _isClockInEnabled = _currentSession == null || !_currentSession!['is_clocked_in'];
      _isClockOutEnabled = _currentSession != null && _currentSession!['is_clocked_in'];
    });
  }

  Future<void> _clockInOut(String action) async {
    if (_isClocking) return;
    setState(() => _isClocking = true);
    try {
      await _getCurrentLocation();
      if (_currentPosition == null) {
        _showSnackBar('Unable to get location', Colors.red);
        return;
      }

      final deviceInfo = kIsWeb ? 'Web' : universal_io.Platform.operatingSystem;
      String? locationAddress;
      if (!kIsWeb) {
        try {
          final placemarks = await geocoding.placemarkFromCoordinates(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          );
          if (placemarks.isNotEmpty) {
            final placemark = placemarks.first;
            locationAddress = '${placemark.street}, ${placemark.locality}, ${placemark.country}';
          }
        } catch (e) {}
      }

      await ApiService.clockInOut(
        action,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        locationAddress: locationAddress,
        deviceInfo: deviceInfo,
      );

      _showSnackBar('Clock ${action == 'clock_in' ? 'In' : 'Out'} successful', Colors.green);
      await Future.wait([_loadData(), _loadRecentData()]);
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      setState(() => _isClocking = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getStatusColor(String? status) {
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

  Widget _buildStatusBadge(String? status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status ?? 'Unknown',
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Map<String, List<dynamic>> _groupLogsByDate(List<dynamic> logs) {
    final grouped = <String, List<dynamic>>{};
    for (final log in logs) {
      final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.parse(log['timestamp']));
      grouped.putIfAbsent(dateKey, () => []).add(log);
    }
    for (final dateKey in grouped.keys) {
      grouped[dateKey]!.sort((a, b) => DateTime.parse(a['timestamp']).compareTo(DateTime.parse(b['timestamp'])));
    }
    return grouped;
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _fromDate != null && _toDate != null
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : DateTimeRange(start: DateTime.now().subtract(const Duration(days: 7)), end: DateTime.now()),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.blue.shade600,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
      await _loadRecentData();
    }
  }

  List<dynamic> _applyFilters(List<dynamic> logs) {
    if (_searchQuery.isEmpty) return logs;
    final query = _searchQuery.toLowerCase().trim();
    return logs.where((log) {
      final timestamp = DateTime.parse(log['timestamp']);
      final dateStr = DateFormat('yyyy-MM-dd').format(timestamp);
      final yearStr = timestamp.year.toString();
      final timeStr = (_is24HourFormat
          ? TimeFormatService.formatTime24Hour(timestamp)
          : TimeFormatService.formatTime(timestamp))
          .toLowerCase();
      final dayName = DateFormat('EEEE').format(timestamp).toLowerCase();
      final monthName = DateFormat('MMMM').format(timestamp).toLowerCase();
      final shortDate = DateFormat('MMM d').format(timestamp).toLowerCase();
      final action = log['action']?.toString().toLowerCase() ?? '';
      final location = log['location_address']?.toString().toLowerCase() ?? '';

      bool matchesTime = timeStr.contains(query) ||
          RegExp(r'^\d{1,2}:\d{2}\s*(am|pm)?$', caseSensitive: false).hasMatch(query) &&
              timeStr.contains(query.replaceAll(RegExp(r'\s*(am|pm)$', caseSensitive: false), '')) ||
          RegExp(r'^\d{1,2}:\d{2}$').hasMatch(query) && timeStr.contains(query);

      bool matchesDate = dateStr.contains(query) ||
          shortDate.contains(query) ||
          RegExp(r'^\d{4}-\d{1,2}-\d{1,2}$').hasMatch(query) && dateStr.contains(query) ||
          RegExp(r'^\d{1,2}/\d{1,2}/\d{4}$').hasMatch(query) && dateStr.contains(query.replaceAll('/', '-'));

      return matchesDate ||
          yearStr.contains(query) ||
          matchesTime ||
          dayName.contains(query) ||
          monthName.contains(query) ||
          action.contains(query) ||
          location.contains(query);
    }).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredLogs = _applyFilters(_weekLogs);
      if (query.isNotEmpty) {
        _expandedDates = {for (var date in _groupLogsByDate(_filteredLogs).keys) date: true};
      } else {
        _expandedDates = {
          for (var date in _groupLogsByDate(_filteredLogs).keys) date: date == DateFormat('yyyy-MM-dd').format(DateTime.now())
        };
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _fromDate = null;
      _toDate = null;
      _filteredLogs = _weekLogs;
      _expandedDates = {
        for (var date in _groupLogsByDate(_filteredLogs).keys) date: date == DateFormat('yyyy-MM-dd').format(DateTime.now())
      };
    });
    _loadRecentData();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb && MediaQuery.of(context).size.width > 800;
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade50, Colors.purple.shade50],
            ),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade50, Colors.purple.shade50],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text('Error Loading Data', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.purple.shade50],
          ),
        ),
        child: SafeArea(child: isWeb ? _buildWebLayout() : _buildMobileLayout()),
      ),
    );
  }

  Widget _buildWebLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildClockWidget(),
                const SizedBox(height: 24),
                _buildCurrentSessionWidget(),
                const SizedBox(height: 24),
                _buildQuickActions(),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                Expanded(child: _buildRecentView()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildClockWidget(),
          const SizedBox(height: 20),
          _buildCurrentSessionWidget(),
          const SizedBox(height: 20),
          _buildQuickActions(),
          const SizedBox(height: 20),
          _buildRecentView(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.access_time, size: 28, color: Colors.blue.shade600),
            const SizedBox(width: 12),
            Text(
              'Attendance Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
            ),
            const Spacer(),
            if (_userData != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        (_userData!['name'] as String? ?? 'User')[0].toUpperCase(),
                        style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_userData!['name'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => _selectDateRange(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
            ),
            child: Row(
              children: [
                Icon(Icons.date_range, size: 20, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _fromDate != null && _toDate != null
                        ? '${DateFormat('MMM dd, yyyy').format(_fromDate!)} - ${DateFormat('MMM dd, yyyy').format(_toDate!)}'
                        : 'Select Date Range',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search records...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(onPressed: () => _onSearchChanged(''), icon: const Icon(Icons.clear, color: Colors.grey))
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Examples: "2025-06-22", "June", "Monday", "2:30 PM", "2025"',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
        if (_searchQuery.isNotEmpty || _fromDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Icon(Icons.filter_list, size: 16, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                Text('Filters applied', style: TextStyle(fontSize: 14, color: Colors.orange.shade600, fontWeight: FontWeight.w500)),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildClockWidget() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Current Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
              IconButton(
                onPressed: _toggleTimeFormat,
                icon: Icon(_is24HourFormat ? Icons.schedule : Icons.access_time, color: Colors.blue.shade600),
                tooltip: _is24HourFormat ? 'Switch to 12-hour' : 'Switch to 24-hour',
              ),
            ],
          ),
          Text(
            _is24HourFormat ? TimeFormatService.formatTime24Hour(_currentTime) : TimeFormatService.formatTime(_currentTime),
            style: TextStyle(fontSize: MediaQuery.of(context).size.width < 600 ? 36 : 48, fontWeight: FontWeight.bold, color: Colors.grey.shade800, fontFamily: 'monospace'),
          ),
          Text(
            DateFormat('EEEE, MMMM d, yyyy').format(_currentTime),
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          if (_currentSession?['is_clocked_in'] == true) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.green.shade700),
                  const SizedBox(width: 6),
                  Text('Session: $_sessionDuration', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentSessionWidget() {
    if (_currentSession == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Icon(Icons.schedule, size: 32, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('No Active Session', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
            Text('Clock in to start', style: TextStyle(fontSize: 14, color: Colors.grey.shade500), textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _currentSession!['is_clocked_in'] ? Icons.play_circle_filled : Icons.stop_circle,
                color: _currentSession!['is_clocked_in'] ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text('Current Session', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Clock In:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      _currentSession!['clock_in'] != null
                          ? TimeFormatService.formatDateTime(DateTime.parse(_currentSession!['clock_in']).toLocal())
                          : 'N/A',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              if (_currentSession!['clock_out'] != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Clock Out:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        TimeFormatService.formatDateTime(DateTime.parse(_currentSession!['clock_out']).toLocal()),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isClockInEnabled && !_isClocking ? () => _clockInOut('clock_in') : null,
                  icon: _isClocking && _isClockInEnabled
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.login),
                  label: const Text('Clock In'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isClockOutEnabled && !_isClocking ? () => _clockInOut('clock_out') : null,
                  icon: _isClocking && _isClockOutEnabled
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.logout),
                  label: const Text('Clock Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentView() {
    if (_isLoadingWeek) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_weekDataError != null) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Records',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _weekDataError!,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRecentData,
              child: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
    if (_filteredLogs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Icon(Icons.history, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _fromDate != null ? 'No records found' : 'No attendance records',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty || _fromDate != null)
              TextButton(onPressed: _clearFilters, child: const Text('Clear filters')),
          ],
        ),
      );
    }

    final groupedLogs = _groupLogsByDate(_filteredLogs);
    final sortedDates = groupedLogs.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final logs = groupedLogs[date]!;
        final dateTime = DateTime.parse(date);
        final isExpanded = _expandedDates[date] ?? false;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _expandedDates[date] = !isExpanded;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(dateTime),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          '${logs.length} records',
                          style: TextStyle(fontSize: 12, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: logs.length,
                  itemBuilder: (context, logIndex) => _buildLogItem(logs[logIndex], logIndex == logs.length - 1),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogItem(Map<String, dynamic> log, bool isLast) {
    final timestamp = DateTime.parse(log['timestamp']).toLocal();
    final action = log['action'];
    final location = log['location_address'];
    final workMode = log['work_mode'] ?? 'N/A';

    return Container(
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: action == 'clock_in' ? Colors.green.shade100 : Colors.red.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            action == 'clock_in' ? Icons.login : Icons.logout,
            color: action == 'clock_in' ? Colors.green.shade700 : Colors.red.shade700,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Text(
              action == 'clock_in' ? 'Clock In' : 'Clock Out',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(8)),
              child: Text(
                workMode,
                style: TextStyle(fontSize: 10, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  _is24HourFormat ? TimeFormatService.formatTime24Hour(timestamp) : TimeFormatService.formatTime(timestamp),
                  style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(timestamp),
                  style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            if (location != null && location.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      location,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: IconButton(
          onPressed: () {
            if (log['latitude'] != null && log['longitude'] != null) {
              launchUrl(Uri.parse('https://www.google.com/maps?q=${log['latitude']},${log['longitude']}'),
                  mode: LaunchMode.externalApplication);
            }
          },
          icon: Icon(Icons.map, color: Colors.blue.shade600, size: 20),
          tooltip: 'View on map',
        ),
      ),
    );
  }
}