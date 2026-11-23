import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EF), // Soft cream
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF6EF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "About",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // App Sprout Icon
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F3E9),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🌿', style: TextStyle(fontSize: 42)),
              ),
            ),
            const SizedBox(height: 16),

            // App Name & Version
            const Text(
              "Mood Journal",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Version 1.0.0 (Build 12)",
              style: TextStyle(fontSize: 13, color: Colors.black45),
            ),

            const SizedBox(height: 32),

            // Links Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildTile(context, Icons.shield_outlined, "Privacy Policy", "Your data stays on your device."),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _buildTile(context, Icons.description_outlined, "Terms of Use", "Standard academic use terms."),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _buildTile(context, Icons.star_outline, "Rate Mood Journal", "Thank you for supporting us!"),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _buildTile(context, Icons.favorite_border, "Share with a friend", "Help others build mindfulness."),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _buildTile(context, Icons.mail_outline, "Contact Support", "Created for EC5208 Project."),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Footer
            const Text(
              "\"A calmer mind builds a brighter tomorrow ✨\"",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Color(0xFF6E8F68),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Made with care • 2026 Mood Journal",
              style: TextStyle(fontSize: 12, color: Colors.black38),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String title, String message) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.black38, size: 20),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFF6E8F68),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}