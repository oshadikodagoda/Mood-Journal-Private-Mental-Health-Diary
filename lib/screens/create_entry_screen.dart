import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/journal_entry.dart';
import '../models/emotion.dart';
import '../providers/journal_provider.dart';
import '../services/database_service.dart';
import 'entry_saved_screen.dart'; // Ensure this is imported

class CreateEntryScreen extends StatefulWidget {
  final String? initialMood; 

  const CreateEntryScreen({super.key, this.initialMood});

  @override
  State<CreateEntryScreen> createState() => _CreateEntryScreenState();
}

class _CreateEntryScreenState extends State<CreateEntryScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  String _selectedMood = 'Neutral';
  List<Emotion> _allEmotions = [];
  List<int> _selectedEmotionIds = [];

  final List<String> _moods = ['Very Happy', 'Happy', 'Neutral', 'Sad', 'Very Sad'];

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
      _allEmotions = emotions;
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

    // Save to database
    await context.read<JournalProvider>().addEntry(newEntry, _selectedEmotionIds);
    
    // Navigate to Success Screen, passing the full entry object
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EntrySavedScreen(entry: newEntry), // FIXED HERE
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EF), 
      appBar: AppBar(
        title: const Text('New Entry'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xFFA8C3A0), size: 28),
            onPressed: _saveEntry,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood Selector
            const Text("Mood", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _moods.map((mood) {
                return ChoiceChip(
                  label: Text(mood),
                  selected: _selectedMood == mood,
                  selectedColor: const Color(0xFFE8F3E9),
                  labelStyle: TextStyle(
                    color: _selectedMood == mood ? const Color(0xFF2E4A2D) : Colors.black87,
                    fontWeight: _selectedMood == mood ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    setState(() => _selectedMood = mood);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Title
            const Text("Title", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Give your entry a title...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Content
            const Text("Write your thoughts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Write your thoughts...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // Emotion Tags
            const Text("Emotion Tags", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allEmotions.map((emotion) {
                final isSelected = _selectedEmotionIds.contains(emotion.id);
                return FilterChip(
                  label: Text(emotion.name),
                  selected: isSelected,
                  selectedColor: const Color(0xFFE8F3E9),
                  checkmarkColor: const Color(0xFF2E4A2D),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFF2E4A2D) : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFFA8C3A0) : Colors.black12,
                    ),
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}