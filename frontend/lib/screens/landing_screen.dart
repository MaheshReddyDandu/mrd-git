import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade800,
              Colors.purple.shade800,
            ],
          ),
        ),
        child: const SingleChildScrollView(
          child: Column(
            children: [
              TopNavBar(),
              HeroSection(),
              SizedBox(height: 50),
              FeatureCarousel(),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

class TopNavBar extends StatelessWidget {
  const TopNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(
            'assets/images/company_logo.svg',
            height: 50,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          Row(
            children: [
              _NavBarItem('Login'),
              _NavBarItem('Pricing'),
              _NavBarItem('Contact'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _NavBarItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: () {},
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 80),
      child: Column(
        children: [
          const Text(
            'Modern Workforce Management, Simplified',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'The all-in-one platform for attendance, policy management, and smart workforce analytics. Elevate your team\'s productivity and streamline your HR operations effortlessly.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.blue.shade800,
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Get Started Free', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class FeatureCarousel extends StatefulWidget {
  const FeatureCarousel({super.key});

  @override
  State<FeatureCarousel> createState() => _FeatureCarouselState();
}

class _FeatureCarouselState extends State<FeatureCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.3);
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> features = [
    {
      'title': 'Real-Time Attendance',
      'quote': 'Track clock-ins and outs with GPS precision, ensuring accurate timekeeping from anywhere.',
      'color': Colors.teal,
    },
    {
      'title': 'Smart Policy Engine',
      'quote': 'Define custom time, leave, and calendar policies that are automatically enforced.',
      'color': Colors.amber,
    },
    {
      'title': 'GPS Geofencing',
      'quote': 'Restrict attendance marking to specific geographical locations for enhanced security.',
      'color': Colors.pink,
    },
    {
      'title': 'Automated Workflows',
      'quote': 'Streamline regularization and leave requests with multi-level approval chains.',
      'color': Colors.cyan,
    },
    {
      'title': 'Insightful Analytics',
      'quote': 'Get a clear view of your workforce patterns with comprehensive reports and dashboards.',
      'color': Colors.deepOrange,
    },
    {
      'title': 'Employee Self-Service',
      'quote': 'Empower your team to manage their attendance, requests, and policies with ease.',
      'color': Colors.lightGreen,
    }
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {});
    });
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < features.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 700),
        curve: Curves.ease,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: PageView.builder(
        controller: _pageController,
        itemCount: features.length,
        itemBuilder: (context, index) {
          double scale = 1.0;
          if (_pageController.position.haveDimensions) {
            double page = _pageController.page ?? 0;
            scale = (1 - ((page - index).abs() * 0.3)).clamp(0.8, 1.0);
          }
          return Transform.scale(
            scale: scale,
            child: FeatureCard(
              title: features[index]['title'],
              quote: features[index]['quote'],
              color: features[index]['color'],
            ),
          );
        },
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final String quote;
  final Color color;

  const FeatureCard({
    super.key,
    required this.title,
    required this.quote,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '"$quote"',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 