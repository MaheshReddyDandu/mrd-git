import 'package:flutter/material.dart';

class StatisticsSectionWidget extends StatelessWidget {
  const StatisticsSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 48),
      child: isMobile
          ? Column(
              children: [
                _StatCard('10K+', 'Active Users', Icons.people),
                const SizedBox(height: 16),
                _StatCard('500+', 'Companies', Icons.business),
                const SizedBox(height: 16),
                _StatCard('99.9%', 'Uptime', Icons.trending_up),
                const SizedBox(height: 16),
                _StatCard('24/7', 'Support', Icons.support_agent),
              ],
            )
          : Wrap(
              spacing: isTablet ? 16 : 24,
              runSpacing: isTablet ? 16 : 24,
              alignment: WrapAlignment.spaceAround,
              children: [
                _StatCard('10K+', 'Active Users', Icons.people),
                _StatCard('500+', 'Companies', Icons.business),
                _StatCard('99.9%', 'Uptime', Icons.trending_up),
                _StatCard('24/7', 'Support', Icons.support_agent),
              ],
            ),
    );
  }

  Widget _StatCard(String number, String label, IconData icon) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1024;
        
        return Container(
          width: isMobile ? double.infinity : (isTablet ? 160 : 200),
          padding: EdgeInsets.all(isMobile ? 20 : 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.7)),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: Colors.black54,
                size: isMobile ? 28 : 32,
              ),
              SizedBox(height: isMobile ? 6 : 8),
              Text(
                number,
                style: TextStyle(
                  fontSize: isMobile ? 28 : 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 