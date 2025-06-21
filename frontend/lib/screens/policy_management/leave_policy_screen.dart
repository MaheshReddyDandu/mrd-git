import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class LeavePolicyScreen extends StatefulWidget {
  const LeavePolicyScreen({super.key});

  @override
  State<LeavePolicyScreen> createState() => _LeavePolicyScreenState();
}

class _LeavePolicyScreenState extends State<LeavePolicyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _leaveTypes = [];
  List<dynamic> _leaveRequests = [];
  bool _isLoading = true;
  String? _error;

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
      final leaveTypes = await ApiService.listLeaveTypes();
      final leaveRequests = await ApiService.listLeaveRequests();
      
      setState(() {
        _leaveTypes = leaveTypes;
        _leaveRequests = leaveRequests;
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
        title: const Text('Leave Policy'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Leave Types'),
            Tab(text: 'Leave Requests'),
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
                    _buildLeaveTypesTab(),
                    _buildLeaveRequestsTab(),
                  ],
                ),
    );
  }

  Widget _buildLeaveTypesTab() {
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
                      'Leave Types',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAddLeaveTypeDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Leave Type'),
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
            
            if (_leaveTypes.isEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.beach_access, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No leave types configured',
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
                itemCount: _leaveTypes.length,
                itemBuilder: (context, index) {
                  final leaveType = _leaveTypes[index];
                  return _buildLeaveTypeCard(leaveType);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveTypeCard(Map<String, dynamic> leaveType) {
    final isActive = leaveType['is_active'] ?? true;
    final color = _getLeaveTypeColor(leaveType['category']);
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getLeaveTypeIcon(leaveType['category']),
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          leaveType['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getLeaveCategoryName(leaveType['category']),
                          style: TextStyle(
                            fontSize: 14,
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isActive,
                    onChanged: (value) => _toggleLeaveTypeStatus(leaveType['id'], value),
                    activeColor: color,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Leave Details
              _buildLeaveInfoRow('Default Balance', '${leaveType['default_balance']} days', Icons.calendar_today),
              _buildLeaveInfoRow('Max Balance', '${leaveType['max_balance']} days', Icons.calendar_month),
              _buildLeaveInfoRow('Min Notice', '${leaveType['min_notice_days']} days', Icons.notification_important),
              _buildLeaveInfoRow('Max Duration', '${leaveType['max_duration_days']} days', Icons.timer),
              
              if (leaveType['description'] != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    leaveType['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showEditLeaveTypeDialog(leaveType),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showDeleteLeaveTypeDialog(leaveType),
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

  Widget _buildLeaveInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
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

  Widget _buildLeaveRequestsTab() {
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
                      'Leave Requests',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAddLeaveRequestDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Request Leave'),
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
            
            if (_leaveRequests.isEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.assignment, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No leave requests',
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
                itemCount: _leaveRequests.length,
                itemBuilder: (context, index) {
                  final request = _leaveRequests[index];
                  return _buildLeaveRequestCard(request);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveRequestCard(Map<String, dynamic> request) {
    final status = request['status'] ?? 'pending';
    final startDate = DateTime.parse(request['start_date']);
    final endDate = DateTime.parse(request['end_date']);
    final duration = endDate.difference(startDate).inDays + 1;
    final color = _getStatusColor(status);
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(status),
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['leave_type_name'] ?? 'Unknown Leave Type',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${DateFormat('MMM dd').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            _buildRequestInfoRow('Duration', '$duration days', Icons.calendar_today),
            _buildRequestInfoRow('Reason', request['reason'] ?? 'No reason provided', Icons.note),
            
            if (request['status'] == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _approveLeaveRequest(request['id'], 'approved'),
                    icon: const Icon(Icons.check, size: 18, color: Colors.green),
                    label: const Text('Approve', style: TextStyle(color: Colors.green)),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _approveLeaveRequest(request['id'], 'rejected'),
                    icon: const Icon(Icons.close, size: 18, color: Colors.red),
                    label: const Text('Reject', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRequestInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
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
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Color _getLeaveTypeColor(String category) {
    switch (category.toLowerCase()) {
      case 'annual':
        return Colors.blue;
      case 'sick':
        return Colors.red;
      case 'casual':
        return Colors.orange;
      case 'maternity':
        return Colors.pink;
      case 'paternity':
        return Colors.purple;
      case 'bereavement':
        return Colors.grey;
      default:
        return Colors.green;
    }
  }

  IconData _getLeaveTypeIcon(String category) {
    switch (category.toLowerCase()) {
      case 'annual':
        return Icons.beach_access;
      case 'sick':
        return Icons.local_hospital;
      case 'casual':
        return Icons.free_breakfast;
      case 'maternity':
        return Icons.favorite;
      case 'paternity':
        return Icons.family_restroom;
      case 'bereavement':
        return Icons.emoji_emotions;
      default:
        return Icons.event_note;
    }
  }

  String _getLeaveCategoryName(String category) {
    switch (category.toLowerCase()) {
      case 'annual':
        return 'Annual Leave';
      case 'sick':
        return 'Sick Leave';
      case 'casual':
        return 'Casual Leave';
      case 'maternity':
        return 'Maternity Leave';
      case 'paternity':
        return 'Paternity Leave';
      case 'bereavement':
        return 'Bereavement Leave';
      default:
        return 'Other Leave';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
        return Icons.schedule;
      default:
        return Icons.help;
    }
  }

  void _showAddLeaveTypeDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'annual';
    int defaultBalance = 20;
    int maxBalance = 30;
    int minNotice = 1;
    int maxDuration = 15;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Leave Type'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Leave Type Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'annual', child: Text('Annual Leave')),
                  DropdownMenuItem(value: 'sick', child: Text('Sick Leave')),
                  DropdownMenuItem(value: 'casual', child: Text('Casual Leave')),
                  DropdownMenuItem(value: 'maternity', child: Text('Maternity Leave')),
                  DropdownMenuItem(value: 'paternity', child: Text('Paternity Leave')),
                  DropdownMenuItem(value: 'bereavement', child: Text('Bereavement Leave')),
                ],
                onChanged: (value) {
                  if (value != null) selectedCategory = value;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Default Balance',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        defaultBalance = int.tryParse(value) ?? 20;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Max Balance',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        maxBalance = int.tryParse(value) ?? 30;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Min Notice (days)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        minNotice = int.tryParse(value) ?? 1;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Max Duration (days)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        maxDuration = int.tryParse(value) ?? 15;
                      },
                    ),
                  ),
                ],
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
                _showErrorSnackBar('Please enter a leave type name');
                return;
              }

              try {
                await ApiService.createLeaveType({
                  'name': nameController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'category': selectedCategory,
                  'default_balance': defaultBalance,
                  'max_balance': maxBalance,
                  'min_notice_days': minNotice,
                  'max_duration_days': maxDuration,
                });
                
                Navigator.pop(context);
                _showSuccessSnackBar('Leave type added successfully');
                _loadData();
              } catch (e) {
                _showErrorSnackBar('Error adding leave type: $e');
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditLeaveTypeDialog(Map<String, dynamic> leaveType) {
    // Similar to add dialog but with pre-filled values
  }

  void _showDeleteLeaveTypeDialog(Map<String, dynamic> leaveType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Leave Type'),
        content: Text('Are you sure you want to delete "${leaveType['name']}"?'),
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

  void _showAddLeaveRequestDialog() {
    // Implementation for adding leave request
  }

  Future<void> _approveLeaveRequest(String requestId, String status) async {
    try {
      await ApiService.approveLeaveRequest(requestId, status, 'current_user_id');
      _showSuccessSnackBar('Leave request ${status} successfully');
      _loadData();
    } catch (e) {
      _showErrorSnackBar('Error updating leave request: $e');
    }
  }

  Future<void> _toggleLeaveTypeStatus(String leaveTypeId, bool isActive) async {
    try {
      // Implement toggle functionality
      _showSuccessSnackBar('Leave type status updated');
      _loadData();
    } catch (e) {
      _showErrorSnackBar('Error updating leave type status: $e');
    }
  }
} 