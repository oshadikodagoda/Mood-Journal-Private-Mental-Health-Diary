import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/journal_provider.dart';
import 'mood_selection_screen.dart'; 
import 'daily_reflection_screen.dart'; 
import 'entry_detail_screen.dart';
import 'journal_history_screen.dart';
import 'settings_screen.dart';
import 'insights_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 0: Home, 1: Journal, 2: Insights, 3: More

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JournalProvider>().loadEntries();
    });
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
    final greeting = now.hour < 12 ? "Good morning," : (now.hour < 17 ? "Good afternoon," : "Good evening,");
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(now);

    // Dynamic Theme Variables
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;
    final scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFFAF6EF);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: _selectedIndex == 0 
          ? _buildHomeDashboard(context, greeting, dateStr, now, isDark, cardBg, textColor, subtextColor, accentColor) 
          :const InsightsScreen(), 
      ),
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => const MoodSelectionScreen())
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: cardBg,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: Icons.home_outlined, label: 'Home', index: 0, accentColor: accentColor, isDark: isDark),
              _buildNavItem(icon: Icons.menu_book_outlined, label: 'Journal', index: 1, accentColor: accentColor, isDark: isDark),
              const SizedBox(width: 40), // Spacing for FAB
              _buildNavItem(icon: Icons.bar_chart, label: 'Insights', index: 2, accentColor: accentColor, isDark: isDark),
              _buildNavItem(icon: Icons.menu, label: 'More', index: 3, accentColor: accentColor, isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index, required Color accentColor, required bool isDark}) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? accentColor : (isDark ? Colors.white38 : Colors.black45);
    
    return InkWell(
      onTap: () {
        if (index == 1) {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => const JournalHistoryScreen())
          );
        } else if (index == 3) {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => const SettingsScreen())
          );
        } else {
          setState(() {
            _selectedIndex = index;
          });
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          )
        ],
      ),
    );
  }

  Widget _buildHomeDashboard(
    BuildContext context, 
    String greeting, 
    String dateStr, 
    DateTime now,
    bool isDark,
    Color cardBg,
    Color textColor,
    Color subtextColor,
    Color accentColor,
  ) {
    return Consumer<JournalProvider>(
      builder: (context, provider, child) {
        String? todayMood;
        String? todayMoodTime;
        if (provider.entries.isNotEmpty) {
          final latest = provider.entries.first;
          if (latest.date.day == now.day && latest.date.month == now.month && latest.date.year == now.year) {
            todayMood = latest.mood;
            todayMoodTime = DateFormat('h:mm a').format(latest.date);
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting, style: TextStyle(fontSize: 16, color: subtextColor)),
                      const SizedBox(height: 4),
                      Text(
                        "Oshadi 🌿",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(height: 4),
                      Text(dateStr, style: TextStyle(fontSize: 14, color: subtextColor.withOpacity(0.7))),
                    ],
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: accentColor.withOpacity(0.15),
                      child: Icon(Icons.person_outline, color: accentColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Mood Check-in Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Text(todayMood != null ? _getMoodEmoji(todayMood) : '😐', style: const TextStyle(fontSize: 48)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("How are you feeling today?", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: textColor)),
                          const SizedBox(height: 4),
                          Text(
                            todayMood != null 
                              ? "You logged: $todayMood • $todayMoodTime" 
                              : "You haven't logged your mood yet.",
                            style: TextStyle(fontSize: 12, color: subtextColor),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodSelectionScreen()));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                todayMood != null ? "Change Mood" : "Log Mood",
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Stats Row
              Row(
                children: [
                  Expanded(child: _buildStatCard(cardBg: cardBg, textColor: textColor, subtextColor: subtextColor, isDark: isDark, icon: Icons.local_fire_department, iconColor: Colors.redAccent, title: "5 days", subtitle: "Current streak")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard(cardBg: cardBg, textColor: textColor, subtextColor: subtextColor, isDark: isDark, icon: Icons.menu_book, iconColor: accentColor, title: "${provider.entries.length} entries", subtitle: "This month")),
                ],
              ),
              const SizedBox(height: 16),

              // Daily Reflection Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 18, color: accentColor),
                        const SizedBox(width: 8),
                        Text("Daily Reflection", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '"What is one thing that made you smile today?"',
                      style: TextStyle(fontSize: 14, color: textColor, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyReflectionScreen()));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text("Write about it", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recent Journal Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Recent Journal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const JournalHistoryScreen()),
                      );
                    },
                    child: Text("View all", style: TextStyle(fontSize: 14, color: accentColor)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Recent List
              if (provider.isLoading)
                Center(child: CircularProgressIndicator(color: accentColor))
              else if (provider.entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(child: Text("No entries yet. Start writing!", style: TextStyle(color: subtextColor))),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.entries.length > 3 ? 3 : provider.entries.length, 
                  itemBuilder: (context, index) {
                    final entry = provider.entries[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: cardBg, 
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.02), blurRadius: 6, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Text(_getMoodEmoji(entry.mood), style: const TextStyle(fontSize: 32)),
                        title: Text(entry.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
                        subtitle: Text(entry.content, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: subtextColor)),
                        trailing: Icon(Icons.chevron_right, color: isDark ? Colors.white38 : Colors.black26),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => EntryDetailScreen(entry: entry))).then((_) => provider.loadEntries());
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required Color cardBg,
    required Color textColor,
    required Color subtextColor,
    required bool isDark,
    required IconData icon, 
    required Color iconColor, 
    required String title, 
    required String subtitle
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: subtextColor)),
              ],
            ),
          )
        ],
      ),
    );
  }
}