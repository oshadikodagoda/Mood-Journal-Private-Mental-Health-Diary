import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/pin_keypad.dart';
import 'home_screen.dart';

class CreatePinScreen extends StatefulWidget {
  final bool enableBiometricsAfterPin;
  final bool isChangePin;

  const CreatePinScreen({
    super.key,
    this.enableBiometricsAfterPin = false,
    this.isChangePin = false,
  });

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  final AuthService _authService = AuthService();
  String _pin = '';
  String? _errorMessage;

  void _onDigitPressed(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin += digit;
        _errorMessage = null;
      });

      if (_pin.length == 4) {
        _onSavePin();
      }
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _errorMessage = null;
      });
    }
  }

  void _onSavePin() async {
    if (_pin.length != 4) {
      setState(() {
        _errorMessage = 'Please enter a 4-digit PIN.';
      });
      return;
    }

    // Save PIN to SQLite Database
    try {
      await _authService.setPin(_pin).timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('Database write: $e');
    }

    if (mounted) {
      // If user selected Biometrics on Welcome, prompt the scanner now!
      if (widget.enableBiometricsAfterPin) {
        await _authService.authenticateWithBiometrics(context: context);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.enableBiometricsAfterPin
                ? 'Biometric Lock & Backup PIN enabled!'
                : 'PIN created successfully!',
          ),
          backgroundColor: const Color(0xFF6E8F68),
        ),
      );

      if (widget.isChangePin) {
        Navigator.pop(context, true);
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildPinDot(int index) {
    final bool isFilled = index < _pin.length;
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
    final bool isPinComplete = _pin.length == 4;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EF), // Cream background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Dynamic Title (Backup PIN vs Create PIN)
              Text(
                widget.enableBiometricsAfterPin ? 'Set Backup PIN' : 'Create your PIN',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Dynamic Subtitle
              Text(
                widget.enableBiometricsAfterPin
                    ? 'Choose a 4-digit backup PIN for your biometric lock'
                    : 'Choose a 4-digit PIN to keep your journal private',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 36),

              // 4 PIN Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) => _buildPinDot(index)),
              ),
              const SizedBox(height: 16),

              // Error Message
              SizedBox(
                height: 20,
                child: _errorMessage != null
                    ? Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                        ),
                      )
                    : const SizedBox(),
              ),

              const Spacer(),

              // Keypad
              PinKeypad(
                onDigitPressed: _onDigitPressed,
                onDeletePressed: _onDeletePressed,
                showBiometric: false, // Creating PIN doesn't need biometric button
              ),

              const SizedBox(height: 24),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isPinComplete ? _onSavePin : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E8F68),
                    disabledBackgroundColor: const Color(0xFF6E8F68).withOpacity(0.4),
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}