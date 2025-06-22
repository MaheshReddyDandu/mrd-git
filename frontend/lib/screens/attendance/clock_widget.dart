import 'package:flutter/material.dart';
import '../../services/time_format_service.dart';

class ClockWidget extends StatelessWidget {
  final DateTime currentTime;
  final bool is24HourFormat;
  final VoidCallback onToggleTimeFormat;

  const ClockWidget({
    super.key,
    required this.currentTime,
    required this.is24HourFormat,
    required this.onToggleTimeFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Time',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              IconButton(
                onPressed: onToggleTimeFormat,
                icon: Icon(
                  is24HourFormat ? Icons.schedule : Icons.access_time,
                  color: Colors.blue.shade600,
                ),
                tooltip: is24HourFormat ? 'Switch to 12-hour' : 'Switch to 24-hour',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            is24HourFormat 
              ? TimeFormatService.formatTime24Hour(currentTime)
              : TimeFormatService.formatTime(currentTime),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            TimeFormatService.formatDateTime(currentTime),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
} 