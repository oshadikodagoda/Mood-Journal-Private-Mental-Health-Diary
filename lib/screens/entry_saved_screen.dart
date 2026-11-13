import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import 'entry_detail_screen.dart';

class EntrySavedScreen extends StatelessWidget {
  final JournalEntry entry; // Pass the actual entry object

  const EntrySavedScreen({super.key, required this.entry});

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
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji with green background and checkmark
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F3E9), // Light green circle
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _getMoodEmoji(entry.mood),
                        style: const TextStyle(fontSize: 70),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF6E8F68), // Dark green check circle
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 24),
                  )
                ],
              ),
              const SizedBox(height: 32),

              // Texts
              const Text(
                "Entry saved!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              const Text(
                "Nice work, Oshadi. Taking a moment to reflect is a gift to yourself.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 32),

              // Streak Card (Static for now)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF0F0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.local_fire_department, color: Colors.redAccent, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("5-day streak", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("You've journaled 5 days in a row", style: TextStyle(fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Days of week circles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDayCircle("M", true),
                        _buildDayCircle("T", true),
                        _buildDayCircle("W", true),
                        _buildDayCircle("T", true),
                        _buildDayCircle("F", true),
                        _buildDayCircle("S", false),
                        _buildDayCircle("S", false),
                      ],
                    )
                  ],
                ),
              ),
              
              const Spacer(),

              // Buttons
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the Entry Detail Screen and clear previous screens
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => EntryDetailScreen(entry: entry)),
                      (route) => route.isFirst, // Keep HomeScreen at the bottom of the stack
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E8F68),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                  child: const Text(
                    "View Entry",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text(
                  "Back to Home",
                  style: TextStyle(fontSize: 15, color: Color(0xFF6E8F68), fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayCircle(String day, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted ? const Color(0xFF6E8F68) : const Color(0xFFF0F0F0),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted 
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : null,
          ),
        ),
        const SizedBox(height: 6),
        Text(day, style: const TextStyle(fontSize: 10, color: Colors.black54)),
      ],
    );
  }
}