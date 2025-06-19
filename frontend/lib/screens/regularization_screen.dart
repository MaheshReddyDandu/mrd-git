import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class RegularizationScreen extends StatefulWidget {
  const RegularizationScreen({super.key});

  @override
  State<RegularizationScreen> createState() => _RegularizationScreenState();
}

class _RegularizationScreenState extends State<RegularizationScreen> {
  List<dynamic> _requests = [];
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _userData;

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
      final user = await ApiService.getCurrentUser();
      final tenantId = user['tenant_id'];
      final requests = await ApiService.listRegularizationRequests(tenantId);
      setState(() {
        _userData = user;
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showSubmitRequestDialog() async {
    final formKey = GlobalKey<FormState>();
    DateTime? selectedDate;
    final reasonController = TextEditingController();
    final inController = TextEditingController();
    final outController = TextEditingController();
    bool isSubmitting = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Submit Regularization Request'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: reasonController,
                        decoration: const InputDecoration(labelText: 'Reason'),
                        validator: (v) => v == null || v.isEmpty ? 'Enter reason' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: inController,
                        decoration: const InputDecoration(labelText: 'Requested In (yyyy-MM-dd HH:mm)'),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: outController,
                        decoration: const InputDecoration(labelText: 'Requested Out (yyyy-MM-dd HH:mm)'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => selectedDate = picked);
                          }
                        },
                        child: Text(selectedDate == null ? 'Select Date' : DateFormat('yyyy-MM-dd').format(selectedDate!)),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (formKey.currentState!.validate() && selectedDate != null) {
                            setState(() => isSubmitting = true);
                            try {
                              final user = _userData ?? await ApiService.getCurrentUser();
                              final tenantId = user['tenant_id'];
                              final employeeId = user['id'];
                              await ApiService.submitRegularizationRequest(tenantId, {
                                'tenant_id': tenantId,
                                'employee_id': employeeId,
                                'date': selectedDate!.toIso8601String(),
                                'reason': reasonController.text,
                                'requested_in': inController.text.isEmpty ? null : inController.text,
                                'requested_out': outController.text.isEmpty ? null : outController.text,
                              });
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Request submitted!')),
                                );
                                _loadData();
                              }
                            } catch (e) {
                              setState(() => isSubmitting = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showApproveDialog(dynamic req) async {
    final formKey = GlobalKey<FormState>();
    String? status;
    bool isSubmitting = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Approve/Reject Request'),
              content: Form(
                key: formKey,
                child: DropdownButtonFormField<String>(
                  value: status,
                  items: const [
                    DropdownMenuItem(value: 'approved', child: Text('Approve')),
                    DropdownMenuItem(value: 'rejected', child: Text('Reject')),
                  ],
                  onChanged: (v) => setState(() => status = v),
                  decoration: const InputDecoration(labelText: 'Status'),
                  validator: (v) => v == null ? 'Select status' : null,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setState(() => isSubmitting = true);
                            try {
                              final user = _userData ?? await ApiService.getCurrentUser();
                              final tenantId = user['tenant_id'];
                              await ApiService.approveRegularizationRequest(
                                tenantId,
                                req['id'],
                                {
                                  'approver_id': user['id'],
                                  'status': status,
                                },
                              );
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Request $status!')),
                                );
                                _loadData();
                              }
                            } catch (e) {
                              setState(() => isSubmitting = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    final roles = (_userData?['roles'] as List?)?.map((r) => r['name'] as String).toList() ?? [];
    final isManagerOrAdmin = roles.contains('admin') || roles.contains('manager');
    final userId = _userData?['id'];
    return Scaffold(
      appBar: AppBar(title: const Text('Regularization Requests')),
      body: _requests.isEmpty
          ? const Center(child: Text('No requests found.'))
          : ListView.separated(
              itemCount: _requests.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final req = _requests[i];
                final isOwn = req['employee_id'] == userId;
                return ListTile(
                  leading: Icon(
                    req['status'] == 'approved'
                        ? Icons.check_circle
                        : req['status'] == 'rejected'
                            ? Icons.cancel
                            : Icons.hourglass_top,
                    color: req['status'] == 'approved'
                        ? Colors.green
                        : req['status'] == 'rejected'
                            ? Colors.red
                            : Colors.orange,
                  ),
                  title: Text(DateFormat('yyyy-MM-dd').format(DateTime.parse(req['date']))),
                  subtitle: Text('Reason: ${req['reason']}\nStatus: ${req['status']}'),
                  trailing: isManagerOrAdmin && req['status'] == 'pending'
                      ? IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showApproveDialog(req),
                        )
                      : null,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Request Details'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(req['date']))}'),
                            Text('Reason: ${req['reason']}'),
                            Text('Requested In: ${req['requested_in'] ?? '-'}'),
                            Text('Requested Out: ${req['requested_out'] ?? '-'}'),
                            Text('Status: ${req['status']}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                          if (isManagerOrAdmin && req['status'] == 'pending')
                            ElevatedButton(
                              onPressed: () => _showApproveDialog(req),
                              child: const Text('Approve/Reject'),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSubmitRequestDialog,
        child: const Icon(Icons.add),
        tooltip: 'Submit Request',
      ),
    );
  }
} 