import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'database_service.dart';
import '../models/user_profile.dart';

class AuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final DatabaseService _db = DatabaseService();

  // Check if the device hardware supports biometrics
  Future<bool> isBiometricsAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException {
      return false;
    }
  }

    // Trigger biometric authentication (Fingerprint / Face Unlock)
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to open your Mood Journal',
      );
    } on PlatformException {
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