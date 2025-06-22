import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/policy_screen.dart';
import 'screens/settings_screen.dart';
import 'services/api_service.dart';
import 'services/time_format_service.dart';
import 'screens/landing_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await ApiService.initialize();
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
        // Prevent going back to login if user is already authenticated
        if (settings.name == '/login' && ApiService.isAuthenticated()) {
          return MaterialPageRoute(builder: (context) => const HomeScreen());
        }
        
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const LandingScreen());
          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (context) => const RegisterScreen());
          case '/forgot-password':
            return MaterialPageRoute(builder: (context) => const ForgotPasswordScreen());
          case '/home':
            return MaterialPageRoute(builder: (context) => const HomeScreen());
          case '/attendance':
            return MaterialPageRoute(builder: (context) => const AttendanceScreen());
          case '/policy':
            return MaterialPageRoute(builder: (context) => const PolicyScreen());
          case '/settings':
            return MaterialPageRoute(builder: (context) => const SettingsScreen());
          default:
            return MaterialPageRoute(builder: (context) => const LandingScreen());
        }
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Try to get current user to check if token is valid
      await ApiService.getCurrentUser();
      setState(() {
        _isLoggedIn = true;
        _isLoading = false;
      });
    } catch (e) {
      // Token is invalid or expired
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
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

    return _isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}
