import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  // Theme mode: 0 = Light, 1 = Dark, 2 = System
  int _selectedTheme = 0;

  // Selected Accent color index
  int _selectedColorIndex = 0;
  final List<Color> _accentColors = const [
    Color(0xFF6E8F68), // Sage Green (Default)
    Color(0xFFC0AEE4), // Soft Purple
    Color(0xFFF3B8B8), // Peach / Pink
    Color(0xFFA2D2CB), // Soft Teal
    Color(0xFFF6D899), // Pastel Yellow
  ];

  // Text size slider value (12.0 to 20.0)
  double _fontSize = 15.0;

  // Reduce motion switch
  bool _reduceMotion = false;

  void _changeTheme(int index) {
    setState(() => _selectedTheme = index);
    final provider = context.read<ThemeProvider>();
    if (index == 0) {
      provider.setThemeMode(ThemeMode.light);
    } else if (index == 1) {
      provider.setThemeMode(ThemeMode.dark);
    } else {
      provider.setThemeMode(ThemeMode.system);
    }
  }

  void _onSave() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Appearance preferences saved!"),
        backgroundColor: Color(0xFF6E8F68),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _accentColors[_selectedColorIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAF6EF),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAF6EF),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Appearance",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Theme Selection ---
            _buildSectionHeader("Theme", subtextColor),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildThemeCard("Light", Icons.light_mode, 0, Colors.white, Colors.black87)),
                const SizedBox(width: 12),
                Expanded(child: _buildThemeCard("Dark", Icons.dark_mode, 1, const Color(0xFF2C2C2C), Colors.white)),
                const SizedBox(width: 12),
                Expanded(child: _buildThemeCard("System", Icons.settings_brightness, 2, const Color(0xFF3A3A3A), Colors.white70)),
              ],
            ),

            const SizedBox(height: 28),

            // --- 2. Accent Color ---
            _buildSectionHeader("Accent color", subtextColor),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_accentColors.length, (index) {
                final isSelected = _selectedColorIndex == index;
                final color = _accentColors[index];
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedColorIndex = index);
                    context.read<ThemeProvider>().setAccentColor(color);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? textColor : Colors.transparent,
                        width: isSelected ? 2.5 : 0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Center(
                            child: Icon(Icons.check, color: Colors.white, size: 22),
                          )
                        : null,
                  ),
                );
              }),
            ),

            const SizedBox(height: 28),

            // --- 3. Text Size ---
            _buildSectionHeader("Text size", subtextColor),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text("A", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: subtextColor)),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: activeColor,
                        thumbColor: activeColor,
                        inactiveTrackColor: isDark ? Colors.white24 : Colors.black12,
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: _fontSize,
                        min: 12.0,
                        max: 20.0,
                        divisions: 4,
                        onChanged: (val) => setState(() => _fontSize = val),
                      ),
                    ),
                  ),
                  Text("A", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- 4. Live Preview ---
            _buildSectionHeader("Preview", subtextColor),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                "Today was actually a really good day.",
                style: TextStyle(
                  fontSize: _fontSize,
                  color: textColor,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- 5. Reduce Motion Switch ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.motion_photos_off_outlined, color: subtextColor, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    "Reduce motion",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textColor),
                  ),
                  const Spacer(),
                  Switch(
                    value: _reduceMotion,
                    activeColor: activeColor,
                    onChanged: (val) => setState(() => _reduceMotion = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // --- Save Button ---
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  Widget _buildThemeCard(String title, IconData icon, int index, Color bg, Color textColor) {
    final isSelected = _selectedTheme == index;
    return GestureDetector(
      onTap: () => _changeTheme(index),
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF6E8F68) : Colors.black12,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}