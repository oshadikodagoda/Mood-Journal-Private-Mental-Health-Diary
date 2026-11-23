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
  int _viewMode = 0; // 0 = List, 1 = Calendar

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

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

  Color _getMoodBgColor(String mood) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Journal",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black87),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Consumer<JournalProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Filter entries based on search query
            final filteredEntries = provider.entries.where((entry) {
              final query = _searchQuery.toLowerCase();
              return entry.title.toLowerCase().contains(query) || 
                     entry.content.toLowerCase().contains(query);
            }).toList();

            return Column(
              children: [
                // Search and Filter Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search your journal...',
                            hintStyle: const TextStyle(color: Colors.black38),
                            prefixIcon: const Icon(Icons.search, color: Colors.black38),
                            filled: true,
                            fillColor: Colors.white,
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.tune, color: Colors.black87),
                          onPressed: () {},
                        ),
                      )
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
                      color: Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _viewMode = 0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _viewMode == 0 ? const Color(0xFF6E8F68) : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "List",
                                style: TextStyle(
                                  color: _viewMode == 0 ? Colors.white : Colors.black54,
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
                                color: _viewMode == 1 ? const Color(0xFF6E8F68) : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Calendar",
                                style: TextStyle(
                                  color: _viewMode == 1 ? Colors.white : Colors.black54,
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

                // Content Area: List View or Calendar View
                Expanded(
                  child: _viewMode == 0 
                    ? _buildListView(filteredEntries, provider)
                    : _buildCalendarView(filteredEntries, provider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- CALENDAR VIEW (Member 3 - FR09) ---
  Widget _buildCalendarView(List<JournalEntry> entries, JournalProvider provider) {
    final dayEntries = entries.where((e) => isSameDay(e.date, _selectedDay)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                todayDecoration: BoxDecoration(
                  color: const Color(0xFF6E8F68).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFF6E8F68),
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 10),

          if (dayEntries.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: const Text("No journal entries for this day.", style: TextStyle(color: Colors.black45)),
            )
          else
            ...dayEntries.map((entry) => _buildEntryTile(entry, provider)).toList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- LIST VIEW ---
  Widget _buildListView(List<JournalEntry> entries, JournalProvider provider) {
    if (entries.isEmpty) {
      return const Center(child: Text("No entries found."));
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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            ...monthEntries.map((entry) => _buildEntryTile(entry, provider)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildEntryTile(JournalEntry entry, JournalProvider provider) {
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getMoodBgColor(entry.mood),
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
                  Text(dateStr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 2),
                  Text(entry.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(entry.content, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.black45)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}