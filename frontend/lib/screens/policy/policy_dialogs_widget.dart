import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/api_service.dart';

class PolicyDialogsWidget {
  static Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
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

  static void showPolicyDetails(BuildContext context, dynamic policy, VoidCallback onAssignPolicy) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.policy, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                policy['name'] ?? 'Policy Details',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Type', policy['type'] ?? 'N/A'),
              _buildDetailRow('Level', policy['level'] ?? 'N/A'),
              _buildDetailRow('Status', (policy['is_active'] ?? true) ? 'Active' : 'Inactive'),
              const SizedBox(height: 16),
              const Text(
                'Rules:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  policy['rules'] ?? 'No rules defined',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onAssignPolicy();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Assign Policy'),
          ),
        ],
      ),
    );
  }

  static Future<void> showAddPolicyDialog(BuildContext context, VoidCallback onPolicyCreated) async {
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
              title: Row(
                children: [
                  Icon(Icons.add_circle, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  const Text('Create New Policy'),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Policy Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.policy),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Enter policy name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: typeController,
                        decoration: InputDecoration(
                          labelText: 'Type (attendance, leave, penalty, etc.)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.category),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Enter type' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: levelController,
                        decoration: InputDecoration(
                          labelText: 'Level (org, branch, department, user)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.layers),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Enter level' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: rulesController,
                        decoration: InputDecoration(
                          labelText: 'Rules (JSON)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.code),
                        ),
                        maxLines: 4,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter rules';
                          try {
                            jsonDecode(v);
                          } catch (_) {
                            return 'Invalid JSON format';
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
                              final user = await ApiService.getCurrentUser();
                              final tenantId = user['tenant_id'] ?? '';
                              await ApiService.createPolicy({
                                'tenant_id': tenantId,
                                'name': nameController.text,
                                'type': typeController.text,
                                'level': levelController.text,
                                'rules': rulesController.text,
                              });
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Policy created successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                onPolicyCreated();
                              }
                            } catch (e) {
                              setState(() => isSubmitting = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : const Text('Create Policy'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Future<void> showAssignPolicyDialog(BuildContext context, dynamic policy) async {
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
              title: Row(
                children: [
                  Icon(Icons.assignment, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Assign Policy: ${policy['name']}'),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: branchIdController,
                        decoration: InputDecoration(
                          labelText: 'Branch ID (optional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.business),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: departmentIdController,
                        decoration: InputDecoration(
                          labelText: 'Department ID (optional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.account_tree),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: userIdController,
                        decoration: InputDecoration(
                          labelText: 'User ID (optional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.person),
                        ),
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
                            final user = await ApiService.getCurrentUser();
                            final tenantId = user['tenant_id'] ?? '';
                            await ApiService.assignPolicy({
                              'policy_id': policy['id'],
                              'tenant_id': tenantId,
                              'branch_id': branchIdController.text,
                              'department_id': departmentIdController.text,
                              'user_id': userIdController.text,
                            });
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Policy assigned successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            setState(() => isSubmitting = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : const Text('Assign Policy'),
                ),
              ],
            );
          },
        );
      },
    );
  }
} 