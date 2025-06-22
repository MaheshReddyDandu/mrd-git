import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/policy_screen.dart';
import 'screens/settings_screen.dart';
import 'services/api_service.dart';
import 'services/base_api_service.dart';
import 'services/time_format_service.dart';
import 'screens/landing_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await BaseApiService.initialize();
  await TimeFormatService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workforce Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            // Public routes accessible to everyone
            switch (settings.name) {
              case '/':
                return const LandingScreen();
              case '/login':
                return const LoginScreen();
              case '/register':
                return const RegisterScreen();
              case '/forgot-password':
                return const ForgotPasswordScreen();
            }

            // Protected routes that require authentication
            return AuthGuard(
              child: Builder(
                builder: (context) {
                  switch (settings.name) {
                    case '/home':
                      return const HomeScreen();
                    case '/attendance':
                      return const AttendanceScreen();
                    case '/policy':
                      return const PolicyScreen();
                    case '/settings':
                      return const SettingsScreen();
                    default:
                      // If route is unknown and protected, redirect to landing
                      return const LandingScreen();
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}

class AuthGuard extends StatefulWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool? _isAuthorized;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Check token existence first for a quick check
    if (!BaseApiService.isAuthenticated()) {
      setState(() {
        _isAuthorized = false;
      });
      return;
    }

    // Then, verify token validity with the server
    try {
      await ApiService.getCurrentUser();
      setState(() {
        _isAuthorized = true;
      });
    } catch (e) {
      // Token is invalid or expired
      await BaseApiService.clearToken();
      setState(() {
        _isAuthorized = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthorized == null) {
      // Loading screen while checking auth
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isAuthorized == false) {
      // Not authorized, redirect to login
      // We use a post-frame callback to avoid build-time navigation errors
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      // Show a loading indicator while redirecting
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Authorized, show the intended screen
    return widget.child;
  }
}
