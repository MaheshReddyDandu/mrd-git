import 'package:flutter/material.dart';
import 'policy_assignment_screen.dart';
import 'effective_policy_viewer_screen.dart';
import '../policy_screen.dart';

class PolicyManagementDashboard extends StatelessWidget {
  const PolicyManagementDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Policy Management'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          _buildDashboardCard(
            context,
            icon: Icons.list_alt,
            title: 'Manage Policies',
            subtitle: 'Create, edit, and view all company policies',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PolicyScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.assignment_add,
            title: 'Assign Policies',
            subtitle: 'Assign policies to employees, departments, or branches',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PolicyAssignmentScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.shield_outlined,
            title: 'Effective Policy Viewer',
            subtitle: 'See which policies apply to a specific employee',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EffectivePolicyViewerScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
} 