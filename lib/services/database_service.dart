import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/journal_entry.dart';
import '../models/emotion.dart';
import '../models/reminder.dart';
import '../models/user_profile.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the Database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'mood_journal.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create Tables on First Run
  Future<void> _onCreate(Database db, int version) async {
    // 1. User / Profile Table
    await db.execute('''
      CREATE TABLE User (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        settings TEXT
      )
    ''');

    // 2. Journal Entry Table
    await db.execute('''
      CREATE TABLE JournalEntry (
        entry_id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        mood TEXT,
        date TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // 3. Emotion Table
    await db.execute('''
      CREATE TABLE Emotion (
        emotion_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
      )
    ''');

    // 4. Entry Emotion (Many-to-Many relationship)
    await db.execute('''
      CREATE TABLE EntryEmotion (
        entry_id INTEGER,
        emotion_id INTEGER,
        PRIMARY KEY (entry_id, emotion_id),
        FOREIGN KEY (entry_id) REFERENCES JournalEntry (entry_id) ON DELETE CASCADE,
        FOREIGN KEY (emotion_id) REFERENCES Emotion (emotion_id) ON DELETE CASCADE
      )
    ''');

    // 5. Reminder Table
    await db.execute('''
      CREATE TABLE Reminder (
        reminder_id INTEGER PRIMARY KEY AUTOINCREMENT,
        time TEXT,
        enabled INTEGER
      )
    ''');

    // Insert Pre-defined Emotions (From your proposal)
    List<String> defaultEmotions = [
      "Happy", "Sad", "Angry", "Excited", "Relaxed", 
      "Stressed", "Worried", "Grateful", "Motivated", "Lonely"
    ];
    for (String emotion in defaultEmotions) {
      await db.insert('Emotion', {'name': emotion});
    }
    
    // Insert default user profile
    await db.insert('User', {'name': 'User', 'settings': '0|'});
  }

  // ==========================================
  // CRUD OPERATIONS FOR JOURNAL ENTRIES
  // ==========================================

  // Create (Insert) Journal Entry
  Future<int> insertEntry(JournalEntry entry, List<int> selectedEmotionIds) async {
    final db = await database;
    
    // We use a transaction because we are inserting into two tables
    return await db.transaction((txn) async {
      int entryId = await txn.insert('JournalEntry', entry.toMap());

      // Save the emotion tags linked to this entry
      for (int emotionId in selectedEmotionIds) {
        await txn.insert('EntryEmotion', {
          'entry_id': entryId,
          'emotion_id': emotionId,
        });
      }
      return entryId;
    });
  }

  // Read (Get) All Journal Entries (Chronological - Newest First)
  Future<List<JournalEntry>> getAllEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'JournalEntry',
      orderBy: 'date DESC',
    );

    List<JournalEntry> entries = [];
    for (var map in maps) {
      JournalEntry entry = JournalEntry.fromMap(map);
      // Fetch emotion IDs for this specific entry
      final emotionMaps = await db.query(
        'EntryEmotion',
        columns: ['emotion_id'],
        where: 'entry_id = ?',
        whereArgs: [entry.id],
      );
      entry.emotionIds = emotionMaps.map((e) => e['emotion_id'] as int).toList();
      entries.add(entry);
    }
    return entries;
  }

  // Update Journal Entry
  Future<int> updateEntry(JournalEntry entry) async {
    final db = await database;
    return await db.update(
      'JournalEntry',
      entry.toMap(),
      where: 'entry_id = ?',
      whereArgs: [entry.id],
    );
  }

  // Delete Journal Entry
  Future<int> deleteEntry(int entryId) async {
    final db = await database;
    // ON DELETE CASCADE will automatically remove it from EntryEmotion table
    return await db.delete(
      'JournalEntry',
      where: 'entry_id = ?',
      whereArgs: [entryId],
    );
  }

  // ==========================================
  // HELPER OPERATIONS (For UI)
  // ==========================================

  // Get all available emotions (For the tags in Journal Entry Screen)
  Future<List<Emotion>> getAllEmotions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Emotion');
    return List.generate(maps.length, (i) => Emotion.fromMap(maps[i]));
  }

  // Search entries by keyword
  Future<List<JournalEntry>> searchEntries(String keyword) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'JournalEntry',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) => JournalEntry.fromMap(maps[i]));
  }
}