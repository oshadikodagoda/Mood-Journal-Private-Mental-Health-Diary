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
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE8F3E9),
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('🌿', style: TextStyle(fontSize: 42))),
            ),
            const SizedBox(height: 16),
            Text("Mood Journal", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 4),
            Text("Version 1.0.0 (Release Build)", style: TextStyle(fontSize: 13, color: subtextColor)),
            const SizedBox(height: 24),

            // Group 28 Team Credits Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.groups_outlined, color: accentColor, size: 22),
                      const SizedBox(width: 8),
                      Text("Project Team (Group 28)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
                    ],
                  ),
                  const Divider(height: 20),
                  Text("• Dilrukshi R.T. (EG/2023/5565)", style: TextStyle(fontSize: 13, color: textColor)),
                  const SizedBox(height: 6),
                  Text("• Kodagoda O.D. (EG/2023/5683)", style: TextStyle(fontSize: 13, color: textColor)),
                  const SizedBox(height: 6),
                  Text("• Sewmini H.K.T. (EG/2023/5886)", style: TextStyle(fontSize: 13, color: textColor)),
                  const SizedBox(height: 12),
                  Text("Faculty of Engineering • University of Ruhuna", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: subtextColor)),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.shield_outlined, color: textColor, size: 22),
                    title: Text("Privacy-First & Offline", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
                    subtitle: Text("All journal data stored locally in SQLite", style: TextStyle(fontSize: 12, color: subtextColor)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            Text(
              "\"A calmer mind builds a brighter tomorrow ✨\"",
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic, color: accentColor, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
