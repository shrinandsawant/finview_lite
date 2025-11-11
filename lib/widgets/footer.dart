import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.onPrimary; // contrast with kiwi
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      width: double.infinity,
      color: const Color(0xFF8DB600), // same kiwi as header
      padding: const EdgeInsets.symmetric(
        vertical: 16,
      ), // no horizontal padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // CTA + Social icons
          isSmallScreen
              ? Column(
                  children: [
                    Text(
                      'Track your portfolio easily with FinView Lite',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // readable on kiwi
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _socialIcon(Icons.public, iconColor),
                        const SizedBox(width: 12),
                        _socialIcon(Icons.chat, iconColor),
                        const SizedBox(width: 12),
                        _socialIcon(Icons.work, iconColor),
                        const SizedBox(width: 12),
                        _socialIcon(Icons.camera_alt, iconColor),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Track your portfolio easily with FinView Lite',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // readable on kiwi
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        _socialIcon(Icons.public, iconColor),
                        const SizedBox(width: 12),
                        _socialIcon(Icons.chat, iconColor),
                        const SizedBox(width: 12),
                        _socialIcon(Icons.work, iconColor),
                        const SizedBox(width: 12),
                        _socialIcon(Icons.camera_alt, iconColor),
                      ],
                    ),
                  ],
                ),
          const SizedBox(height: 12),
          // Rights
          Text(
            '© 2025 FinView Lite • All rights reserved.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}
