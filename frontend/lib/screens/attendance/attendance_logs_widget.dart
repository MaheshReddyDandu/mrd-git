import 'package:flutter/material.dart';
import '../../services/time_format_service.dart';
import 'package:intl/intl.dart';

class AttendanceLogsWidget extends StatelessWidget {
  final List<dynamic> logs;
  final String searchQuery;
  final bool is24HourFormat;
  final void Function(String) onSearchChanged;
  final VoidCallback onClearFilters;

  const AttendanceLogsWidget({
    super.key,
    required this.logs,
    required this.searchQuery,
    required this.is24HourFormat,
    required this.onSearchChanged,
    required this.onClearFilters,
  });

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
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedLogs = _groupLogsByDate(logs);
    final sortedDates = groupedLogs.keys.toList()..sort();
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final logsForDate = groupedLogs[date]!;
        final dateTime = DateTime.parse(date);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 18, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('EEEE, MMM d, yyyy').format(dateTime),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${logsForDate.length} records',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ...logsForDate.map((log) => _buildLogItem(context, log)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildLogItem(BuildContext context, Map<String, dynamic> log) {
    final timestamp = DateTime.parse(log['timestamp']).toLocal();
    final action = log['action'];
    final location = log['location_address'];
    final workMode = log['work_mode'] ?? 'N/A';
    return ListTile(
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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              workMode,
              style: TextStyle(
                fontSize: 10,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
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
                is24HourFormat 
                  ? TimeFormatService.formatTime24Hour(timestamp)
                  : TimeFormatService.formatTime(timestamp),
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                DateFormat('MMM dd, yyyy').format(timestamp),
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
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
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      trailing: log['latitude'] != null && log['longitude'] != null
          ? IconButton(
              onPressed: () {
                // Implement map view callback if needed
              },
              icon: Icon(
                Icons.map,
                color: Colors.blue.shade600,
                size: 20,
              ),
              tooltip: 'View on map',
            )
          : null,
    );
  }
} 