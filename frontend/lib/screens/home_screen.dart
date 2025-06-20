import 'package:flutter/material.dart';
import 'employee_screen.dart';
import 'attendance_screen.dart';
import 'policy_screen.dart';
import 'regularization_screen.dart';
import 'analytics_screen.dart';
import 'change_password_screen.dart';
import '../services/api_service.dart';
import 'organization/organization_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'policy_management/policy_management_dashboard.dart';
import 'notifications/notification_list_screen.dart';

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
  int _unreadCount = 0;

  final List<Widget> _screens = const [
    EmployeeScreen(),
    AttendanceScreen(),
    PolicyScreen(),
    RegularizationScreen(),
    AnalyticsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchUnreadNotifications();
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

  Future<void> _fetchUnreadNotifications() async {
    try {
      final user = _userData ?? await ApiService.getCurrentUser();
      final tenantId = user['tenant_id'];
      final notifs = await ApiService.listNotifications(tenantId, onlyUnread: true);
      setState(() => _unreadCount = notifs.length);
    } catch (e) {
      setState(() => _unreadCount = 0);
    }
  }

  void _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationListScreen()),
    );
    _fetchUnreadNotifications();
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
    final isEmployee = roles.contains('user');

    // Navigation items (show/hide based on role)
    final navItems = <NavigationDestination>[];
    final navScreens = <Widget>[];
    if (isAdmin) {
      navItems.add(const NavigationDestination(icon: Icon(Icons.business_center), label: 'Organization'));
      navScreens.add(const OrganizationScreen());
    }
    if (isAdmin || isManager) {
      navItems.add(const NavigationDestination(icon: Icon(Icons.people), label: 'Employees'));
      navScreens.add(const EmployeeScreen());
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
    if (isAdmin) {
      navItems.add(const NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Admin'));
      navScreens.add(const AdminDashboardScreen());
    }

    // Responsive: Sidebar for wide screens, bottom nav for mobile
    final isWide = MediaQuery.of(context).size.width > 700;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: _openNotifications,
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$_unreadCount',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'change_password') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'change_password',
                child: Text('Change Password'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Row(
          children: [
          if (isWide)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onNavTap,
              labelType: NavigationRailLabelType.all,
              destinations: navItems
                  .map((item) => NavigationRailDestination(
                        icon: item.icon,
                        label: Text(item.label ?? ''),
                      ))
                  .toList(),
                    ),
          Expanded(child: navScreens[_selectedIndex]),
                  ],
                ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onNavTap,
              destinations: navItems,
      ),
    );
  }

  Widget _buildAdminSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Dashboard',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                print('Fetching all users...');
                try {
                  final users = await ApiService.getAllUsers();
                  print('Users fetched: $users');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Found ${users.length} users'),
                      ),
                    );
                  }
                } catch (e) {
                  print('Error fetching users: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                      ),
                    );
                  }
                }
              },
              child: const Text('View All Users'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagerSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manager Dashboard',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                print('Accessing manager dashboard...');
                try {
                  final dashboard = await ApiService.getManagerDashboard();
                  print('Dashboard data: $dashboard');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(dashboard['message'] ?? 'Dashboard accessed'),
                      ),
                    );
                  }
                } catch (e) {
                  print('Error accessing dashboard: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Access Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Profile',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                print('Accessing user profile...');
                try {
                  final profile = await ApiService.getUserProfile();
                  print('Profile data: $profile');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(profile['message'] ?? 'Profile accessed'),
                      ),
                    );
                  }
                } catch (e) {
                  print('Error accessing profile: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                      ),
                    );
                  }
                }
              },
              child: const Text('View Profile'),
            ),
          ],
        ),
      ),
    );
  }
} 