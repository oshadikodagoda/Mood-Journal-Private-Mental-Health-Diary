import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';
import '../models/emotion.dart';
import '../providers/journal_provider.dart';
import '../services/database_service.dart';
import 'entry_saved_screen.dart'; // Import the saved screen

class EditEntryScreen extends StatefulWidget {
  final JournalEntry entry;

  const EditEntryScreen({super.key, required this.entry});

  @override
  State<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _selectedMood;
  List<Emotion> _allEmotions = [];
  List<int> _selectedEmotionIds = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title);
    _contentController = TextEditingController(text: widget.entry.content);
    _selectedMood = widget.entry.mood;
    _selectedEmotionIds = List.from(widget.entry.emotionIds); 
    
    _loadEmotions();
  }

  Future<void> _loadEmotions() async {
    final db = context.read<DatabaseService>();
    final emotions = await db.getAllEmotions();
    setState(() {
      _allEmotions = emotions;
    });
  }

  void _saveChanges() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in title and content.')),
      );
      return;
    }

    final updatedEntry = JournalEntry(
      id: widget.entry.id,
      title: _titleController.text,
      content: _contentController.text,
      mood: _selectedMood,
      date: widget.entry.date,
      createdAt: widget.entry.createdAt,
      updatedAt: DateTime.now(),
    );

    final db = context.read<DatabaseService>();
    await db.updateEntry(updatedEntry);
    
    if (mounted) {
      final provider = context.read<JournalProvider>();
      await provider.loadEntries();
      
      // Navigate to EntrySavedScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EntrySavedScreen(entry: updatedEntry),
        ),
      );
    }
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'Very Happy': return '🤩';
      case 'Happy': return '😊';
      case 'Neutral': return '😐';
      case 'Sad': return '😔';
      case 'Very Sad': return '😭';
      case 'Calm': return '😌';
      default: return '😐';
    }
  }

  Color _getEmotionColor(String emotion) {
    if (emotion == 'Happy') return const Color(0xFFFFF3D6);
    if (emotion == 'Motivated') return const Color(0xFFEBE4F5);
    if (emotion == 'Grateful') return const Color(0xFFE8F3E9);
    return const Color(0xFFF0F0F0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text("Edit Entry", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mood Summary Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Text(_getMoodEmoji(_selectedMood), style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Feeling $_selectedMood", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const Text("Tap to change mood", style: TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                         // TODO: Implement mood change if needed
                      },
                      child: const Text("Change", style: TextStyle(color: Color(0xFF6E8F68))),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Title Input
              const Text("Title", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'A good day at university',
                  hintStyle: const TextStyle(color: Colors.black38),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Content Input
              const Text("How was your day?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _contentController,
                maxLines: 6,
                maxLength: 500,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Today I managed to...',
                  hintStyle: const TextStyle(color: Colors.black38),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  counterText: "", 
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "${_contentController.text.length}/500",
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ),
              const SizedBox(height: 16),

              // Emotions
              const Text("Add emotions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allEmotions.map((emotion) {
                  final isSelected = _selectedEmotionIds.contains(emotion.id);
                  return FilterChip(
                    label: Text(emotion.name),
                    selected: isSelected,
                    backgroundColor: _getEmotionColor(emotion.name),
                    selectedColor: const Color(0xFF6E8F68),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide.none,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedEmotionIds.add(emotion.id!);
                        } else {
                          _selectedEmotionIds.remove(emotion.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),

              // Save Changes Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E8F68),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Cancel Button
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context), // Goes back to Detail Page
                  child: const Text(
                    "Cancel",
                    style: TextStyle(fontSize: 15, color: Color(0xFF6E8F68), fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}