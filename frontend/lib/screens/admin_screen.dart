import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<dynamic> _tenants = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTenants();
  }

  Future<void> _fetchTenants() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final tenants = await ApiService.adminListTenants();
      setState(() {
        _tenants = tenants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showAssignPlanDialog(dynamic tenant) async {
    final formKey = GlobalKey<FormState>();
    final planController = TextEditingController(text: tenant['plan'] ?? '');
    bool isSubmitting = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Assign Plan to ${tenant['name']}'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: planController,
                  decoration: const InputDecoration(labelText: 'Plan'),
                  validator: (v) => v == null || v.isEmpty ? 'Enter plan' : null,
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
                              await ApiService.adminAssignPlan(tenant['id'], planController.text);
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Plan assigned!')),
                                );
                                _fetchTenants();
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
                      : const Text('Assign'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showUsageDialog(dynamic tenant) async {
    bool isLoading = true;
    Map<String, dynamic>? usage;
    String? error;
    showDialog(
      context: context,
      builder: (context) {
        ApiService.adminTenantUsage(tenant['id']).then((data) {
          if (mounted) {
            setState(() {
              usage = data;
              isLoading = false;
            });
          }
        }).catchError((e) {
          if (mounted) {
            setState(() {
              error = e.toString();
              isLoading = false;
            });
          }
        });
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Usage for ${tenant['name']}'),
              content: isLoading
                  ? const SizedBox(height: 60, child: Center(child: CircularProgressIndicator()))
                  : error != null
                      ? Text('Error: $error')
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Employees: ${usage?['total_employees'] ?? 0}'),
                            Text('Attendance Records: ${usage?['total_attendance_records'] ?? 0}'),
                          ],
                        ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
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
    return Scaffold(
      appBar: AppBar(title: const Text('SaaS Admin')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text('Invite New User'),
              onPressed: _showInviteUserDialog,
            ),
          ),
          Expanded(
            child: _tenants.isEmpty
                ? const Center(child: Text('No tenants found.'))
                : ListView.separated(
                    itemCount: _tenants.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final tenant = _tenants[i];
                      return ListTile(
                        leading: const Icon(Icons.business),
                        title: Text(tenant['name'] ?? ''),
                        subtitle: Text('Plan: ${tenant['plan'] ?? '-'}\nContact: ${tenant['contact_email'] ?? '-'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.assignment),
                              tooltip: 'Assign Plan',
                              onPressed: () => _showAssignPlanDialog(tenant),
                            ),
                            IconButton(
                              icon: const Icon(Icons.bar_chart),
                              tooltip: 'View Usage',
                              onPressed: () => _showUsageDialog(tenant),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showInviteUserDialog() async {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final usernameController = TextEditingController();
    String? selectedRoleId;
    List<Map<String, dynamic>> availableRoles = [];
    bool isSubmitting = false;
    String? resetToken;
    String? error;
    // Fetch roles from backend
    try {
      final roles = await ApiService.getRoles();
      availableRoles = List<Map<String, dynamic>>.from(roles);
      if (availableRoles.isNotEmpty) selectedRoleId = availableRoles.first['id'];
    } catch (e) {
      availableRoles = [
        {'id': 'admin', 'name': 'admin'},
        {'id': 'manager', 'name': 'manager'},
        {'id': 'user', 'name': 'user'},
      ]; // fallback
      selectedRoleId = availableRoles.first['id'];
    }
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Invite New User'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(labelText: 'Username'),
                        validator: (v) => v == null || v.isEmpty ? 'Enter username' : null,
                      ),
                      const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                      value: selectedRoleId,
                      items: availableRoles.map<DropdownMenuItem<String>>((role) => DropdownMenuItem<String>(
                        value: role['id'] as String,
                        child: Text(role['name']),
                      )).toList(),
                      onChanged: (val) => setState(() => selectedRoleId = val),
                      decoration: const InputDecoration(labelText: 'Role'),
                      validator: (v) => v == null || v.isEmpty ? 'Select a role' : null,
                    ),
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setState(() => isSubmitting = true);
                            try {
                              final resp = await ApiService.adminAddUser(
                                email: emailController.text,
                                username: usernameController.text,
                                roleId: selectedRoleId!,
                              );
                              setState(() {
                                resetToken = resp['reset_token'];
                                isSubmitting = false;
                              });
                            } catch (e) {
                              setState(() {
                                error = e.toString();
                                isSubmitting = false;
                              });
                              // Show error as a SnackBar
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error ?? 'Failed to add user')),
                                );
                              }
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Invite'),
                ),
              ],
            );
          },
        );
      },
    );
  }
} 