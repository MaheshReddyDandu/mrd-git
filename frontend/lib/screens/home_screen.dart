import 'package:flutter/material.dart';
import 'user_screen.dart';
import 'attendance_screen.dart';
import 'policy_screen.dart';
import 'regularization_screen.dart';
import 'analytics_screen.dart';
import 'change_password_screen.dart';
import '../services/api_service.dart';
import 'organization/organization_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'policy_management/policy_management_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _error;
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    UserScreen(),
    AttendanceScreen(),
    PolicyScreen(),
    RegularizationScreen(),
    AnalyticsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      print('Loading user data...');
      final userData = await ApiService.getCurrentUser();
      print('User data loaded: $userData');
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    print('Logging out...');
    // Clear token
    ApiService.setToken('');
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _logout,
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      );
    }

    // Determine user roles
    final roles = (_userData?['roles'] as List?)?.map((r) => r['name'] as String).toList() ?? [];
    final isAdmin = roles.contains('admin') || roles.contains('owner');
    final isManager = roles.contains('manager');
    final isUser = roles.contains('user');

    // Navigation items (show/hide based on role)
    final navItems = <NavigationDestination>[];
    final navScreens = <Widget>[];
    if (isAdmin) {
      navItems.add(const NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Admin'));
      navScreens.add(const AdminDashboardScreen());
    }
    if (isAdmin) {
      navItems.add(const NavigationDestination(icon: Icon(Icons.business_center), label: 'Organization'));
      navScreens.add(const OrganizationScreen());
    }
    if (isAdmin || isManager) {
      navItems.add(const NavigationDestination(icon: Icon(Icons.people), label: 'Users'));
      navScreens.add(const UserScreen());
    }
    navItems.add(const NavigationDestination(icon: Icon(Icons.access_time), label: 'Attendance'));
    navScreens.add(const AttendanceScreen());
    if (isAdmin || isManager) {
      navItems.add(const NavigationDestination(icon: Icon(Icons.policy), label: 'Policies'));
      navScreens.add(const PolicyManagementDashboard());
    }
    navItems.add(const NavigationDestination(icon: Icon(Icons.edit_note), label: 'Regularization'));
    navScreens.add(const RegularizationScreen());
    navItems.add(const NavigationDestination(icon: Icon(Icons.analytics), label: 'Analytics'));
    navScreens.add(const AnalyticsScreen());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Tenant SaaS'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                  );
                  break;
                case 'logout':
                  _logout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Change Password'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: navScreens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onNavTap,
        destinations: navItems,
      ),
    );
  }
} 