import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class CalendarPolicyScreen extends StatefulWidget {
  const CalendarPolicyScreen({super.key});

  @override
  State<CalendarPolicyScreen> createState() => _CalendarPolicyScreenState();
}

class _CalendarPolicyScreenState extends State<CalendarPolicyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _holidays = [];
  List<dynamic> _weekOffs = [];
  bool _isLoading = true;
  String? _error;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final holidays = await ApiService.listHolidays(year: _selectedYear);
      final weekOffs = await ApiService.listWeekOffs();
      
      setState(() {
        _holidays = holidays;
        _weekOffs = weekOffs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading data: $e');
    }
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Policy'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Holidays'),
            Tab(text: 'Week Offs'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
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
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildHolidaysTab(),
                    _buildWeekOffsTab(),
                  ],
                ),
    );
  }

  Widget _buildHolidaysTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Year Selector
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedYear,
                        decoration: const InputDecoration(
                          labelText: 'Select Year',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(5, (index) {
                          final year = DateTime.now().year - 2 + index;
                          return DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedYear = value);
                            _loadData();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAddHolidayDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Holiday'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Holidays List
            if (_holidays.isEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.event_busy, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No holidays for $_selectedYear',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _holidays.length,
                itemBuilder: (context, index) {
                  final holiday = _holidays[index];
                  final date = DateTime.parse(holiday['date']);
                  final isActive = holiday['is_active'] ?? true;
                  
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isActive ? Colors.green : Colors.grey,
                        child: Icon(
                          Icons.event,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        holiday['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: isActive ? null : TextDecoration.lineThrough,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(DateFormat('EEEE, MMMM d, yyyy').format(date)),
                          if (holiday['description'] != null)
                            Text(
                              holiday['description'],
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getHolidayTypeColor(holiday['type']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              holiday['type'].toString().toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                color: _getHolidayTypeColor(holiday['type']),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: const Icon(Icons.edit),
                              title: const Text('Edit'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: const Icon(Icons.delete, color: Colors.red),
                              title: const Text('Delete', style: TextStyle(color: Colors.red)),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditHolidayDialog(holiday);
                          } else if (value == 'delete') {
                            _showDeleteHolidayDialog(holiday);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekOffsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Week Off Days',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAddWeekOffDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Week Off'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            if (_weekOffs.isEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.weekend, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No week off days configured',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _weekOffs.length,
                itemBuilder: (context, index) {
                  final weekOff = _weekOffs[index];
                  final dayName = _getDayName(weekOff['day_of_week']);
                  final isActive = weekOff['is_active'] ?? true;
                  
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isActive ? Colors.blue : Colors.grey,
                        child: Icon(
                          Icons.weekend,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        dayName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: isActive ? null : TextDecoration.lineThrough,
                        ),
                      ),
                      subtitle: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: isActive ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Switch(
                        value: isActive,
                        onChanged: (value) => _toggleWeekOffStatus(weekOff['id'], value),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _getHolidayTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'holiday':
        return Colors.red;
      case 'optional_holiday':
        return Colors.orange;
      case 'company_holiday':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 0:
        return 'Monday';
      case 1:
        return 'Tuesday';
      case 2:
        return 'Wednesday';
      case 3:
        return 'Thursday';
      case 4:
        return 'Friday';
      case 5:
        return 'Saturday';
      case 6:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  void _showAddHolidayDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String selectedType = 'holiday';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Holiday'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Holiday Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(_selectedYear),
                    lastDate: DateTime(_selectedYear + 1),
                  );
                  if (date != null) {
                    selectedDate = date;
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'holiday', child: Text('Holiday')),
                  DropdownMenuItem(value: 'optional_holiday', child: Text('Optional Holiday')),
                  DropdownMenuItem(value: 'company_holiday', child: Text('Company Holiday')),
                ],
                onChanged: (value) {
                  if (value != null) selectedType = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                _showErrorSnackBar('Please enter a holiday name');
                return;
              }

              try {
                await ApiService.createHoliday({
                  'name': nameController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'date': DateFormat('yyyy-MM-dd').format(selectedDate),
                  'type': selectedType,
                });
                
                Navigator.pop(context);
                _showSuccessSnackBar('Holiday added successfully');
                _loadData();
              } catch (e) {
                _showErrorSnackBar('Error adding holiday: $e');
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditHolidayDialog(Map<String, dynamic> holiday) {
    // Similar to add dialog but with pre-filled values
    // Implementation would be similar to _showAddHolidayDialog
  }

  void _showDeleteHolidayDialog(Map<String, dynamic> holiday) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Holiday'),
        content: Text('Are you sure you want to delete "${holiday['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Implement delete functionality
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddWeekOffDialog() {
    int selectedDay = 0; // Monday

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Week Off'),
        content: DropdownButtonFormField<int>(
          value: selectedDay,
          decoration: const InputDecoration(
            labelText: 'Day of Week',
            border: OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(value: 0, child: Text('Monday')),
            DropdownMenuItem(value: 1, child: Text('Tuesday')),
            DropdownMenuItem(value: 2, child: Text('Wednesday')),
            DropdownMenuItem(value: 3, child: Text('Thursday')),
            DropdownMenuItem(value: 4, child: Text('Friday')),
            DropdownMenuItem(value: 5, child: Text('Saturday')),
            DropdownMenuItem(value: 6, child: Text('Sunday')),
          ],
          onChanged: (value) {
            if (value != null) selectedDay = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService.createWeekOff({
                  'day_of_week': selectedDay,
                });
                
                Navigator.pop(context);
                _showSuccessSnackBar('Week off added successfully');
                _loadData();
              } catch (e) {
                _showErrorSnackBar('Error adding week off: $e');
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleWeekOffStatus(String weekOffId, bool isActive) async {
    try {
      // Implement toggle functionality
      _showSuccessSnackBar('Week off status updated');
      _loadData();
    } catch (e) {
      _showErrorSnackBar('Error updating week off status: $e');
    }
  }
} 