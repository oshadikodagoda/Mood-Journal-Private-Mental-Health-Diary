class UserProfile {
  final int? userId;
  final String name;
  final bool appLockEnabled;
  final String? pinCode; // Storing PIN for MVP (In production, use secure storage)

  UserProfile({
    this.userId,
    required this.name,
    required this.appLockEnabled,
    this.pinCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'settings': '${appLockEnabled ? 1 : 0}|${pinCode ?? ""}', // Storing as a simple string for MVP
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    // Parsing the settings string back into variables
    final settingsStr = map['settings'] as String? ?? '0|';
    final settingsParts = settingsStr.split('|');
    
    return UserProfile(
      userId: map['user_id'],
      name: map['name'],
      appLockEnabled: settingsParts[0] == '1',
      pinCode: settingsParts.length > 1 && settingsParts[1].isNotEmpty ? settingsParts[1] : null,
    );
  }
}