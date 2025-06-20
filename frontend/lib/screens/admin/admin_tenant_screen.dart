import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminTenantScreen extends StatefulWidget {
  const AdminTenantScreen({super.key});

  @override
  State<AdminTenantScreen> createState() => _AdminTenantScreenState();
}

class _AdminTenantScreenState extends State<AdminTenantScreen> {
  late Future<List<dynamic>> _tenantsFuture;

  @override
  void initState() {
    super.initState();
    _refreshTenants();
  }

  void _refreshTenants() {
    setState(() {
      _tenantsFuture = ApiService.adminListTenants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tenant Management (Admin)')),
      body: FutureBuilder<List<dynamic>>(
        future: _tenantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tenants found.'));
          }
          final tenants = snapshot.data!;
          return ListView.builder(
            itemCount: tenants.length,
            itemBuilder: (context, index) {
              final tenant = tenants[index];
              return ListTile(
                title: Text(tenant['name']),
                subtitle: Text('Plan: ${tenant['plan'] ?? 'N/A'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditTenantDialog(tenant),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteTenant(tenant['id']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.analytics),
                      onPressed: () => _showTenantUsageDialog(tenant['id']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.assignment_turned_in),
                      onPressed: () => _showAssignPlanDialog(tenant),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showEditTenantDialog(Map<String, dynamic> tenant) async {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: tenant['name']);
    final _emailController = TextEditingController(text: tenant['contact_email']);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Tenant'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Tenant Name'),
                  validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Contact Email'),
                  validator: (value) => value!.isEmpty ? 'Please enter an email' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    await ApiService.adminUpdateTenant(tenant['id'], {
                      'name': _nameController.text,
                      'contact_email': _emailController.text,
                    });
                    _refreshTenants();
                    Navigator.of(context).pop();
                  } catch (e) {
                    // show error
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTenant(String tenantId) async {
    try {
      await ApiService.adminDeleteTenant(tenantId);
      _refreshTenants();
    } catch (e) {
      // show error
    }
  }

  Future<void> _showTenantUsageDialog(String tenantId) async {
    try {
      final usage = await ApiService.adminTenantUsage(tenantId);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Tenant Usage'),
            content: Text('Employees: ${usage['total_employees'] ?? '-'}\nAttendance Records: ${usage['total_attendance_records'] ?? '-'}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // show error
    }
  }

  Future<void> _showAssignPlanDialog(Map<String, dynamic> tenant) async {
    String? _selectedPlan = tenant['plan'];
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Assign Plan to ${tenant['name']}'),
          content: DropdownButtonFormField<String>(
            value: _selectedPlan,
            items: const [
              DropdownMenuItem(value: 'basic', child: Text('Basic')),
              DropdownMenuItem(value: 'pro', child: Text('Pro')),
              DropdownMenuItem(value: 'enterprise', child: Text('Enterprise')),
            ],
            onChanged: (value) {
              _selectedPlan = value;
            },
            decoration: const InputDecoration(labelText: 'Plan'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_selectedPlan != null) {
                  try {
                    await ApiService.adminAssignPlan(tenant['id'], _selectedPlan!);
                    _refreshTenants();
                    Navigator.of(context).pop();
                  } catch (e) {
                    // show error
                  }
                }
              },
              child: const Text('Assign'),
            ),
          ],
        );
      },
    );
  }
} 