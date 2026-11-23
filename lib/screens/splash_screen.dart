import 'dart:async';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/user_profile.dart';
import 'welcome_screen.dart';
import 'pin_lock_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final DatabaseService _db = DatabaseService();

  @override
  void initState() {
    super.initState();

    // Smooth entry animation for the logo
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Check user state after 2 seconds
    Timer(const Duration(milliseconds: 2200), _checkInitialRoute);
  }

  Future<void> _checkInitialRoute() async {
    try {
      final UserProfile profile = await _db.getUserProfile();

      if (!mounted) return;

      // 1. If App Lock is enabled, go to PIN Lock Screen
      if (profile.appLockEnabled && profile.pinCode != null && profile.pinCode!.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PinLockScreen()),
        );
      } 
      // 2. If user already set a name or visited before, go to Home
      else if (profile.name != 'User') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } 
      // 3. First time user, go to Welcome/Setup
      else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    } catch (e) {
      // Fallback in case of any database delay
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EF), // Pastel cream background
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Sprout Icon Circle 🌿
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F3E9), // Light sage
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA8C3A0).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🌿', style: TextStyle(fontSize: 44)),
                  ),
                ),
                const SizedBox(height: 24),

                // App Title
                const Text(
                  'Mood Journal',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E4A2D), // Deep Sage Green
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  'Your private mental health space',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}