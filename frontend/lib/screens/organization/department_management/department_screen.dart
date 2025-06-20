import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class DepartmentManagementScreen extends StatefulWidget {
  const DepartmentManagementScreen({super.key});

  @override
  State<DepartmentManagementScreen> createState() => _DepartmentManagementScreenState();
}

class _DepartmentManagementScreenState extends State<DepartmentManagementScreen> {
  late Future<List<dynamic>> _departmentsFuture;
  late Future<List<dynamic>> _branchesFuture;
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
        _departmentsFuture = ApiService.listDepartments(userData['tenant_id']);
        _branchesFuture = ApiService.listBranches(userData['tenant_id']);
      });
    } catch (e) {
      // handle error
    }
  }

  void _refreshDepartments() {
    if (_userData != null) {
      setState(() {
        _departmentsFuture = ApiService.listDepartments(_userData!['tenant_id']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Department Management'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _departmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No departments found.'));
          }

          final departments = snapshot.data!;
          return ListView.builder(
            itemCount: departments.length,
            itemBuilder: (context, index) {
              final department = departments[index];
              return ListTile(
                title: Text(department['name']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showDepartmentDialog(department: department),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteDepartment(department['id']),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDepartmentDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showDepartmentDialog({Map<String, dynamic>? department}) async {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: department?['name']);
    String? _selectedBranchId = department?['branch_id'];
    final isEditing = department != null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Department' : 'Add Department'),
          content: FutureBuilder<List<dynamic>>(
            future: _branchesFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final branches = snapshot.data!;
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Department Name'),
                      validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedBranchId,
                      items: branches.map<DropdownMenuItem<String>>((branch) {
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
                  final departmentData = {
                    'name': _nameController.text,
                    'branch_id': _selectedBranchId,
                  };

                  try {
                    if (isEditing) {
                      await ApiService.updateDepartment(_userData!['tenant_id'], department!['id'], departmentData);
                    } else {
                      await ApiService.createDepartment(_userData!['tenant_id'], departmentData);
                    }
                    _refreshDepartments();
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

  Future<void> _deleteDepartment(String departmentId) async {
    try {
      await ApiService.deleteDepartment(_userData!['tenant_id'], departmentId);
      _refreshDepartments();
    } catch (e) {
      // show error
    }
  }
} 