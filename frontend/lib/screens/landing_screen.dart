import 'dart:ui';
import 'package:flutter/material.dart';
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

class _LandingScreenState extends State<LandingScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final GlobalKey _featuresKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _scrollToFeatures() {
    final RenderBox renderBox = _featuresKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    Scrollable.ensureVisible(
      _featuresKey.currentContext!,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900,
              Colors.purple.shade900,
              Colors.indigo.shade800,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            const AnimatedBackgroundWidget(),
            // Main content
            SingleChildScrollView(
              child: Column(
                children: [
                  const TopNavBarWidget(),
                  HeroSectionWidget(onLearnMore: _scrollToFeatures),
                  const SizedBox(height: 80),
                  const StatisticsSectionWidget(),
                  const SizedBox(height: 80),
                  FeatureCarouselWidget(key: _featuresKey),
                  const SizedBox(height: 80),
                  const TestimonialsSectionWidget(),
                  const SizedBox(height: 80),
                  const FooterSectionWidget(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 