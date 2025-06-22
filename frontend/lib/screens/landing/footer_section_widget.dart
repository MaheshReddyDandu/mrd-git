import 'package:flutter/material.dart';

class FooterSectionWidget extends StatelessWidget {
  const FooterSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: isMobile ? 40 : 60,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.1)),
        ),
      ),
      child: isMobile
          ? Column(
              children: [
                _FooterColumn(
                  'Company',
                  ['About Us', 'Careers', 'Press', 'Blog'],
                  isMobile: true,
                ),
                const SizedBox(height: 32),
                _FooterColumn(
                  'Product',
                  ['Features', 'Pricing', 'Security', 'API'],
                  isMobile: true,
                ),
                const SizedBox(height: 32),
                _FooterColumn(
                  'Support',
                  ['Help Center', 'Contact', 'Status', 'Documentation'],
                  isMobile: true,
                ),
                const SizedBox(height: 32),
                _FooterColumn(
                  'Legal',
                  ['Privacy', 'Terms', 'Cookies', 'Licenses'],
                  isMobile: true,
                ),
                const SizedBox(height: 40),
                const Divider(color: Colors.black12),
                const SizedBox(height: 24),
                Text(
                  '© 2024 Company Name. All rights reserved.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: isMobile ? 12 : 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _FooterColumn(
                      'Company',
                      ['About Us', 'Careers', 'Press', 'Blog'],
                      isMobile: false,
                    ),
                    _FooterColumn(
                      'Product',
                      ['Features', 'Pricing', 'Security', 'API'],
                      isMobile: false,
                    ),
                    _FooterColumn(
                      'Support',
                      ['Help Center', 'Contact', 'Status', 'Documentation'],
                      isMobile: false,
                    ),
                    _FooterColumn(
                      'Legal',
                      ['Privacy', 'Terms', 'Cookies', 'Licenses'],
                      isMobile: false,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const Divider(color: Colors.black12),
                const SizedBox(height: 24),
                Text(
                  '© 2024 Company Name. All rights reserved.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ],
            ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> items;
  final bool isMobile;

  const _FooterColumn(this.title, this.items, {required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isMobile ? double.infinity : null,
      child: Column(
        crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.black87,
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          ...items.map((item) => Padding(
                padding: EdgeInsets.only(bottom: isMobile ? 8 : 6),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      // Handle footer link clicks
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$item clicked')),
                      );
                    },
                    child: Text(
                      item,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: isMobile ? 14 : 16,
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
} 