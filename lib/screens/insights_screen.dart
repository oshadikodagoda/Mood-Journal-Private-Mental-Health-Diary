import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/database_service.dart';
import '../models/journal_entry.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final DatabaseService _db = DatabaseService();
  bool _isLoading = true;
  Map<String, dynamic> _insightsData = {};
  List<JournalEntry> _recentEntries = [];

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    final data = await _db.getMoodInsightsData();
    final allEntries = await _db.getAllEntries();
    if (mounted) {
      setState(() {
        _insightsData = data;
        _recentEntries = allEntries.take(7).toList().reversed.toList();
        _isLoading = false;
      });
    }
  }

  double _moodToValue(String mood) {
    switch (mood) {
      case 'Very Happy': return 5.0;
      case 'Happy': return 4.0;
      case 'Neutral': return 3.0;
      case 'Sad': return 2.0;
      case 'Very Sad': return 1.0;
      default: return 3.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;
    final scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFFAF6EF);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        body: Center(child: CircularProgressIndicator(color: accentColor)),
      );
    }

    final moodCounts = (_insightsData['moodCounts'] as Map<String, int>?) ?? {};
    final topMood = _insightsData['topMood'] ?? 'None';
    final positivePct = (_insightsData['positivePercentage'] ?? 0.0) as double;
    final totalEntries = _insightsData['totalEntries'] ?? 0;

    // Trend spots from recent entries
    List<FlSpot> spots = [];
    if (_recentEntries.isNotEmpty) {
      for (int i = 0; i < _recentEntries.length; i++) {
        spots.add(FlSpot(i.toDouble(), _moodToValue(_recentEntries[i].mood)));
      }
    } else {
      spots = const [
        FlSpot(0, 3),
        FlSpot(1, 4),
        FlSpot(2, 4),
        FlSpot(3, 3),
        FlSpot(4, 5),
      ];
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        title: Text(
          "Your Mood Insights",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: textColor),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadInsights,
        color: accentColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overall Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B2E19) : const Color(0xFFE8F3E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accentColor.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Text('🌿', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            totalEntries > 0 ? "Most Frequent: $topMood" : "Start your journey",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF2E5A27),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            totalEntries > 0 
                              ? "$positivePct% positive reflection rate across $totalEntries journal entries."
                              : "Log your first journal entry to view mood analytics.",
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text(
                "Mood Distribution",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 12),

              // Distribution Bars
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMoodBar("Very Happy", '🤩', moodCounts['Very Happy'] ?? 0, totalEntries, const Color(0xFF81C784), textColor),
                    _buildMoodBar("Happy", '😊', moodCounts['Happy'] ?? 0, totalEntries, const Color(0xFFAED581), textColor),
                    _buildMoodBar("Neutral", '😐', moodCounts['Neutral'] ?? 0, totalEntries, const Color(0xFFFFD54F), textColor),
                    _buildMoodBar("Sad", '😔', moodCounts['Sad'] ?? 0, totalEntries, const Color(0xFFFFB74D), textColor),
                    _buildMoodBar("Very Sad", '😭', moodCounts['Very Sad'] ?? 0, totalEntries, const Color(0xFFE57373), textColor),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text(
                "Mood Trend",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 12),

              // Trend Chart using fl_chart
              Container(
                height: 220,
                padding: const EdgeInsets.only(top: 24, right: 24, left: 10, bottom: 12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: LineChart(
                  LineChartData(
                    minY: 1,
                    maxY: 5,
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          reservedSize: 32,
                          getTitlesWidget: (val, _) {
                            switch (val.toInt()) {
                              case 5: return const Text('🤩', style: TextStyle(fontSize: 14));
                              case 4: return const Text('😊', style: TextStyle(fontSize: 14));
                              case 3: return const Text('😐', style: TextStyle(fontSize: 14));
                              case 2: return const Text('😔', style: TextStyle(fontSize: 14));
                              case 1: return const Text('😭', style: TextStyle(fontSize: 14));
                              default: return const Text('');
                            }
                          },
                        ),
                      ),
                      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: accentColor,
                        barWidth: 4,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: accentColor.withOpacity(0.15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodBar(String label, String emoji, int count, int total, Color color, Color textColor) {
    double pct = total > 0 ? (count / total) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          SizedBox(width: 80, child: Text(label, style: TextStyle(fontSize: 13, color: textColor))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: Colors.grey.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 10,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text("$count", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
        ],
      ),
    );
  }
}