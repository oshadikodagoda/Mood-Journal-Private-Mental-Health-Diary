import 'package:flutter/material.dart';

class PinKeypad extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback? onBiometricPressed;
  final bool showBiometric;

  const PinKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onDeletePressed,
    this.onBiometricPressed,
    this.showBiometric = false,
  });

  Widget _buildKey(BuildContext context, String value) {
    return InkWell(
      onTap: () => onDigitPressed(value),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E4A2D),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: 1, 2, 3
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKey(context, '1'),
            _buildKey(context, '2'),
            _buildKey(context, '3'),
          ],
        ),
        const SizedBox(height: 20),

        // Row 2: 4, 5, 6
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKey(context, '4'),
            _buildKey(context, '5'),
            _buildKey(context, '6'),
          ],
        ),
        const SizedBox(height: 20),

        // Row 3: 7, 8, 9
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKey(context, '7'),
            _buildKey(context, '8'),
            _buildKey(context, '9'),
          ],
        ),
        const SizedBox(height: 20),

        // Row 4: Biometrics, 0, Backspace
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Biometric button (or empty space if not available)
            SizedBox(
              width: 72,
              height: 72,
              child: showBiometric && onBiometricPressed != null
                  ? IconButton(
                      icon: const Icon(Icons.fingerprint, size: 36, color: Color(0xFF6E8F68)),
                      onPressed: onBiometricPressed,
                    )
                  : const SizedBox(),
            ),

            // Number 0
            _buildKey(context, '0'),

            // Delete backspace button
            SizedBox(
              width: 72,
              height: 72,
              child: IconButton(
                icon: const Icon(Icons.backspace_outlined, size: 28, color: Colors.black54),
                onPressed: onDeletePressed,
              ),
            ),
          ],
        ),
      ],
    );
  }
}