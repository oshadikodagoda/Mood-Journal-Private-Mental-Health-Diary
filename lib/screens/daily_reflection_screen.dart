import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';
import '../models/emotion.dart';
import '../providers/journal_provider.dart';
import '../services/database_service.dart';
import 'mood_selection_screen.dart';
import 'entry_saved_screen.dart'; // Ensure this is imported

class DailyReflectionScreen extends StatefulWidget {
  final String? initialMood; 

  const DailyReflectionScreen({super.key, this.initialMood});

  @override
  State<DailyReflectionScreen> createState() => _DailyReflectionScreenState();
}

class _DailyReflectionScreenState extends State<DailyReflectionScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedMood = 'Happy';
  List<Emotion> _allEmotions = [];
  List<int> _selectedEmotionIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialMood != null) {
      _selectedMood = widget.initialMood!;
    }
    _loadEmotions();
  }

  Future<void> _loadEmotions() async {
    final db = context.read<DatabaseService>();
    final emotions = await db.getAllEmotions();
    setState(() {
      // Take only the first 6 emotions for the quick selection look
      _allEmotions = emotions.take(6).toList(); 
    });
  }

  void _saveEntry() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in title and content.')),
      );
      return;
    }

    final now = DateTime.now();
    final newEntry = JournalEntry(
      title: _titleController.text,
      content: _contentController.text,
      mood: _selectedMood,
      date: now,
      createdAt: now,
      updatedAt: now,
    );

    // 1. Save to database using the Provider
    await context.read<JournalProvider>().addEntry(newEntry, _selectedEmotionIds);
    
    // 2. Navigate to Success Screen, passing the full entry object
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EntrySavedScreen(entry: newEntry), // FIXED HERE
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(now);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Today's Journal",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(dateStr, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 24),

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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MoodSelectionScreen()),
                        );
                      },
                      child: const Text("Change", style: TextStyle(color: Color(0xFFA8C3A0))),
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
                    selectedColor: const Color(0xFFA8C3A0),
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

              // Save Entry Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E8F68),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), // Pill shape
                    elevation: 0,
                  ),
                  child: const Text(
                    "Save Entry",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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

  Color _getEmotionColor(String emotion) {
    if (emotion == 'Happy') return const Color(0xFFFFF3D6);
    if (emotion == 'Motivated') return const Color(0xFFEBE4F5);
    if (emotion == 'Grateful') return const Color(0xFFE8F3E9);
    return const Color(0xFFF0F0F0);
  }
}