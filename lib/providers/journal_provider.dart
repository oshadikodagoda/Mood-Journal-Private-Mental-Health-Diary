import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/database_service.dart';

class JournalProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<JournalEntry> _entries = [];
  bool _isLoading = false;

  List<JournalEntry> get entries => _entries;
  bool get isLoading => _isLoading;

  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();
    
    _entries = await _db.getAllEntries();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEntry(JournalEntry entry, List<int> emotionIds) async {
    await _db.insertEntry(entry, emotionIds);
    await loadEntries(); // Reload list after saving
  }

  Future<void> deleteEntry(int entryId) async {
    await _db.deleteEntry(entryId);
    await loadEntries(); // Reload list after deleting
  }
}