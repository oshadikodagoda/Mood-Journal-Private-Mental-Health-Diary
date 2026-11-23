import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/user_profile.dart';
import 'privacy_security_screen.dart';
import 'reminders_screen.dart';
import 'appearance_screen.dart';
import 'export_data_screen.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseService _db = DatabaseService();
  String _userName = 'Oshadi';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final UserProfile profile = await _db.getUserProfile();
      if (mounted) {
        setState(() {
          _userName = profile.name.isNotEmpty ? profile.name : 'Oshadi';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showEditNameDialog(Color accentColor, Color cardBg, Color textColor) async {
    final TextEditingController nameController = TextEditingController(text: _userName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Edit Name", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        content: TextField(
          controller: nameController,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: "Enter your name",
            hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: accentColor),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: textColor.withOpacity(0.6))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                final currentProfile = await _db.getUserProfile();
                final updated = UserProfile(
                  userId: currentProfile.userId,
                  name: newName,
                  appLockEnabled: currentProfile.appLockEnabled,
                  pinCode: currentProfile.pinCode,
                );
                await _db.updateUserProfile(updated);
                setState(() => _userName = newName);
              }
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

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
          "Settings",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: accentColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- User Profile Header ---
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE8F3E9),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text('🌿', style: TextStyle(fontSize: 24)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Private Mental Health Diary",
                                style: TextStyle(fontSize: 12, color: subtextColor),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit_outlined, color: accentColor, size: 22),
                          onPressed: () => _showEditNameDialog(accentColor, cardBg, textColor),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- Group 1: Account & Privacy ---
                  _buildSectionHeader("Account & Privacy", subtextColor),
                  const SizedBox(height: 8),
                  _buildCardGroup(cardBg, [
                    _buildSettingsTile(
                      icon: Icons.shield_outlined,
                      title: "Privacy & Security",
                      textColor: textColor,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()),
                        );
                      },
                    ),
                    Divider(height: 1, indent: 56, endIndent: 16, color: isDark ? Colors.white12 : Colors.black12),
                    _buildSettingsTile(
                      icon: Icons.lock_outline,
                      title: "App Lock",
                      textColor: textColor,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // --- Group 2: Preferences ---
                  _buildSectionHeader("Preferences", subtextColor),
                  const SizedBox(height: 8),
                  _buildCardGroup(cardBg, [
                    _buildSettingsTile(
                      icon: Icons.notifications_none_outlined,
                      title: "Reminders",
                      textColor: textColor,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RemindersScreen()),
                        );
                      },
                    ),
                    Divider(height: 1, indent: 56, endIndent: 16, color: isDark ? Colors.white12 : Colors.black12),
                    _buildSettingsTile(
                      icon: Icons.light_mode_outlined,
                      title: "Appearance",
                      textColor: textColor,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AppearanceScreen()),
                        );
                      },
                    ),
                    Divider(height: 1, indent: 56, endIndent: 16, color: isDark ? Colors.white12 : Colors.black12),
                    _buildSettingsTile(
                      icon: Icons.menu_book_outlined,
                      title: "Journal Preferences",
                      textColor: textColor,
                      isDark: isDark,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Journal preferences saved"),
                            backgroundColor: accentColor,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // --- Group 3: Data ---
                  _buildSectionHeader("Data", subtextColor),
                  const SizedBox(height: 8),
                  _buildCardGroup(cardBg, [
                    _buildSettingsTile(
                      icon: Icons.file_upload_outlined,
                      title: "Export Data",
                      textColor: textColor,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ExportDataScreen()),
                        );
                      },
                    ),
                    Divider(height: 1, indent: 56, endIndent: 16, color: isDark ? Colors.white12 : Colors.black12),
                    _buildSettingsTile(
                      icon: Icons.delete_outline,
                      title: "Delete Data",
                      titleColor: const Color(0xFFE57373),
                      iconColor: const Color(0xFFE57373),
                      textColor: textColor,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // --- Group 4: About ---
                  _buildSectionHeader("About", subtextColor),
                  const SizedBox(height: 8),
                  _buildCardGroup(cardBg, [
                    _buildSettingsTile(
                      icon: Icons.info_outline,
                      title: "About Mood Journal",
                      textColor: textColor,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AboutScreen()),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  Widget _buildCardGroup(Color cardBg, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color textColor,
    required bool isDark,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? textColor, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? textColor,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: isDark ? Colors.white38 : Colors.black38, size: 20),
      onTap: onTap,
    );
  }
}