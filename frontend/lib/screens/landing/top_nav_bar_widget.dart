import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TopNavBarWidget extends StatefulWidget {
  const TopNavBarWidget({super.key});

  @override
  State<TopNavBarWidget> createState() => _TopNavBarWidgetState();
}

class _TopNavBarWidgetState extends State<TopNavBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo with hover effect
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                // Scroll to top
                Scrollable.ensureVisible(context);
              },
              child: SvgPicture.asset(
                'assets/images/company_logo.svg',
                height: 50,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
          Row(
            children: [
              _NavBarItem('Login', Icons.login),
              _NavBarItem('Pricing', Icons.attach_money),
              _NavBarItem('Contact', Icons.contact_support),
            ],
          ),
        ],
      ),
    );
  }

  Widget _NavBarItem(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            switch (title) {
              case 'Login':
                Navigator.pushNamed(context, '/login');
                break;
              case 'Pricing':
                _showPricingDialog();
                break;
              case 'Contact':
                _showContactDialog();
                break;
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.transparent,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPricingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pricing Plans'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PricingCard('Starter', '\$9/month', 'Up to 50 employees', Colors.blue),
            _PricingCard('Professional', '\$29/month', 'Up to 200 employees', Colors.green),
            _PricingCard('Enterprise', 'Custom', 'Unlimited employees', Colors.purple),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Us'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📧 Email: support@company.com'),
            SizedBox(height: 8),
            Text('📞 Phone: +1 (555) 123-4567'),
            SizedBox(height: 8),
            Text('📍 Address: 123 Business St, Tech City'),
            SizedBox(height: 16),
            Text('We\'d love to hear from you!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _PricingCard(String plan, String price, String description, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(plan, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(price, style: TextStyle(fontSize: 24, color: color, fontWeight: FontWeight.bold)),
            Text(description, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
} 