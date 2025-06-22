import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

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
            _AnimatedBackground(),
            // Main content
            SingleChildScrollView(
              child: Column(
                children: [
                  TopNavBar(),
                  HeroSection(onLearnMore: _scrollToFeatures),
                  const SizedBox(height: 80),
                  const StatisticsSection(),
                  const SizedBox(height: 80),
                  FeatureCarousel(key: _featuresKey),
                  const SizedBox(height: 80),
                  const TestimonialsSection(),
                  const SizedBox(height: 80),
                  const FooterSection(),
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

class _AnimatedBackground extends StatefulWidget {
  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(20, (index) => AnimationController(
      duration: Duration(seconds: 3 + (index % 5)),
      vsync: this,
    ));
    _animations = _controllers.map((controller) => 
      Tween<double>(begin: 0.0, end: 1.0).animate(controller)
    ).toList();
    
    for (var controller in _controllers) {
      controller.repeat();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: List.generate(20, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Positioned(
                left: (index * 50.0) % MediaQuery.of(context).size.width,
                top: (_animations[index].value * MediaQuery.of(context).size.height),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class TopNavBar extends StatefulWidget {
  const TopNavBar({super.key});

  @override
  State<TopNavBar> createState() => _TopNavBarState();
}

class _TopNavBarState extends State<TopNavBar> {
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

class HeroSection extends StatelessWidget {
  const HeroSection({super.key, required this.onLearnMore});

  final VoidCallback onLearnMore;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue.shade800,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                ),
                child: const Text('Get Started Free', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 20),
              OutlinedButton(
                onPressed: onLearnMore,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Learn More', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatisticsSection extends StatelessWidget {
  const StatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(
            number,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
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
    return Column(
      children: [
        const Text(
          'Powerful Features',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Everything you need to manage your workforce effectively',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 50),
        SizedBox(
          height: 280,
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final String quote;
  final Color color;
  final IconData icon;

  const FeatureCard({
    super.key,
    required this.title,
    required this.quote,
    required this.color,
    required this.icon,
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
                Icon(icon, color: Colors.white, size: 32),
                const SizedBox(height: 16),
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

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          const Text(
            'What Our Customers Say',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 50),
          Row(
            children: [
              Expanded(
                child: _TestimonialCard(
                  'Sarah Johnson',
                  'HR Manager',
                  'This platform has revolutionized how we manage attendance. The GPS tracking and automated workflows save us hours every week.',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _TestimonialCard(
                  'Mike Chen',
                  'Operations Director',
                  'The policy engine is incredibly flexible. We can now enforce different rules for different departments seamlessly.',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _TestimonialCard(
                  'Emily Rodriguez',
                  'CEO',
                  'The analytics dashboard gives us insights we never had before. It\'s like having a crystal ball for workforce management.',
                  Colors.purple,
                ),
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

  const _TestimonialCard(this.name, this.role, this.quote, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"$quote"',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                child: Text(
                  name[0],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    role,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

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