import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class TimeFormatService {
  static const String _timeFormatKey = 'time_format_preference';
  static const String _24Hour = '24hour';
  static const String _12Hour = '12hour';
  
  static String _currentFormat = _24Hour; // Default to 24-hour format
  
  // Initialize the service and load user preference
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentFormat = prefs.getString(_timeFormatKey) ?? _24Hour;
  }
  
  // Get current time format preference
  static String get currentFormat => _currentFormat;
  
  // Check if using 24-hour format
  static bool get is24Hour => _currentFormat == _24Hour;
  
  // Check if using 12-hour format
  static bool get is12Hour => _currentFormat == _12Hour;
  
  // Set time format preference
  static Future<void> setTimeFormat(String format) async {
    if (format != _24Hour && format != _12Hour) {
      throw ArgumentError('Invalid time format. Use "24hour" or "12hour"');
    }
    
    _currentFormat = format;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_timeFormatKey, format);
  }
  
  // Toggle between 12-hour and 24-hour format
  static Future<void> toggleTimeFormat() async {
    final newFormat = _currentFormat == _24Hour ? _12Hour : _24Hour;
    await setTimeFormat(newFormat);
  }
  
  // Format time based on user preference
  static String formatTime(DateTime time) {
    if (_currentFormat == _24Hour) {
      return DateFormat('HH:mm:ss').format(time);
    } else {
      return DateFormat('hh:mm:ss a').format(time);
    }
  }
  
  // Format time without seconds
  static String formatTimeShort(DateTime time) {
    if (_currentFormat == _24Hour) {
      return DateFormat('HH:mm').format(time);
    } else {
      return DateFormat('hh:mm a').format(time);
    }
  }
  
  // Format date and time
  static String formatDateTime(DateTime time) {
    if (_currentFormat == _24Hour) {
      return DateFormat('MMM dd, yyyy HH:mm:ss').format(time);
    } else {
      return DateFormat('MMM dd, yyyy hh:mm:ss a').format(time);
    }
  }
  
  // Format date and time short
  static String formatDateTimeShort(DateTime time) {
    if (_currentFormat == _24Hour) {
      return DateFormat('MMM dd, HH:mm').format(time);
    } else {
      return DateFormat('MMM dd, hh:mm a').format(time);
    }
  }
  
  // Get format display name
  static String get formatDisplayName {
    return _currentFormat == _24Hour ? '24-Hour' : '12-Hour';
  }
  
  // Get format description
  static String get formatDescription {
    return _currentFormat == _24Hour 
        ? 'Shows time in 24-hour format (e.g., 14:30)'
        : 'Shows time in 12-hour format (e.g., 2:30 PM)';
  }
} 