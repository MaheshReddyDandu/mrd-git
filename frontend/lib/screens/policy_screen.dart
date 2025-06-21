import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert';

class PolicyScreen extends StatefulWidget {
  const PolicyScreen({super.key});

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  List<dynamic> _policies = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPolicies();
  }

  Future<void> _fetchPolicies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final tenantId = await _getTenantId();
      final policies = await ApiService.listPolicies(tenantId);
      setState(() {
        _policies = policies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<String> _getTenantId() async {
    final user = await ApiService.getCurrentUser();
    return user['tenant_id'] ?? '';
  }

  Future<void> _showAddPolicyDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    final levelController = TextEditingController();
    final rulesController = TextEditingController();
    bool isSubmitting = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Policy'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: typeController,
                        decoration: const InputDecoration(labelText: 'Type (attendance, leave, penalty, etc.)'),
                        validator: (v) => v == null || v.isEmpty ? 'Enter type' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: levelController,
                        decoration: const InputDecoration(labelText: 'Level (org, branch, department, user)'),
                        validator: (v) => v == null || v.isEmpty ? 'Enter level' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: rulesController,
                        decoration: const InputDecoration(labelText: 'Rules (JSON)'),
                        maxLines: 3,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter rules';
                          try {
                            jsonDecode(v);
                          } catch (_) {
                            return 'Invalid JSON';
                          }
                          return null;
                        },
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
                          if (formKey.currentState!.validate()) {
                            setState(() => isSubmitting = true);
                            try {
                              final tenantId = await _getTenantId();
                              await ApiService.createPolicy(tenantId, {
                                'tenant_id': tenantId,
                                'name': nameController.text,
                                'type': typeController.text,
                                'level': levelController.text,
                                'rules': rulesController.text,
                              });
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Policy added!')),
                                );
                                _fetchPolicies();
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
                      : const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAssignPolicyDialog(dynamic policy) async {
    final formKey = GlobalKey<FormState>();
    final branchIdController = TextEditingController();
    final departmentIdController = TextEditingController();
    final userIdController = TextEditingController();
    bool isSubmitting = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Assign Policy: ${policy['name']}'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: branchIdController,
                        decoration: const InputDecoration(labelText: 'Branch ID (optional)'),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: departmentIdController,
                        decoration: const InputDecoration(labelText: 'Department ID (optional)'),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: userIdController,
                        decoration: const InputDecoration(labelText: 'User ID (optional)'),
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
                          setState(() => isSubmitting = true);
                          try {
                            final tenantId = await _getTenantId();
                            await ApiService.assignPolicy(tenantId, {
                              'tenant_id': tenantId,
                              'policy_id': policy['id'],
                              'branch_id': branchIdController.text.isEmpty ? null : branchIdController.text,
                              'department_id': departmentIdController.text.isEmpty ? null : departmentIdController.text,
                              'user_id': userIdController.text.isEmpty ? null : userIdController.text,
                            });
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Policy assigned!')),
                              );
                            }
                          } catch (e) {
                            setState(() => isSubmitting = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Policies')),
      body: _policies.isEmpty
          ? const Center(child: Text('No policies found.'))
          : ListView.separated(
              itemCount: _policies.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final policy = _policies[i];
                return ListTile(
                  leading: const Icon(Icons.policy),
                  title: Text(policy['name'] ?? ''),
                  subtitle: Text('Type: ${policy['type']}, Level: ${policy['level']}'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(policy['name'] ?? ''),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Type: ${policy['type']}'),
                              Text('Level: ${policy['level']}'),
                              Text('Rules: ${policy['rules']}'),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                          ElevatedButton(
                            onPressed: () => _showAssignPolicyDialog(policy),
                            child: const Text('Assign'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPolicyDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add Policy',
      ),
    );
  }
} 