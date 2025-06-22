import 'package:flutter/material.dart';

class HeroSectionWidget extends StatelessWidget {
  const HeroSectionWidget({super.key, required this.onLearnMore});

  final VoidCallback onLearnMore;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: isMobile ? 60 : 80,
      ),
      child: Column(
        children: [
          Text(
            'Modern Workforce Management, Simplified',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 32 : (isTablet ? 42 : 52),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          Text(
            'The all-in-one platform for attendance, policy management, and smart workforce analytics. Elevate your team\'s productivity and streamline your HR operations effortlessly.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: isMobile ? 32 : 40),
          Wrap(
            spacing: isMobile ? 16 : 20,
            runSpacing: isMobile ? 16 : 20,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue.shade700,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 32 : 40,
                    vertical: isMobile ? 16 : 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                ),
                child: Text(
                  'Get Started Free',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: onLearnMore,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade700,
                  side: BorderSide(color: Colors.blue.shade700),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 32 : 40,
                    vertical: isMobile ? 16 : 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Learn More',
                  style: TextStyle(fontSize: isMobile ? 14 : 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 