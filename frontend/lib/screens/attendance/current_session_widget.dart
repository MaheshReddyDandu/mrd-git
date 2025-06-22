import 'package:flutter/material.dart';
import '../../services/time_format_service.dart';

class CurrentSessionWidget extends StatelessWidget {
  final Map<String, dynamic>? currentSession;
  const CurrentSessionWidget({super.key, required this.currentSession});

  @override
  Widget build(BuildContext context) {
    if (currentSession == null) {
      return Container(
        padding: const EdgeInsets.all(20),
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
            Icon(Icons.schedule, size: 32, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No Active Session',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Clock in to start your work session',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                currentSession!['is_clocked_in'] == true 
                  ? Icons.play_circle_filled 
                  : Icons.stop_circle,
                color: currentSession!['is_clocked_in'] == true 
                  ? Colors.green 
                  : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Current Session',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Clock In Time:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      currentSession!['clock_in'] != null 
                        ? TimeFormatService.formatDateTime(DateTime.parse(currentSession!['clock_in']).toLocal())
                        : 'Not available',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              if (currentSession!['clock_out'] != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Clock Out Time:',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        TimeFormatService.formatDateTime(DateTime.parse(currentSession!['clock_out']).toLocal()),
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
} 