import 'package:flutter/material.dart';
import 'branch_management/branch_screen.dart';
import 'department_management/department_screen.dart';

class OrganizationScreen extends StatelessWidget {
  const OrganizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organization Setup'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Branches'),
            subtitle: const Text('Manage company branches'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BranchManagementScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.group_work),
            title: const Text('Departments'),
            subtitle: const Text('Manage company departments'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DepartmentManagementScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
} 