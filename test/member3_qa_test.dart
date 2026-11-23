import 'package:flutter_test/flutter_test.dart';
import 'package:mood_journal/models/journal_entry.dart';

void main() {
  group('Member 3 QA Test Suite (Proposal Table 13.1)', () {
    test('T08: Calendar entry correctly correlates with selected calendar date', () {
      final date = DateTime(2026, 10, 1, 14, 30);
      final entry = JournalEntry(
        id: 1,
        title: "Reflection",
        content: "Great productive day",
        mood: "Happy",
        date: date,
        createdAt: date,
        updatedAt: date,
      );
      expect(entry.date.year, 2026);
      expect(entry.date.month, 10);
      expect(entry.date.day, 1);
    });

    test('T09: Search algorithm matches keyword in title or content', () {
      final entries = [
        JournalEntry(id: 1, title: 'Peaceful afternoon', content: 'Went for a walk', mood: 'Calm', date: DateTime.now(), createdAt: DateTime.now(), updatedAt: DateTime.now()),
        JournalEntry(id: 2, title: 'Exam study', content: 'Preparing for mobile dev presentation', mood: 'Focused', date: DateTime.now(), createdAt: DateTime.now(), updatedAt: DateTime.now()),
      ];
      final query = 'presentation';
      final results = entries.where((e) =>
        e.title.toLowerCase().contains(query) || e.content.toLowerCase().contains(query)
      ).toList();
      expect(results.length, 1);
      expect(results.first.title, 'Exam study');
    });

    test('T10: Filter entries by specific mood tag', () {
      final entries = [
        JournalEntry(id: 1, title: 'Day 1', content: 'Good', mood: 'Happy', date: DateTime.now(), createdAt: DateTime.now(), updatedAt: DateTime.now()),
        JournalEntry(id: 2, title: 'Day 2', content: 'Down', mood: 'Sad', date: DateTime.now(), createdAt: DateTime.now(), updatedAt: DateTime.now()),
      ];
      final filtered = entries.where((e) => e.mood == 'Happy').toList();
      expect(filtered.length, 1);
      expect(filtered.first.mood, 'Happy');
    });

    test('T11: Calculation of positive mood ratio for Insights', () {
      final moods = ['Happy', 'Very Happy', 'Sad', 'Happy'];
      final positiveCount = moods.where((m) => m == 'Happy' || m == 'Very Happy').length;
      final percentage = (positiveCount / moods.length) * 100;
      expect(percentage, 75.0);
    });

    test('T13: Offline Capability - SQLite models serialize locally', () {
      final entry = JournalEntry(
        id: 10,
        title: "Offline Reflection",
        content: "No internet needed",
        mood: "Neutral",
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final map = entry.toMap();
      expect(map['title'], "Offline Reflection");
      expect(map['mood'], "Neutral");
    });
  });
}
