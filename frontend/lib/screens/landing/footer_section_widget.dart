import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FooterSectionWidget extends StatelessWidget {
  const FooterSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'assets/images/company_logo.svg',
                height: 40,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              const SizedBox(height: 16),
              const Text(
                '© 2024 Your Company. All rights reserved.',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          Row(
            children: [
              _FooterLink('Privacy Policy'),
              _FooterLink('Terms of Service'),
              _FooterLink('Support'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _FooterLink(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: () {},
        child: Text(
          text,
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
} 