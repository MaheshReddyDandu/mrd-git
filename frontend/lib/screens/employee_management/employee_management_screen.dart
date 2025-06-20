import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  State<EmployeeManagementScreen> createState() => _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  late Future<List<dynamic>> _employeesFuture;
  late Future<List<dynamic>> _departmentsFuture;
  late Future<List<dynamic>> _rolesFuture;
  Map<String, dynamic>? _userData;

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
        _employeesFuture = ApiService.listEmployees(userData['tenant_id']);
        _departmentsFuture = ApiService.listDepartments(userData['tenant_id']);
        _rolesFuture = ApiService.getRoles();
      });
    } catch (e) {
      // handle error
    }
  }

  void _refreshEmployees() {
    if (_userData != null) {
      setState(() {
        _employeesFuture = ApiService.listEmployees(_userData!['tenant_id']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Management'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _employeesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No employees found.'));
          }

          final employees = snapshot.data!;
          return ListView.builder(
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final emp = employees[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(emp['name'] ?? ''),
                subtitle: Text(emp['email'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEmployeeDialog(employee: emp),
                    ),
                    // Optionally add delete button here
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEmployeeDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showEmployeeDialog({Map<String, dynamic>? employee}) async {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: employee?['name']);
    final _emailController = TextEditingController(text: employee?['email']);
    String? _selectedDepartmentId = employee?['department_id'];
    String? _selectedRoleId = employee?['role_id'];
    final isEditing = employee != null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Employee' : 'Add Employee'),
          content: FutureBuilder<List<dynamic>>(
            future: Future.wait([_departmentsFuture, _rolesFuture]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final departments = snapshot.data![0];
              final roles = snapshot.data![1];
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) => value!.isEmpty ? 'Please enter an email' : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedDepartmentId,
                      items: departments.map<DropdownMenuItem<String>>((dept) {
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
                      value: _selectedRoleId,
                      items: roles.map<DropdownMenuItem<String>>((role) {
                        return DropdownMenuItem<String>(
                          value: role['id'],
                          child: Text(role['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRoleId = value;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Role'),
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
                  final empData = {
                    'name': _nameController.text,
                    'email': _emailController.text,
                    'department_id': _selectedDepartmentId,
                    'role_id': _selectedRoleId,
                    'tenant_id': _userData!['tenant_id'],
                  };
                  try {
                    if (isEditing) {
                      // TODO: Implement updateEmployee API if available
                    } else {
                      await ApiService.createEmployee(_userData!['tenant_id'], empData);
                    }
                    _refreshEmployees();
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
} 