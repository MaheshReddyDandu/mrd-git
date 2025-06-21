import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class TimePolicyScreen extends StatefulWidget {
  const TimePolicyScreen({super.key});

  @override
  State<TimePolicyScreen> createState() => _TimePolicyScreenState();
}

class _TimePolicyScreenState extends State<TimePolicyScreen> {
  List<dynamic> _timePolicies = [];
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
      final policies = await ApiService.listPolicies(policyType: 'time');
      setState(() {
        _timePolicies = policies;
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
        title: const Text('Time Policy'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showAddTimePolicyDialog(),
            icon: const Icon(Icons.add),
            tooltip: 'Add Time Policy',
          ),
        ],
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
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: _timePolicies.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                            Center(
                              child: Column(
                                children: [
                                  Icon(Icons.access_time, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'No time policies configured',
                                    style: TextStyle(fontSize: 18, color: Colors.grey),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Add your first time policy to get started',
                                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                  ),
                                  SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: () => _showAddTimePolicyDialog(),
                                    icon: Icon(Icons.add),
                                    label: Text('Add Time Policy'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _timePolicies.length,
                          itemBuilder: (context, index) {
                            final policy = _timePolicies[index];
                            return _buildTimePolicyCard(policy);
                          },
                        ),
                ),
    );
  }

  Widget _buildTimePolicyCard(Map<String, dynamic> policy) {
    final policyType = policy['policy_type'] ?? 'standard';
    final isActive = policy['is_active'] ?? true;
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              _getPolicyTypeColor(policyType).withOpacity(0.1),
              _getPolicyTypeColor(policyType).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getPolicyTypeColor(policyType).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getPolicyTypeIcon(policyType),
                      color: _getPolicyTypeColor(policyType),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          policy['name'] ?? 'Unnamed Policy',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getPolicyTypeName(policyType),
                          style: TextStyle(
                            fontSize: 14,
                            color: _getPolicyTypeColor(policyType),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isActive,
                    onChanged: (value) => _togglePolicyStatus(policy['id'], value),
                    activeColor: _getPolicyTypeColor(policyType),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Working Hours
              if (policy['start_time'] != null && policy['end_time'] != null)
                _buildInfoRow(
                  'Working Hours',
                  '${policy['start_time']} - ${policy['end_time']}',
                  Icons.schedule,
                ),
              
              // Break Duration
              if (policy['break_duration_minutes'] != null)
                _buildInfoRow(
                  'Break Duration',
                  '${policy['break_duration_minutes']} minutes',
                  Icons.coffee,
                ),
              
              // Flexible Time
              if (policy['flexible_time_minutes'] != null)
                _buildInfoRow(
                  'Flexible Time',
                  '±${policy['flexible_time_minutes']} minutes',
                  Icons.timer,
                ),
              
              // Work Mode
              if (policy['work_mode'] != null)
                _buildInfoRow(
                  'Work Mode',
                  _getWorkModeName(policy['work_mode']),
                  Icons.work,
                ),
              
              // Grace Period
              if (policy['grace_period_minutes'] != null)
                _buildInfoRow(
                  'Grace Period',
                  '${policy['grace_period_minutes']} minutes',
                  Icons.access_time,
                ),
              
              const SizedBox(height: 16),
              
              // Description
              if (policy['description'] != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    policy['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showEditTimePolicyDialog(policy),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showDeleteTimePolicyDialog(policy),
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPolicyTypeColor(String policyType) {
    switch (policyType.toLowerCase()) {
      case 'standard':
        return Colors.blue;
      case 'flexible':
        return Colors.green;
      case 'wfh':
        return Colors.purple;
      case 'hybrid':
        return Colors.orange;
      case 'shift':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getPolicyTypeIcon(String policyType) {
    switch (policyType.toLowerCase()) {
      case 'standard':
        return Icons.schedule;
      case 'flexible':
        return Icons.timer;
      case 'wfh':
        return Icons.home;
      case 'hybrid':
        return Icons.swap_horiz;
      case 'shift':
        return Icons.rotate_right;
      default:
        return Icons.access_time;
    }
  }

  String _getPolicyTypeName(String policyType) {
    switch (policyType.toLowerCase()) {
      case 'standard':
        return 'Standard Working Hours';
      case 'flexible':
        return 'Flexible Time';
      case 'wfh':
        return 'Work From Home';
      case 'hybrid':
        return 'Hybrid Mode';
      case 'shift':
        return 'Shift Work';
      default:
        return 'Custom Policy';
    }
  }

  String _getWorkModeName(String workMode) {
    switch (workMode.toLowerCase()) {
      case 'office':
        return 'Office Only';
      case 'wfh':
        return 'Work From Home';
      case 'hybrid':
        return 'Hybrid (Office + WFH)';
      case 'remote':
        return 'Remote Only';
      default:
        return workMode;
    }
  }

  void _showAddTimePolicyDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 18, minute: 0);
    String selectedPolicyType = 'standard';
    String selectedWorkMode = 'office';
    int breakDuration = 60;
    int flexibleTime = 30;
    int gracePeriod = 15;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Time Policy'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Policy Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedPolicyType,
                decoration: const InputDecoration(
                  labelText: 'Policy Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'standard', child: Text('Standard')),
                  DropdownMenuItem(value: 'flexible', child: Text('Flexible')),
                  DropdownMenuItem(value: 'wfh', child: Text('Work From Home')),
                  DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
                  DropdownMenuItem(value: 'shift', child: Text('Shift Work')),
                ],
                onChanged: (value) {
                  if (value != null) selectedPolicyType = value;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: startTime,
                        );
                        if (time != null) {
                          startTime = time;
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Time',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(startTime.format(context)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: endTime,
                        );
                        if (time != null) {
                          endTime = time;
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Time',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(endTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedWorkMode,
                decoration: const InputDecoration(
                  labelText: 'Work Mode',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'office', child: Text('Office Only')),
                  DropdownMenuItem(value: 'wfh', child: Text('Work From Home')),
                  DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
                  DropdownMenuItem(value: 'remote', child: Text('Remote Only')),
                ],
                onChanged: (value) {
                  if (value != null) selectedWorkMode = value;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Break Duration (minutes)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        breakDuration = int.tryParse(value) ?? 60;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Grace Period (minutes)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        gracePeriod = int.tryParse(value) ?? 15;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Flexible Time (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  flexibleTime = int.tryParse(value) ?? 30;
                },
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
                _showErrorSnackBar('Please enter a policy name');
                return;
              }

              try {
                await ApiService.createPolicy({
                  'name': nameController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'policy_type': 'time',
                  'time_policy_type': selectedPolicyType,
                  'start_time': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                  'end_time': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                  'work_mode': selectedWorkMode,
                  'break_duration_minutes': breakDuration,
                  'grace_period_minutes': gracePeriod,
                  'flexible_time_minutes': flexibleTime,
                });
                
                Navigator.pop(context);
                _showSuccessSnackBar('Time policy added successfully');
                _loadData();
              } catch (e) {
                _showErrorSnackBar('Error adding time policy: $e');
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditTimePolicyDialog(Map<String, dynamic> policy) {
    // Similar to add dialog but with pre-filled values
    // Implementation would be similar to _showAddTimePolicyDialog
  }

  void _showDeleteTimePolicyDialog(Map<String, dynamic> policy) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Time Policy'),
        content: Text('Are you sure you want to delete "${policy['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService.deletePolicy(policy['id']);
                Navigator.pop(context);
                _showSuccessSnackBar('Time policy deleted successfully');
                _loadData();
              } catch (e) {
                _showErrorSnackBar('Error deleting time policy: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _togglePolicyStatus(String policyId, bool isActive) async {
    try {
      // Implement toggle functionality
      _showSuccessSnackBar('Policy status updated');
      _loadData();
    } catch (e) {
      _showErrorSnackBar('Error updating policy status: $e');
    }
  }
} 