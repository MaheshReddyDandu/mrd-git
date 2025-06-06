import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _error;

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${_userData?['username'] ?? 'User'}!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email: ${_userData?['email'] ?? 'N/A'}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Roles: ${_userData?['roles']?.map((r) => r['name']).join(', ') ?? 'User'}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_userData?['roles']?.any((r) => r['name'] == 'admin') ?? false)
              _buildAdminSection(),
            if (_userData?['roles']?.any((r) => r['name'] == 'manager') ?? false)
              _buildManagerSection(),
            _buildUserSection(),
          ],
        ),
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