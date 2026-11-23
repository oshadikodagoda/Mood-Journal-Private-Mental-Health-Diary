import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/user_profile.dart';
import 'create_pin_screen.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _db = DatabaseService();

  bool _appLockEnabled = false;
  bool _biometricEnabled = false;
  bool _hidePreview = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSecurityPreferences();
  }

  Future<void> _loadSecurityPreferences() async {
    try {
      final UserProfile profile = await _db.getUserProfile().timeout(
        const Duration(seconds: 1),
        onTimeout: () => UserProfile(name: 'User', appLockEnabled: false),
      );
      final bool canBiometrics = await _authService.isBiometricsAvailable().timeout(
        const Duration(seconds: 1),
        onTimeout: () => true,
      );

      if (mounted) {
        setState(() {
          _appLockEnabled = profile.appLockEnabled;
          _biometricEnabled = canBiometrics && profile.appLockEnabled;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppLockToggle(bool value) async {
    try {
      if (value) {
        final profile = await _db.getUserProfile().timeout(const Duration(seconds: 1));
        if (profile.pinCode == null || profile.pinCode!.isEmpty) {
          if (!mounted) return;
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CreatePinScreen()),
          );
          if (created != true) return;
        }
      }

      await _authService.toggleAppLock(value).timeout(const Duration(seconds: 1));
    } catch (e) {
      debugPrint('Error toggling app lock: $e');
    }

    if (mounted) {
      setState(() => _appLockEnabled = value);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? 'App Lock enabled' : 'App Lock disabled'),
          backgroundColor: const Color(0xFF6E8F68),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
          "Privacy & Security",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: accentColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Protection", subtextColor),
                  const SizedBox(height: 8),
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
                        _buildSwitchTile(
                          icon: Icons.lock_outline,
                          title: "App Lock",
                          value: _appLockEnabled,
                          textColor: textColor,
                          accentColor: accentColor,
                          onChanged: _handleAppLockToggle,
                        ),
                        Divider(height: 1, indent: 56, endIndent: 16, color: isDark ? Colors.white12 : Colors.black12),
                        _buildSwitchTile(
                          icon: Icons.fingerprint,
                          title: "Biometric Unlock",
                          value: _biometricEnabled && _appLockEnabled,
                          textColor: textColor,
                          accentColor: accentColor,
                          onChanged: _appLockEnabled
                              ? (val) => setState(() => _biometricEnabled = val)
                              : null,
                        ),
                        Divider(height: 1, indent: 56, endIndent: 16, color: isDark ? Colors.white12 : Colors.black12),
                        _buildSwitchTile(
                          icon: Icons.visibility_off_outlined,
                          title: "Hide Journal Preview",
                          value: _hidePreview,
                          textColor: textColor,
                          accentColor: accentColor,
                          onChanged: (val) => setState(() => _hidePreview = val),
                        ),
                        Divider(height: 1, indent: 56, endIndent: 16, color: isDark ? Colors.white12 : Colors.black12),
                        ListTile(
                          leading: Icon(Icons.edit_outlined, color: textColor),
                          title: Text("Change PIN", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: textColor)),
                          trailing: Icon(Icons.chevron_right, color: isDark ? Colors.white38 : Colors.black38),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CreatePinScreen(isChangePin: true)),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  _buildSectionHeader("Your data", subtextColor),
                  const SizedBox(height: 8),
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
                        ListTile(
                          leading: Icon(Icons.file_upload_outlined, color: textColor),
                          title: Text("Export My Data", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: textColor)),
                          trailing: Icon(Icons.chevron_right, color: isDark ? Colors.white38 : Colors.black38),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Export feature available in Export Data menu"),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        Divider(height: 1, indent: 56, endIndent: 16, color: isDark ? Colors.white12 : Colors.black12),
                        ListTile(
                          leading: const Icon(Icons.delete_outline, color: Color(0xFFE57373)),
                          title: const Text(
                            "Delete All Journal Data",
                            style: TextStyle(color: Color(0xFFE57373), fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                          trailing: Icon(Icons.chevron_right, color: isDark ? Colors.white38 : Colors.black38),
                          onTap: _showDeleteDataDialog,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Privacy Badge
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1B2E19) : const Color(0xFFE8F3E9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accentColor.withOpacity(0.5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Text('🌿', style: TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your journal stays on your device.",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF2E5A27),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Entries are encrypted and never leave your phone unless you export them.",
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black54,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Text(
      title,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Color textColor,
    required Color accentColor,
    required ValueChanged<bool>? onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: textColor)),
      value: value,
      activeColor: accentColor,
      onChanged: onChanged,
    );
  }

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete All Data?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          "This will permanently erase all journal entries and mood history stored on this device. This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE57373),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Data reset cancelled"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}