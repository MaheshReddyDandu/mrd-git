import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ProjectManagementScreen extends StatefulWidget {
  const ProjectManagementScreen({super.key});

  @override
  State<ProjectManagementScreen> createState() => _ProjectManagementScreenState();
}

class _ProjectManagementScreenState extends State<ProjectManagementScreen> {
  late Future<List<dynamic>> _projectsFuture;
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
        _projectsFuture = ApiService.listProjects();
        _clientsFuture = ApiService.listClients();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load projects: $e')),
        );
      }
    }
  }

  void _refreshProjects() {
    setState(() {
      _projectsFuture = ApiService.listProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProjects,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _projectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No projects found.'));
          }
          final projects = snapshot.data!;
          final isWide = MediaQuery.of(context).size.width > 600;
          if (isWide) {
            // Desktop/tablet: DataTable
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Client')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Start Date')),
                  DataColumn(label: Text('End Date')),
                  DataColumn(label: Text('Budget')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: projects.map<DataRow>((project) {
                  return DataRow(cells: [
                    DataCell(Text(project['name'] ?? '')),
                    DataCell(Text(project['client_name'] ?? '')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(project['status']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          project['status'] ?? '',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                    DataCell(Text(project['start_date'] ?? '')),
                    DataCell(Text(project['end_date'] ?? '')),
                    DataCell(Text(project['budget'] ?? '')),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit',
                          onPressed: () => _showProjectDialog(project: project),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Delete',
                          onPressed: () => _deleteProject(project['id']),
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
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(project['name'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Client: ${project['client_name'] ?? ''}'),
                        Text('Status: ${project['status'] ?? ''}'),
                        if (project['start_date'] != null)
                          Text('Start: ${project['start_date']}'),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showProjectDialog(project: project);
                        } else if (value == 'delete') {
                          _deleteProject(project['id']);
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
        onPressed: () => _showProjectDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Project'),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'on-hold':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showProjectDialog({Map<String, dynamic>? project}) async {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: project?['name']);
    final _descriptionController = TextEditingController(text: project?['description']);
    final _budgetController = TextEditingController(text: project?['budget']);
    String? _selectedClientId = project?['client_id'];
    String _status = project?['status'] ?? 'active';
    DateTime? _startDate = project?['start_date'] != null 
        ? DateTime.parse(project!['start_date']) 
        : null;
    DateTime? _endDate = project?['end_date'] != null 
        ? DateTime.parse(project!['end_date']) 
        : null;
    final isEditing = project != null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Project' : 'Add Project'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Project Name'),
                    validator: (v) => v == null || v.isEmpty ? 'Enter project name' : null,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  FutureBuilder<List<dynamic>>(
                    future: _clientsFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      final clients = snapshot.data!;
                      return DropdownButtonFormField<String>(
                        value: _selectedClientId,
                        items: clients.map<DropdownMenuItem<String>>((client) {
                          return DropdownMenuItem<String>(
                            value: client['id'],
                            child: Text(client['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedClientId = value;
                          });
                        },
                        decoration: const InputDecoration(labelText: 'Client'),
                        validator: (v) => v == null ? 'Select a client' : null,
                      );
                    },
                  ),
                  TextFormField(
                    controller: _budgetController,
                    decoration: const InputDecoration(labelText: 'Budget'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('Start Date'),
                          subtitle: Text(_startDate?.toString().split(' ')[0] ?? 'Not set'),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              setState(() {
                                _startDate = date;
                              });
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text('End Date'),
                          subtitle: Text(_endDate?.toString().split(' ')[0] ?? 'Not set'),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              setState(() {
                                _endDate = date;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  DropdownButtonFormField<String>(
                    value: _status,
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'completed', child: Text('Completed')),
                      DropdownMenuItem(value: 'on-hold', child: Text('On Hold')),
                      DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _status = value ?? 'active';
                      });
                    },
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
                    'description': _descriptionController.text,
                    'client_id': _selectedClientId,
                    'status': _status,
                    'budget': _budgetController.text,
                    'start_date': _startDate?.toIso8601String().split('T')[0],
                    'end_date': _endDate?.toIso8601String().split('T')[0],
                  };
                  try {
                    if (isEditing) {
                      await ApiService.updateProject(project!['id'], data);
                    } else {
                      await ApiService.createProject(data);
                    }
                    if (mounted) {
                      Navigator.of(context).pop();
                      _refreshProjects();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isEditing ? 'Project updated' : 'Project added')),
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

  Future<void> _deleteProject(String projectId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text('Are you sure you want to delete this project?'),
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
        await ApiService.deleteProject(projectId);
        _refreshProjects();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project deleted')),
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