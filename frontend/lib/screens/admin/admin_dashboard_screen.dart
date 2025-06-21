import 'package:flutter/material.dart';
import 'admin_tenant_screen.dart';
import 'user_management_screen.dart';
import 'audit_log_screen.dart';
import 'reports_screen.dart';
import 'client_management_screen.dart';
import 'project_management_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          _buildDashboardCard(
            context,
            icon: Icons.business_center,
            title: 'Tenant Management',
            subtitle: 'Manage SaaS tenants, plans, and usage',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminTenantScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.people_alt,
            title: 'User Management',
            subtitle: 'Invite users and assign roles',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserManagementScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.business,
            title: 'Client Management',
            subtitle: 'Manage client companies and their details',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ClientManagementScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.work,
            title: 'Project Management',
            subtitle: 'Manage projects and their assignments',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProjectManagementScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.bar_chart,
            title: 'Reports',
            subtitle: 'Attendance and activity reports',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportsScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.history,
            title: 'Audit Logs',
            subtitle: 'View system and user activity logs',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AuditLogScreen()),
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