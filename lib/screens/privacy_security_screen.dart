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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
      debugPrint('Error toggling lock: $e');
    }

    if (mounted) {
      setState(() {
        _appLockEnabled = value;
      });

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
          "Privacy & Security",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6E8F68)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Section 1: Protection ---
                  _buildSectionHeader("Protection"),
                  const SizedBox(height: 8),
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
                        // App Lock Toggle
                        _buildSwitchTile(
                          icon: Icons.lock_outline,
                          title: "App Lock",
                          value: _appLockEnabled,
                          onChanged: _handleAppLockToggle,
                        ),
                        const Divider(height: 1, indent: 56, endIndent: 16),

                        // Biometric Unlock Toggle
                        _buildSwitchTile(
                          icon: Icons.fingerprint,
                          title: "Biometric Unlock",
                          value: _biometricEnabled && _appLockEnabled,
                          onChanged: _appLockEnabled
                              ? (val) => setState(() => _biometricEnabled = val)
                              : null,
                        ),
                        const Divider(height: 1, indent: 56, endIndent: 16),

                        // Hide Journal Preview Toggle
                        _buildSwitchTile(
                          icon: Icons.visibility_off_outlined,
                          title: "Hide Journal Preview",
                          value: _hidePreview,
                          onChanged: (val) => setState(() => _hidePreview = val),
                        ),
                        const Divider(height: 1, indent: 56, endIndent: 16),

                        // Change PIN Tile
                        ListTile(
                          leading: const Icon(Icons.edit_outlined, color: Colors.black87),
                          title: const Text(
                            "Change PIN",
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: Colors.black38),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CreatePinScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // --- Section 2: Your Data ---
                  _buildSectionHeader("Your data"),
                  const SizedBox(height: 8),
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
                        // Export Data
                        ListTile(
                          leading: const Icon(Icons.file_upload_outlined, color: Colors.black87),
                          title: const Text(
                            "Export My Data",
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: Colors.black38),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Export feature available in next release"),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 56, endIndent: 16),

                        // Delete All Journal Data
                        ListTile(
                          leading: const Icon(Icons.delete_outline, color: Color(0xFFE57373)),
                          title: const Text(
                            "Delete All Journal Data",
                            style: TextStyle(
                              color: Color(0xFFE57373),
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: Colors.black38),
                          onTap: _showDeleteDataDialog,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- Sage Green Privacy Badge (From Figma) ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F3E9), // Light sage
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFA8C3A0).withOpacity(0.5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Text('🌿', style: TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your journal stays on your device.",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E5A27),
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Entries are encrypted and never leave your phone unless you export them.",
                                style: TextStyle(
                                  color: Colors.black54,
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

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: Colors.black87),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      value: value,
      activeColor: const Color(0xFF6E8F68),
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
            child: const Text("Cancel", style: TextStyle(color: Colors.black54)),
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