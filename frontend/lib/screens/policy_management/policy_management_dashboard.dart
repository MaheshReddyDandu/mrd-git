import 'package:flutter/material.dart';
import 'policy_assignment_screen.dart';
import 'effective_policy_viewer_screen.dart';
import '../policy_screen.dart';
import 'calendar_policy_screen.dart';
import 'time_policy_screen.dart';
import 'leave_policy_screen.dart';

class PolicyManagementDashboard extends StatelessWidget {
  const PolicyManagementDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Policy Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDashboardCard(
            context,
            icon: Icons.list_alt,
            title: 'General Policies',
            subtitle: 'Create, edit, and view all company policies',
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PolicyScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.calendar_today,
            title: 'Calendar Policy',
            subtitle: 'Manage holidays, week-offs, and working days',
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarPolicyScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.access_time,
            title: 'Time Policy',
            subtitle: 'Configure working hours, flexible time, WFH, and hybrid modes',
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TimePolicyScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.beach_access,
            title: 'Leave Policy',
            subtitle: 'Manage leave types, balances, and approval workflows',
            color: Colors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LeavePolicyScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.assignment_add,
            title: 'Assign Policies',
            subtitle: 'Assign policies to users, departments, or branches',
            color: Colors.teal,
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
            subtitle: 'See which policies apply to a specific user',
            color: Colors.indigo,
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
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
} 