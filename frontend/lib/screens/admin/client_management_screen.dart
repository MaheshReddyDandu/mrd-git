import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ClientManagementScreen extends StatefulWidget {
  const ClientManagementScreen({super.key});

  @override
  State<ClientManagementScreen> createState() => _ClientManagementScreenState();
}

class _ClientManagementScreenState extends State<ClientManagementScreen> {
  late Future<List<dynamic>> _clientsFuture;
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
        _clientsFuture = ApiService.listClients();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load clients: $e')),
        );
      }
    }
  }

  void _refreshClients() {
    setState(() {
      _clientsFuture = ApiService.listClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshClients,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _clientsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No clients found.'));
          }
          final clients = snapshot.data!;
          final isWide = MediaQuery.of(context).size.width > 600;
          if (isWide) {
            // Desktop/tablet: DataTable
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Industry')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: clients.map<DataRow>((client) {
                  return DataRow(cells: [
                    DataCell(Text(client['name'] ?? '')),
                    DataCell(Text(client['contact_email'] ?? '')),
                    DataCell(Text(client['contact_phone'] ?? '')),
                    DataCell(Text(client['industry'] ?? '')),
                    DataCell(Text(client['status'] ?? '')),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit',
                          onPressed: () => _showClientDialog(client: client),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Delete',
                          onPressed: () => _deleteClient(client['id']),
                        ),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            );
          } else {
            // Mobile: Card list
            return ListView.builder(
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(client['name'] ?? ''),
                    subtitle: Text(client['contact_email'] ?? ''),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showClientDialog(client: client);
                        } else if (value == 'delete') {
                          _deleteClient(client['id']);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showClientDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Client'),
      ),
    );
  }

  Future<void> _showClientDialog({Map<String, dynamic>? client}) async {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: client?['name']);
    final _emailController = TextEditingController(text: client?['contact_email']);
    final _phoneController = TextEditingController(text: client?['contact_phone']);
    final _addressController = TextEditingController(text: client?['address']);
    final _industryController = TextEditingController(text: client?['industry']);
    String _status = client?['status'] ?? 'active';
    final isEditing = client != null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Client' : 'Add Client'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Contact Email'),
                    validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Contact Phone'),
                  ),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  TextFormField(
                    controller: _industryController,
                    decoration: const InputDecoration(labelText: 'Industry'),
                  ),
                  DropdownButtonFormField<String>(
                    value: _status,
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                      DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                    ],
                    onChanged: (v) => _status = v ?? 'active',
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                ],
              ),
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
                  final data = {
                    'name': _nameController.text,
                    'contact_email': _emailController.text,
                    'contact_phone': _phoneController.text,
                    'address': _addressController.text,
                    'industry': _industryController.text,
                    'status': _status,
                  };
                  try {
                    if (isEditing) {
                      await ApiService.updateClient(client!['id'], data);
                    } else {
                      await ApiService.createClient(data);
                    }
                    if (mounted) {
                      Navigator.of(context).pop();
                      _refreshClients();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isEditing ? 'Client updated' : 'Client added')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                }
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteClient(String clientId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Client'),
        content: const Text('Are you sure you want to delete this client?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ApiService.deleteClient(clientId);
        _refreshClients();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Client deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
} 