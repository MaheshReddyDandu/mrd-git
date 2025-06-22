import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'landing/animated_background_widget.dart';
import 'landing/top_nav_bar_widget.dart';
import 'landing/hero_section_widget.dart';
import 'landing/statistics_section_widget.dart';
import 'landing/feature_carousel_widget.dart';
import 'landing/testimonials_section_widget.dart';
import 'landing/footer_section_widget.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showMobileMenu = false;

  @override
  void initState() {
    super.initState();
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(String section) {
    // Scroll to specific section
    switch (section) {
      case 'features':
        _scrollController.animateTo(
          800,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        break;
      case 'testimonials':
        _scrollController.animateTo(
          1200,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        break;
      case 'contact':
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        break;
    }
    setState(() {
      _showMobileMenu = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      body: Stack(
        children: [
          // Light sky blue background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFB3E5FC), // Light sky blue
                  Color(0xFFE1F5FE), // Lighter blue
                ],
              ),
            ),
          ),
          // Animated background
          const AnimatedBackgroundWidget(),
          
          // Main content
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // Top navigation bar
                TopNavBarWidget(
                  isMenuOpen: _showMobileMenu,
                  onMenuToggle: () {
                    setState(() {
                      _showMobileMenu = !_showMobileMenu;
                    });
                  },
                ),
                
                // Hero section
                HeroSectionWidget(
                  onLearnMore: () => _scrollToSection('features'),
                ),
                
                // Statistics section
                const StatisticsSectionWidget(),
                
                // Feature carousel
                const FeatureCarouselWidget(),
                
                // Testimonials section
                const TestimonialsSectionWidget(),
                
                // Footer section
                const FooterSectionWidget(),
              ],
            ),
          ),
          
          // Mobile menu overlay
          if (_showMobileMenu && isMobile)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 80),
                  _MobileMenuItem(
                    'Features',
                    Icons.featured_play_list,
                    () => _scrollToSection('features'),
                  ),
                  _MobileMenuItem(
                    'Testimonials',
                    Icons.rate_review,
                    () => _scrollToSection('testimonials'),
                  ),
                  _MobileMenuItem(
                    'Contact',
                    Icons.contact_support,
                    () => _scrollToSection('contact'),
                  ),
                  const Divider(color: Colors.white24, height: 32),
                  _MobileMenuItem(
                    'Login',
                    Icons.login,
                    () {
                      setState(() {
                        _showMobileMenu = false;
                      });
                      Navigator.pushNamed(context, '/login');
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MobileMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _MobileMenuItem(this.title, this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
} 