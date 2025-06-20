import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class EffectivePolicyViewerScreen extends StatefulWidget {
  const EffectivePolicyViewerScreen({super.key});

  @override
  State<EffectivePolicyViewerScreen> createState() => _EffectivePolicyViewerScreenState();
}

class _EffectivePolicyViewerScreenState extends State<EffectivePolicyViewerScreen> {
  late Future<List<dynamic>> _employeesFuture;
  Map<String, dynamic>? _userData;
  String? _selectedEmployeeId;
  List<dynamic>? _effectivePolicies;
  bool _isLoadingPolicies = false;

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
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load initial data: $e')),
        );
      }
    }
  }

  Future<void> _fetchEffectivePolicies() async {
    if (_selectedEmployeeId == null || _userData == null) {
      return;
    }
    setState(() {
      _isLoadingPolicies = true;
      _effectivePolicies = null;
    });
    try {
      final policies = await ApiService.getEffectivePolicy(
        _userData!['tenant_id'],
        _selectedEmployeeId!,
      );
      setState(() {
        _effectivePolicies = policies;
        _isLoadingPolicies = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPolicies = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch policies: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Effective Policy Viewer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<dynamic>>(
              future: _employeesFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Text('Could not load employees.');
                }
                final employees = snapshot.data!;
                return DropdownButtonFormField<String>(
                  value: _selectedEmployeeId,
                  items: employees.map<DropdownMenuItem<String>>((emp) {
                    return DropdownMenuItem<String>(
                      value: emp['id'],
                      child: Text(emp['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedEmployeeId = value;
                      _effectivePolicies = null; // Clear old policies
                    });
                    if (value != null) {
                      _fetchEffectivePolicies();
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Select Employee',
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text('Effective Policies', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            Expanded(
              child: _buildPolicyList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyList() {
    if (_isLoadingPolicies) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_effectivePolicies == null) {
      return const Center(child: Text('Select an employee to see their effective policies.'));
    }
    if (_effectivePolicies!.isEmpty) {
      return const Center(child: Text('No effective policies found for this employee.'));
    }
    final policies = _effectivePolicies!;
    return ListView.builder(
      itemCount: policies.length,
      itemBuilder: (context, index) {
        final policy = policies[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: Text(policy['name']),
            subtitle: Text('Type: ${policy['type']}'),
          ),
        );
      },
    );
  }
} 