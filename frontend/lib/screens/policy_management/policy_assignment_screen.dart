import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class PolicyAssignmentScreen extends StatefulWidget {
  const PolicyAssignmentScreen({super.key});

  @override
  State<PolicyAssignmentScreen> createState() => _PolicyAssignmentScreenState();
}

class _PolicyAssignmentScreenState extends State<PolicyAssignmentScreen> {
  late Future<List<dynamic>> _policiesFuture;
  late Future<List<dynamic>> _branchesFuture;
  late Future<List<dynamic>> _departmentsFuture;
  late Future<List<dynamic>> _usersFuture;
  Map<String, dynamic>? _userData;
  String? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final userData = await ApiService.getCurrentUser();
      setState(() {
        _userData = userData;
        _policiesFuture = ApiService.listPolicies();
        _branchesFuture = ApiService.listBranches(userData['tenant_id']);
        _departmentsFuture = ApiService.listDepartments(userData['tenant_id']);
        _usersFuture = ApiService.listUsers(userData['tenant_id']);
      });
    } catch (e) {
      // handle error
    }
  }

  void _refreshPolicies() {
    if (_userData != null) {
      setState(() {
        _policiesFuture = ApiService.listPolicies();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Policy Assignment'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _policiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No policies found.'));
          }

          final policies = snapshot.data!;
          return ListView.builder(
            itemCount: policies.length,
            itemBuilder: (context, index) {
              final policy = policies[index];
              return ListTile(
                title: Text(policy['name']),
                subtitle: Text('Type: ${policy['type']}, Level: ${policy['level']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.assignment_add),
                  onPressed: () => _showAssignmentDialog(policy),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showAssignmentDialog(Map<String, dynamic> policy) async {
    String? _selectedBranchId;
    String? _selectedDepartmentId;
    String? _selectedUserId;
    final _formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Assign Policy: ${policy['name']}'),
          content: FutureBuilder<List<List<dynamic>>>(
            future: Future.wait([
              _branchesFuture,
              _departmentsFuture,
              _usersFuture,
            ]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final branches = snapshot.data![0];
              final departments = snapshot.data![1];
              final users = snapshot.data![2];
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedBranchId,
                      items: [const DropdownMenuItem(value: '', child: Text('None'))] +
                          branches.map<DropdownMenuItem<String>>((branch) {
                        return DropdownMenuItem<String>(
                          value: branch['id'],
                          child: Text(branch['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBranchId = value;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Branch'),
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedDepartmentId,
                      items: [const DropdownMenuItem(value: '', child: Text('None'))] +
                          departments.map<DropdownMenuItem<String>>((dept) {
                        return DropdownMenuItem<String>(
                          value: dept['id'],
                          child: Text(dept['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartmentId = value;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Department'),
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedUserId,
                      items: users.map<DropdownMenuItem<String>>((user) {
                        return DropdownMenuItem<String>(
                          value: user['id'],
                          child: Text(user['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUserId = value;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'User'),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await ApiService.assignPolicy({
                    'policy_id': policy['id'],
                    'tenant_id': _userData!['tenant_id'],
                    'branch_id': _selectedBranchId,
                    'department_id': _selectedDepartmentId,
                    'user_id': _selectedUserId,
                  });
                  _refreshPolicies();
                  Navigator.of(context).pop();
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