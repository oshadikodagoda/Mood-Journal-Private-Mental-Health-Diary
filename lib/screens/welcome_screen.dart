import 'package:flutter/material.dart';
import 'create_pin_screen.dart';
import 'home_screen.dart';
import '../services/auth_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // 0: PIN Lock, 1: Biometric Lock, 2: No lock
  int _selectedOption = 0; 
  final AuthService _authService = AuthService();

  Widget _buildProtectionOption({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final bool isSelected = _selectedOption == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF6E8F68) : Colors.transparent,
            width: 2,
          ),
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
            // Leading Icon Circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE8F3E9) : const Color(0xFFF7F7F7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF6E8F68) : Colors.black54,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            // Radio Checkmark Circle
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF6E8F68) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFF6E8F68) : Colors.black26,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _onContinue() async {
    if (_selectedOption == 0 || _selectedOption == 1) {
      // Navigate to Create PIN screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreatePinScreen(
            enableBiometricsAfterPin: _selectedOption == 1,
          ),
        ),
      );
    } else {
      // No lock selected
      await _authService.toggleAppLock(false);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EF), // Cream background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Sprout Icon 🌿
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F3E9),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🌿', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Welcome to\nMood Journal',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'A private space to record your thoughts, moods, and moments.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Section Header
              const Text(
                'How would you like to protect your journal?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Option 1: PIN Lock
              _buildProtectionOption(
                index: 0,
                icon: Icons.lock_outline,
                title: 'PIN Lock',
                subtitle: 'Protect your journal with a personal 4-digit PIN',
              ),
              const SizedBox(height: 12),

              // Option 2: Biometric Lock
              _buildProtectionOption(
                index: 1,
                icon: Icons.fingerprint,
                title: 'Biometric Lock',
                subtitle: 'Use fingerprint or face ID to unlock',
              ),
              const SizedBox(height: 12),

              // Option 3: No lock for now
              _buildProtectionOption(
                index: 2,
                icon: Icons.close,
                title: 'No lock for now',
                subtitle: 'You can turn this on later in Settings',
              ),

              const Spacer(),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E8F68), // Sage Green
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}