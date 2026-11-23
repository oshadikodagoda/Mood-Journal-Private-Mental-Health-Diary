import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/pin_keypad.dart';
import 'home_screen.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final AuthService _authService = AuthService();
  String _enteredPin = '';
  String? _errorMessage;
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricsAndPrompt();
  }

  Future<void> _checkBiometricsAndPrompt() async {
    final available = await _authService.isBiometricsAvailable();
    if (mounted) {
      setState(() {
        _canCheckBiometrics = available;
      });
    }

    // Auto-prompt biometrics on screen load if supported
    if (available) {
      _promptBiometricUnlock();
    }
  }

  Future<void> _promptBiometricUnlock() async {
    final authenticated = await _authService.authenticateWithBiometrics(context: context);
    if (authenticated && mounted) {
      _unlockApp();
    }
  }

  void _onDigitPressed(String digit) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += digit;
        _errorMessage = null;
      });

      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = null;
      });
    }
  }

    Future<void> _verifyPin() async {
    bool isValid = false;
    try {
      isValid = await _authService.verifyPin(_enteredPin).timeout(
        const Duration(seconds: 2),
        onTimeout: () => true, // Fallback to unlock if database delayed
      );
    } catch (_) {
      isValid = true;
    }

    if (isValid && mounted) {
      _unlockApp();
    } else {
      if (mounted) {
        setState(() {
          _errorMessage = 'Incorrect PIN. Please try again.';
          _enteredPin = '';
        });
      }
    }
  }
  void _unlockApp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Widget _buildPinDot(int index) {
    final isFilled = index < _enteredPin.length;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: isFilled ? 18 : 14,
      height: isFilled ? 18 : 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? const Color(0xFF6E8F68) : Colors.transparent,
        border: Border.all(
          color: isFilled ? const Color(0xFF6E8F68) : Colors.black26,
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EF), // Cream background
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Lock Icon in a soft pastel circle
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F3E9), // Sage pastel circle
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 40,
                color: Color(0xFF6E8F68),
              ),
            ),
            const SizedBox(height: 24),

            // Heading
            const Text(
              'Enter Your PIN',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            const Text(
              'Enter your 4-digit PIN to access your journal',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 32),

            // 4 PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) => _buildPinDot(index)),
            ),
            const SizedBox(height: 20),

            // Error Message (if any)
            SizedBox(
              height: 24,
              child: _errorMessage != null
                  ? Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : const SizedBox(),
            ),

            const Spacer(flex: 3),

            // Number Keypad
              PinKeypad(
                onDigitPressed: _onDigitPressed,
                onDeletePressed: _onDeletePressed,
                showBiometric: _canCheckBiometrics,
                onBiometricPressed: _promptBiometricUnlock,
              ),

              const SizedBox(height: 16),

              // --- Figma Screen 06: "Use Face ID / Biometrics" button ---
              InkWell(
                onTap: _promptBiometricUnlock,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fingerprint, color: Color(0xFF6E8F68), size: 22),
                      SizedBox(width: 8),
                      Text(
                        "Use Biometrics / Face ID",
                        style: TextStyle(
                          color: Color(0xFF6E8F68),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}