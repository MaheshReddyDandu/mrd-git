import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class BranchManagementScreen extends StatefulWidget {
  const BranchManagementScreen({super.key});

  @override
  State<BranchManagementScreen> createState() => _BranchManagementScreenState();
}

class _BranchManagementScreenState extends State<BranchManagementScreen> {
  late Future<List<dynamic>> _branchesFuture;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFetchBranches();
  }

  Future<void> _loadUserDataAndFetchBranches() async {
    try {
      final userData = await ApiService.getCurrentUser();
      setState(() {
        _userData = userData;
        _branchesFuture = ApiService.listBranches(userData['tenant_id']);
      });
    } catch (e) {
      // Handle error
    }
  }

  void _refreshBranches() {
    if (_userData != null) {
      setState(() {
        _branchesFuture = ApiService.listBranches(_userData!['tenant_id']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Branch Management'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _branchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No branches found.'));
          }

          final branches = snapshot.data!;
          return ListView.builder(
            itemCount: branches.length,
            itemBuilder: (context, index) {
              final branch = branches[index];
              return ListTile(
                title: Text(branch['name']),
                subtitle: Text(branch['address'] ?? 'No address'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showBranchDialog(branch: branch),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteBranch(branch['id']),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBranchDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showBranchDialog({Map<String, dynamic>? branch}) async {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: branch?['name']);
    final _addressController = TextEditingController(text: branch?['address']);
    final isEditing = branch != null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Branch' : 'Add Branch'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Branch Name'),
                  validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
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
                  final branchData = {
                    'name': _nameController.text,
                    'address': _addressController.text,
                  };

                  try {
                    if (isEditing) {
                      await ApiService.updateBranch(_userData!['tenant_id'], branch!['id'], branchData);
                    } else {
                      await ApiService.createBranch(_userData!['tenant_id'], branchData);
                    }
                    _refreshBranches();
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

  Future<void> _deleteBranch(String branchId) async {
    try {
      await ApiService.deleteBranch(_userData!['tenant_id'], branchId);
      _refreshBranches();
    } catch (e) {
      // show error
    }
  }
} 