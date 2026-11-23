import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'database_service.dart';
import '../models/user_profile.dart';

class AuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final DatabaseService _db = DatabaseService();

  // Check if the device hardware supports biometrics
  Future<bool> isBiometricsAvailable() async {
    if (kIsWeb) {
      // Always available in simulated demo mode on Web!
      return true;
    }
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  // Trigger biometric authentication (Fingerprint / Face Unlock)
  Future<bool> authenticateWithBiometrics({BuildContext? context}) async {
    // 1. Web Preview Mode (Interactive Simulated Sensor)
    if (kIsWeb && context != null && context.mounted) {
      return await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFFFAF6EF),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F3E9),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.fingerprint, size: 44, color: Color(0xFF6E8F68)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Biometric Unlock",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                "Touch sensor or use Face ID to open your Mood Journal",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check, color: Colors.white, size: 18),
                  label: const Text("Simulate Match (Unlock)", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E8F68),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Use PIN Instead", style: TextStyle(color: Colors.black45)),
              ),
            ],
          ),
        ),
      ) ?? false;
    }

    // 2. Real Android Mobile Device Mode
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to open your Mood Journal',
      );
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  // Verify the entered 4-digit PIN against the stored PIN
  Future<bool> verifyPin(String enteredPin) async {
    final UserProfile profile = await _db.getUserProfile();
    if (profile.pinCode == null || profile.pinCode!.isEmpty) {
      return true; // No PIN set
    }
    return profile.pinCode == enteredPin;
  }

  // Set or update the 4-digit PIN
  Future<bool> setPin(String newPin) async {
    final UserProfile profile = await _db.getUserProfile();
    final updatedProfile = UserProfile(
      userId: profile.userId,
      name: profile.name,
      appLockEnabled: true,
      pinCode: newPin,
    );
    final rowsAffected = await _db.updateUserProfile(updatedProfile);
    return rowsAffected > 0;
  }

  // Enable or disable App Lock
  Future<bool> toggleAppLock(bool enabled) async {
    final UserProfile profile = await _db.getUserProfile();
    final updatedProfile = UserProfile(
      userId: profile.userId,
      name: profile.name,
      appLockEnabled: enabled,
      pinCode: profile.pinCode,
    );
    final rowsAffected = await _db.updateUserProfile(updatedProfile);
    return rowsAffected > 0;
  }
}