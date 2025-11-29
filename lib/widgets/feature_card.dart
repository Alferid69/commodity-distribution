import 'package:flutter/material.dart';

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // The Icon with a circular background
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1), // Light, pastel background
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 32),
        ),
        const SizedBox(height: 16.0),
        // The Title
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 8.0),
        // The Description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
