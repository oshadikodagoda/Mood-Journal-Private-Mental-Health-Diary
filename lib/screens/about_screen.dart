import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;
    final scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFFAF6EF);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "About",
          style: TextStyle(
            color: textColor,
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
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE8F3E9),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🌿', style: TextStyle(fontSize: 42)),
              ),
            ),
            const SizedBox(height: 16),

            // App Name & Version
            Text(
              "Mood Journal",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Version 1.0.0 (Build 12)",
              style: TextStyle(fontSize: 13, color: subtextColor),
            ),

            const SizedBox(height: 32),

            // Links Card
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildTile(context, Icons.shield_outlined, "Privacy Policy", "Your data stays on your device.", textColor, subtextColor, isDark, accentColor),
                  Divider(height: 1, indent: 56, endIndent: 16, color: isDark ? Colors.white12 : Colors.black12),
                  _buildTile(context, Icons.description_outlined, "Terms of Use", "Standard academic use terms.", textColor, subtextColor, isDark, accentColor),
                  Divider(height: 1, indent: 56, endIndent: 16, color: isDark ? Colors.white12 : Colors.black12),
                  _buildTile(context, Icons.star_outline, "Rate Mood Journal", "Thank you for supporting us!", textColor, subtextColor, isDark, accentColor),
                  Divider(height: 1, indent: 56, endIndent: 16, color: isDark ? Colors.white12 : Colors.black12),
                  _buildTile(context, Icons.favorite_border, "Share with a friend", "Help others build mindfulness.", textColor, subtextColor, isDark, accentColor),
                  Divider(height: 1, indent: 56, endIndent: 16, color: isDark ? Colors.white12 : Colors.black12),
                  _buildTile(context, Icons.mail_outline, "Contact Support", "Created for EC5208 Project.", textColor, subtextColor, isDark, accentColor),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Footer
            Text(
              "\"A calmer mind builds a brighter tomorrow ✨\"",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: accentColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Made with care • 2026 Mood Journal",
              style: TextStyle(fontSize: 12, color: subtextColor),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, 
    IconData icon, 
    String title, 
    String message, 
    Color textColor, 
    Color subtextColor,
    bool isDark,
    Color accentColor,
  ) {
    return ListTile(
      leading: Icon(icon, color: textColor, size: 22),
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textColor)),
      trailing: Icon(Icons.chevron_right, color: isDark ? Colors.white38 : Colors.black38, size: 20),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: accentColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}