class Reminder {
  final int? id;
  final String time; // Store as "HH:mm" (e.g., "20:00")
  final bool enabled;

  Reminder({
    this.id,
    required this.time,
    required this.enabled,
  });

  Map<String, dynamic> toMap() {
    return {
      'reminder_id': id,
      'time': time,
      'enabled': enabled ? 1 : 0, // SQLite doesn't have boolean, use 1 and 0
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['reminder_id'],
      time: map['time'],
      enabled: map['enabled'] == 1,
    );
  }
}