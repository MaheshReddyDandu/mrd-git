import 'package:flutter/material.dart';

class TestimonialsSectionWidget extends StatelessWidget {
  const TestimonialsSectionWidget({super.key});

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
            'What Our Customers Say',
            style: TextStyle(
              fontSize: isMobile ? 28 : (isTablet ? 32 : 36),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: isMobile ? 40 : 50),
          isMobile
              ? Column(
                  children: [
                    _TestimonialCard(
                      'Sarah Johnson',
                      'HR Manager',
                      'This platform has revolutionized how we manage attendance. The GPS tracking and automated workflows save us hours every week.',
                      Colors.blue,
                      isMobile: true,
                    ),
                    const SizedBox(height: 20),
                    _TestimonialCard(
                      'Mike Chen',
                      'Operations Director',
                      'The policy engine is incredibly flexible. We can now enforce different rules for different departments seamlessly.',
                      Colors.green,
                      isMobile: true,
                    ),
                    const SizedBox(height: 20),
                    _TestimonialCard(
                      'Emily Rodriguez',
                      'CEO',
                      'The analytics dashboard gives us insights we never had before. It\'s like having a crystal ball for workforce management.',
                      Colors.purple,
                      isMobile: true,
                    ),
                  ],
                )
              : Wrap(
                  spacing: isTablet ? 20 : 24,
                  runSpacing: isTablet ? 20 : 24,
                  alignment: WrapAlignment.center,
                  children: [
                    _TestimonialCard(
                      'Sarah Johnson',
                      'HR Manager',
                      'This platform has revolutionized how we manage attendance. The GPS tracking and automated workflows save us hours every week.',
                      Colors.blue,
                      isMobile: false,
                    ),
                    _TestimonialCard(
                      'Mike Chen',
                      'Operations Director',
                      'The policy engine is incredibly flexible. We can now enforce different rules for different departments seamlessly.',
                      Colors.green,
                      isMobile: false,
                    ),
                    _TestimonialCard(
                      'Emily Rodriguez',
                      'CEO',
                      'The analytics dashboard gives us insights we never had before. It\'s like having a crystal ball for workforce management.',
                      Colors.purple,
                      isMobile: false,
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String name;
  final String role;
  final String quote;
  final Color color;
  final bool isMobile;

  const _TestimonialCard(this.name, this.role, this.quote, this.color, {required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isMobile ? double.infinity : null,
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"$quote"',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: isMobile ? 16 : 20,
                child: Text(
                  name[0],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 10 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 14 : 16,
                      ),
                    ),
                    Text(
                      role,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: isMobile ? 12 : 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 