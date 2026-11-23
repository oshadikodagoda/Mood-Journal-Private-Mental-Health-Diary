import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/user_profile.dart';
import 'privacy_security_screen.dart';

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

  Future<void> _showEditNameDialog() async {
    final TextEditingController nameController = TextEditingController(text: _userName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Edit Name", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: "Enter your name",
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6E8F68)),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6E8F68),
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
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EF), // Soft cream background
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF6EF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6E8F68)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- User Profile Header ---
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F3E9),
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
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "Private Mental Health Diary",
                                style: TextStyle(fontSize: 12, color: Colors.black45),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Color(0xFF6E8F68), size: 22),
                          onPressed: _showEditNameDialog,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- Group 1: Account & Privacy ---
                  _buildSectionHeader("Account & Privacy"),
                  const SizedBox(height: 8),
                  _buildCardGroup([
                    _buildSettingsTile(
                      icon: Icons.shield_outlined,
                      title: "Privacy & Security",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 16),
                    _buildSettingsTile(
                      icon: Icons.lock_outline,
                      title: "App Lock",
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
                  _buildSectionHeader("Preferences"),
                  const SizedBox(height: 8),
                  _buildCardGroup([
                    _buildSettingsTile(
                      icon: Icons.notifications_none_outlined,
                      title: "Reminders",
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Reminders module (Member 3)"),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 16),
                    _buildSettingsTile(
                      icon: Icons.light_mode_outlined,
                      title: "Appearance",
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Theme: Pastel Light (Active)"),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 16),
                    _buildSettingsTile(
                      icon: Icons.menu_book_outlined,
                      title: "Journal Preferences",
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Journal preferences saved"),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // --- Group 3: Data ---
                  _buildSectionHeader("Data"),
                  const SizedBox(height: 8),
                  _buildCardGroup([
                    _buildSettingsTile(
                      icon: Icons.file_upload_outlined,
                      title: "Export Data",
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Export feature coming soon"),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 16),
                    _buildSettingsTile(
                      icon: Icons.delete_outline,
                      title: "Delete Data",
                      titleColor: const Color(0xFFE57373),
                      iconColor: const Color(0xFFE57373),
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
                  _buildSectionHeader("About"),
                  const SizedBox(height: 8),
                  _buildCardGroup([
                    _buildSettingsTile(
                      icon: Icons.info_outline,
                      title: "About Mood Journal",
                      onTap: _showAboutDialog,
                    ),
                  ]),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.black87,
    Color titleColor = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.black38, size: 20),
      onTap: onTap,
    );
  }

  void _showAboutDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFFAF6EF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F3E9),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🌿', style: TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Mood Journal",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            const Text(
              "Version 1.0.0 (Build 12)",
              style: TextStyle(color: Colors.black45, fontSize: 13),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}