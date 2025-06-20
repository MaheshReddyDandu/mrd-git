import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  late Future<List<dynamic>> _usersFuture;
  late Future<List<dynamic>> _rolesFuture;

  @override
  void initState() {
    super.initState();
    _refreshUsers();
    _rolesFuture = ApiService.getRoles();
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = ApiService.getAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management (Admin)')),
      body: FutureBuilder<List<dynamic>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          }
          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final roles = (user['roles'] as List?)?.map((r) => r['name']).join(', ') ?? '';
              return ListTile(
                title: Text(user['username'] ?? user['email']),
                subtitle: Text('Roles: $roles'),
                trailing: IconButton(
                  icon: const Icon(Icons.assignment_ind),
                  onPressed: () => _showAssignRoleDialog(user),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showInviteUserDialog,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Future<void> _showInviteUserDialog() async {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _usernameController = TextEditingController();
    String? _selectedRoleId;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Invite New User'),
          content: FutureBuilder<List<dynamic>>(
            future: _rolesFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final roles = snapshot.data!;
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) => value!.isEmpty ? 'Please enter an email' : null,
                    ),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                      validator: (value) => value!.isEmpty ? 'Please enter a username' : null,
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
                        _selectedRoleId = value;
                      },
                      decoration: const InputDecoration(labelText: 'Role'),
                      validator: (value) => value == null ? 'Please select a role' : null,
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
                  try {
                    await ApiService.adminAddUser(
                      email: _emailController.text,
                      username: _usernameController.text,
                      roleId: _selectedRoleId!,
                    );
                    _refreshUsers();
                    Navigator.of(context).pop();
                  } catch (e) {
                    // show error
                  }
                }
              },
              child: const Text('Invite'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAssignRoleDialog(Map<String, dynamic> user) async {
    String? _selectedRoleId;
    final _formKey = GlobalKey<FormState>();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Assign Role to ${user['username'] ?? user['email']}'),
          content: FutureBuilder<List<dynamic>>(
            future: _rolesFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final roles = snapshot.data!;
              return Form(
                key: _formKey,
                child: DropdownButtonFormField<String>(
                  value: _selectedRoleId,
                  items: roles.map<DropdownMenuItem<String>>((role) {
                    return DropdownMenuItem<String>(
                      value: role['id'],
                      child: Text(role['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _selectedRoleId = value;
                  },
                  decoration: const InputDecoration(labelText: 'Role'),
                  validator: (value) => value == null ? 'Please select a role' : null,
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
                if (_formKey.currentState!.validate() && _selectedRoleId != null) {
                  try {
                    await ApiService.adminAssignRole(user['id'], _selectedRoleId!);
                    _refreshUsers();
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