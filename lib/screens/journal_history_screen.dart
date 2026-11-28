import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/journal_entry.dart';
import '../providers/journal_provider.dart';
import 'entry_detail_screen.dart';

class JournalHistoryScreen extends StatefulWidget {
  const JournalHistoryScreen({super.key});

  @override
  State<JournalHistoryScreen> createState() => _JournalHistoryScreenState();
}

class _JournalHistoryScreenState extends State<JournalHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedMoodFilter = "All"; // Active mood filter
  int _viewMode = 0; // 0 = List, 1 = Calendar

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final List<String> _moodOptions = [
    "All", "Very Happy", "Happy", "Neutral", "Sad", "Very Sad"
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
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

  Color _getMoodBgColor(String mood, bool isDark) {
    if (isDark) return const Color(0xFF2C2C2C);
    switch (mood) {
      case 'Very Happy': return const Color(0xFFFFF3D6); 
      case 'Happy': return const Color(0xFFFFF3D6);
      case 'Neutral': return const Color(0xFFF0F0F0); 
      case 'Sad': return const Color(0xFFEBE4F5); 
      case 'Very Sad': return const Color(0xFFEBE4F5);
      case 'Calm': return const Color(0xFFE8F3E9); 
      default: return const Color(0xFFFFF0F0); 
    }
  }

  // --- FILTER MODAL BOTTOM SHEET (Member 3 - FR11) ---
  void _showFilterModal(bool isDark, Color cardBg, Color textColor, Color subtextColor, Color accentColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Filter by Mood",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => _selectedMoodFilter = "All");
                          Navigator.pop(ctx);
                        },
                        child: Text("Reset", style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: _moodOptions.map((mood) {
                      final isSelected = _selectedMoodFilter == mood;
                      return ChoiceChip(
                        label: Text(
                          mood == "All" ? "All Moods" : "${_getMoodEmoji(mood)} $mood",
                          style: TextStyle(
                            color: isSelected ? Colors.white : textColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: accentColor,
                        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
                        onSelected: (selected) {
                          setState(() {
                            _selectedMoodFilter = mood;
                          });
                          Navigator.pop(ctx);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;
    final scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFFAF6EF);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          "Journal",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: textColor),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Consumer<JournalProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(child: CircularProgressIndicator(color: accentColor));
            }

            // Multi-criteria filter: Keyword (FR10) + Mood Tag (FR11)
            final filteredEntries = provider.entries.where((entry) {
              final query = _searchQuery.toLowerCase();
              final matchesQuery = query.isEmpty || 
                  entry.title.toLowerCase().contains(query) || 
                  entry.content.toLowerCase().contains(query);
              final matchesMood = _selectedMoodFilter == "All" || entry.mood == _selectedMoodFilter;
              return matchesQuery && matchesMood;
            }).toList();

            return Column(
              children: [
                // Search Bar + Tune/Filter Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(color: textColor),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search your journal...',
                            hintStyle: TextStyle(color: subtextColor),
                            prefixIcon: Icon(Icons.search, color: subtextColor),
                            filled: true,
                            fillColor: cardBg,
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: _selectedMoodFilter != "All" ? accentColor : cardBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.tune, 
                            color: _selectedMoodFilter != "All" ? Colors.white : textColor,
                          ),
                          onPressed: () => _showFilterModal(isDark, cardBg, textColor, subtextColor, accentColor),
                        ),
                      )
                    ],
                  ),
                ),
                
                // Active Filter Tag Indicator
                if (_selectedMoodFilter != "All")
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                    child: Row(
                      children: [
                        Chip(
                          label: Text("Filter: $_selectedMoodFilter", style: const TextStyle(fontSize: 12, color: Colors.white)),
                          backgroundColor: accentColor,
                          deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
                          onDeleted: () => setState(() => _selectedMoodFilter = "All"),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // List / Calendar Toggle Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _viewMode = 0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _viewMode == 0 ? accentColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "List",
                                style: TextStyle(
                                  color: _viewMode == 0 ? Colors.white : subtextColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _viewMode = 1),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _viewMode == 1 ? accentColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Calendar",
                                style: TextStyle(
                                  color: _viewMode == 1 ? Colors.white : subtextColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Content: List View or Calendar View
                Expanded(
                  child: _viewMode == 0 
                    ? _buildListView(filteredEntries, provider, isDark, cardBg, textColor, subtextColor, accentColor)
                    : _buildCalendarView(filteredEntries, provider, isDark, cardBg, textColor, subtextColor, accentColor),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendarView(List<JournalEntry> entries, JournalProvider provider, bool isDark, Color cardBg, Color textColor, Color subtextColor, Color accentColor) {
    final dayEntries = entries.where((e) => isSameDay(e.date, _selectedDay)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                leftChevronIcon: Icon(Icons.chevron_left, color: textColor),
                rightChevronIcon: Icon(Icons.chevron_right, color: textColor),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: subtextColor),
                weekendStyle: TextStyle(color: subtextColor),
              ),
              eventLoader: (day) {
                return entries.where((e) => isSameDay(e.date, day)).toList();
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(color: textColor),
                weekendTextStyle: TextStyle(color: textColor),
                outsideTextStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
                todayDecoration: BoxDecoration(
                  color: accentColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: Color(0xFFE57373),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            _selectedDay == null 
              ? "Entries" 
              : "Entries for ${DateFormat('MMMM d, yyyy').format(_selectedDay!)}",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 10),

          if (dayEntries.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Text("No matching entries for this day.", style: TextStyle(color: subtextColor)),
            )
          else
            ...dayEntries.map((entry) => _buildEntryTile(entry, provider, isDark, cardBg, textColor, subtextColor, accentColor)).toList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildListView(List<JournalEntry> entries, JournalProvider provider, bool isDark, Color cardBg, Color textColor, Color subtextColor, Color accentColor) {
    if (entries.isEmpty) {
      return Center(child: Text("No entries match your search/filter.", style: TextStyle(color: subtextColor)));
    }

    Map<String, List<JournalEntry>> groupedEntries = {};
    for (var entry in entries) {
      String monthYear = DateFormat('MMMM yyyy').format(entry.date);
      if (!groupedEntries.containsKey(monthYear)) {
        groupedEntries[monthYear] = [];
      }
      groupedEntries[monthYear]!.add(entry);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      itemCount: groupedEntries.length,
      itemBuilder: (context, index) {
        String monthYear = groupedEntries.keys.elementAt(index);
        List<JournalEntry> monthEntries = groupedEntries[monthYear]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
              child: Text(
                monthYear,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
            ...monthEntries.map((entry) => _buildEntryTile(entry, provider, isDark, cardBg, textColor, subtextColor, accentColor)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildEntryTile(JournalEntry entry, JournalProvider provider, bool isDark, Color cardBg, Color textColor, Color subtextColor, Color accentColor) {
    final dateStr = DateFormat('MMM d').format(entry.date);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EntryDetailScreen(entry: entry)),
        ).then((_) => provider.loadEntries());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getMoodBgColor(entry.mood, isDark),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(_getMoodEmoji(entry.mood), style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateStr, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: accentColor)),
                  const SizedBox(height: 2),
                  Text(entry.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor)),
                  const SizedBox(height: 4),
                  Text(entry.content, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: subtextColor)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: isDark ? Colors.white38 : Colors.black26),
          ],
        ),
      ),
    );
  }
}
