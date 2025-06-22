import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:async';

class FeatureCarouselWidget extends StatefulWidget {
  const FeatureCarouselWidget({super.key});

  @override
  State<FeatureCarouselWidget> createState() => _FeatureCarouselWidgetState();
}

class _FeatureCarouselWidgetState extends State<FeatureCarouselWidget> {
  final PageController _pageController = PageController(viewportFraction: 0.3);
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> features = [
    {
      'title': 'Real-Time Attendance',
      'quote': 'Track clock-ins and outs with GPS precision, ensuring accurate timekeeping from anywhere.',
      'color': Colors.teal,
      'icon': Icons.access_time,
    },
    {
      'title': 'Smart Policy Engine',
      'quote': 'Define custom time, leave, and calendar policies that are automatically enforced.',
      'color': Colors.amber,
      'icon': Icons.policy,
    },
    {
      'title': 'GPS Geofencing',
      'quote': 'Restrict attendance marking to specific geographical locations for enhanced security.',
      'color': Colors.pink,
      'icon': Icons.location_on,
    },
    {
      'title': 'Automated Workflows',
      'quote': 'Streamline regularization and leave requests with multi-level approval chains.',
      'color': Colors.cyan,
      'icon': Icons.auto_awesome,
    },
    {
      'title': 'Insightful Analytics',
      'quote': 'Get a clear view of your workforce patterns with comprehensive reports and dashboards.',
      'color': Colors.deepOrange,
      'icon': Icons.analytics,
    },
    {
      'title': 'Employee Self-Service',
      'quote': 'Empower your team to manage their attendance, requests, and policies with ease.',
      'color': Colors.lightGreen,
      'icon': Icons.self_improvement,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 48),
      child: Column(
        children: [
          Text(
            'Powerful Features',
            style: TextStyle(
              fontSize: isMobile ? 28 : (isTablet ? 32 : 36),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            'Everything you need to manage your workforce effectively',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: isMobile ? 40 : 50),
          SizedBox(
            height: isMobile ? 320 : 280,
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
                    icon: features[index]['icon'],
                    isMobile: isMobile,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final String quote;
  final Color color;
  final IconData icon;
  final bool isMobile;

  const FeatureCard({
    super.key,
    required this.title,
    required this.quote,
    required this.color,
    required this.icon,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16),
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
            padding: EdgeInsets.all(isMobile ? 20 : 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    color: Colors.black54,
                    size: isMobile ? 28 : 32,
                  ),
                  SizedBox(height: isMobile ? 12 : 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: isMobile ? 12 : 16),
                  Text(
                    '"$quote"',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: Colors.black54,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 