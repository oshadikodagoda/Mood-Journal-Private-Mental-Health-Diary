class JournalEntry {
  final int? id;
  final String title;
  final String content;
  final String mood;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  List<int> emotionIds; // To hold associated emotion IDs

  JournalEntry({
    this.id,
    required this.title,
    required this.content,
    required this.mood,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.emotionIds = const [],
  });

  // Convert a JournalEntry into a Map (for SQLite)
  Map<String, dynamic> toMap() {
    return {
      'entry_id': id,
      'title': title,
      'content': content,
      'mood': mood,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Convert a Map (from SQLite) into a JournalEntry
  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['entry_id'],
      title: map['title'],
      content: map['content'],
      mood: map['mood'],
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}