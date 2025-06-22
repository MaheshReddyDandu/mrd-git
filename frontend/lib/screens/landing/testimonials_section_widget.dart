import 'package:flutter/material.dart';

class TestimonialsSectionWidget extends StatelessWidget {
  const TestimonialsSectionWidget({super.key});

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