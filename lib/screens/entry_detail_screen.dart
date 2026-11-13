import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/journal_entry.dart';
import '../models/emotion.dart';
import '../providers/journal_provider.dart';
import '../services/database_service.dart';
import 'edit_entry_screen.dart'; 

class EntryDetailScreen extends StatefulWidget {
  final JournalEntry entry;

  const EntryDetailScreen({super.key, required this.entry});

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  List<Emotion> _entryEmotions = [];

  @override
  void initState() {
    super.initState();
    _loadEmotions();
  }

  Future<void> _loadEmotions() async {
    if (widget.entry.emotionIds.isNotEmpty) {
      final db = context.read<DatabaseService>();
      final allEmotions = await db.getAllEmotions();
      setState(() {
        _entryEmotions = allEmotions.where((e) => widget.entry.emotionIds.contains(e.id)).toList();
      });
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

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Red Trash Icon Circle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF0F0), // Light red background
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline, 
                    color: Color(0xFFD32F2F), // Red icon
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  "Delete this entry?",
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.black87
                  ),
                ),
                const SizedBox(height: 12),

                // Description (Dynamic with title)
                Text(
                  '"${widget.entry.title}" will be permanently removed from your journal. This can\'t be undone.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14, 
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Delete Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Close dialog first
                      Navigator.pop(ctx); 
                      
                      // Delete from DB
                      await context.read<JournalProvider>().deleteEntry(widget.entry.id!);
                      
                      // Pop back to Home Screen
                      if (context.mounted) Navigator.pop(context); 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F), // Red button
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Delete Entry",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 15, 
                      color: Color(0xFF6E8F68), // Green text
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(widget.entry.date);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Journal Entry",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {},
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(dateStr, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 16),

              Row(
                children: [
                  Text(_getMoodEmoji(widget.entry.mood), style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Text(
                    widget.entry.mood, 
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                widget.entry.title,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    widget.entry.content,
                    style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.6),
                  ),
                ),
              ),

              if (_entryEmotions.isNotEmpty) ...[
                const Text("Emotions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _entryEmotions.map((emotion) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getEmotionColor(emotion.name),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        emotion.name,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
              ],

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditEntryScreen(entry: widget.entry),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        side: const BorderSide(color: Color(0xFF6E8F68)),
                      ),
                      child: const Text(
                        "Edit",
                        style: TextStyle(fontSize: 16, color: Color(0xFF6E8F68), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _showDeleteDialog, // Call the new custom dialog
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEBEE), // Light red
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      child: const Text(
                        "Delete",
                        style: TextStyle(fontSize: 16, color: Color(0xFFD32F2F), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}