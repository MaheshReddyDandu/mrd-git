import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
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
  List<dynamic> _attendanceRecords = [];
  List<dynamic> _attendanceLogs = [];
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

  @override
  void initState() {
    super.initState();
    _startClock();
    _loadData();
    _checkLocationPermission();
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
      final attendanceRecords = await ApiService.getMyAttendanceRecords();
      final attendanceLogs = await ApiService.getMyAttendanceLogs(
        date: DateFormat('yyyy-MM-dd').format(_selectedDate)
      );
      
      setState(() {
        _userData = user;
        _currentSession = currentSession;
        _attendanceRecords = attendanceRecords;
        _attendanceLogs = attendanceLogs;
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
      setState(() {
        _attendanceLogs = logs;
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
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
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
              
              // Date Selector for Logs
              _buildDateSelector(),
              
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
              DateFormat('HH:mm:ss').format(_currentTime),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
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
                const Text(
                  'Current Session',
                  style: TextStyle(
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
                const Text('Duration:'),
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
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Clock In:'),
                Text(
                  DateFormat('HH:mm:ss').format(DateTime.parse(_currentSession!['clock_in'])),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance Logs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
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
        ),
      ),
    );
  }

  Widget _buildAttendanceLogsWidget() {
    if (_attendanceLogs.isEmpty) {
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
                  'No attendance logs for this date',
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

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _attendanceLogs.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final log = _attendanceLogs[index];
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
                Text(DateFormat('HH:mm:ss').format(timestamp)),
                if (log['location_address'] != null)
                  Text(
                    log['location_address'],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            trailing: hasLocation
                ? IconButton(
                    onPressed: () => _showLocationOnMap(
                      log['latitude'].toDouble(),
                      log['longitude'].toDouble(),
                    ),
                    icon: const Icon(Icons.map),
                    tooltip: 'View on map',
                  )
                : const Icon(Icons.location_off, color: Colors.grey),
          );
        },
      ),
    );
  }
} 