import 'package:flutter/material.dart';
import 'daily_reflection_screen.dart'; // Updated import

class MoodSelectionScreen extends StatefulWidget {
  const MoodSelectionScreen({super.key});

  @override
  State<MoodSelectionScreen> createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends State<MoodSelectionScreen> {
  String _selectedMood = 'Very Happy';
  
  // The emotions from your Figma design
  final List<String> _emotions = [
    "Happy", "Stressed", "Tired", "Grateful", 
    "Angry", "Loved", "Anxious", "Excited", 
    "Lonely", "Proud"
  ];
  
  final List<String> _selectedEmotions = [];

  // Data for the Grid (Emoji, Title, Background Color)
  final List<Map<String, dynamic>> _moodOptions = [
    {'emoji': '🤩', 'title': 'Very Happy', 'color': const Color(0xFFE8F3E9)}, // Light Green
    {'emoji': '😊', 'title': 'Happy', 'color': Colors.white},
    {'emoji': '😐', 'title': 'Neutral', 'color': Colors.white},
    {'emoji': '😔', 'title': 'Sad', 'color': Colors.white},
    {'emoji': '😭', 'title': 'Very Sad', 'color': Colors.white},
    {'emoji': '😌', 'title': 'Calm', 'color': Colors.white},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EF), // Cream background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "How are you feeling?",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                "Choose the mood that best describes your current feelings.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),

              // Mood Grid
              Expanded(
                flex: 3,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _moodOptions.length,
                  itemBuilder: (context, index) {
                    final option = _moodOptions[index];
                    final isSelected = _selectedMood == option['title'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMood = option['title'];
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFE8F3E9) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFA8C3A0) : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(option['emoji'], style: const TextStyle(fontSize: 40)),
                            const SizedBox(height: 8),
                            Text(
                              option['title'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? const Color(0xFF2E4A2D) : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Emotion Tags Title
              const Text(
                "What's behind this mood?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),

              // Emotion Tags Wrap
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _emotions.map((emotion) {
                      final isSelected = _selectedEmotions.contains(emotion);
                      return FilterChip(
                        label: Text(emotion),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedEmotions.add(emotion);
                            } else {
                              _selectedEmotions.remove(emotion);
                            }
                          });
                        },
                        backgroundColor: Colors.white,
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
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Updated: Navigate to DailyReflectionScreen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DailyReflectionScreen(initialMood: _selectedMood),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA8C3A0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}