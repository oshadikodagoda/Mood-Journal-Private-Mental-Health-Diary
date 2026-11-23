import 'package:flutter/material.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  // 0: PDF, 1: CSV, 2: JSON
  int _selectedFormat = 0;

  bool _includeEmotions = true;
  bool _includeInsights = false;
  bool _isExporting = false;

  void _onExport() async {
    setState(() => _isExporting = true);

    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() => _isExporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Journal exported successfully!"),
          backgroundColor: Color(0xFF6E8F68),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EF), // Soft cream
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF6EF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Export Data",
          style: TextStyle(
            color: Colors.black87,
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
            // Top Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
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
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F3E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.file_download_outlined, color: Color(0xFF6E8F68), size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      "Download a copy of your journal to keep or share with someone you trust.",
                      style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Format Selection
            _buildSectionHeader("Format"),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildFormatTile("PDF Document", "Best for reading & printing", 0),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _buildFormatTile("CSV Spreadsheet", "Open in Excel or Sheets", 1),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _buildFormatTile("JSON", "For backups & developers", 2),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Date Range
            _buildSectionHeader("Date range"),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Text("All time • Current year", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  Spacer(),
                  Icon(Icons.calendar_today_outlined, size: 20, color: Colors.black45),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Include Options
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text("Include emotions & tags", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    value: _includeEmotions,
                    activeColor: const Color(0xFF6E8F68),
                    onChanged: (val) => setState(() => _includeEmotions = val),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    title: const Text("Include mood insights", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    value: _includeInsights,
                    activeColor: const Color(0xFF6E8F68),
                    onChanged: (val) => setState(() => _includeInsights = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // Export Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isExporting ? null : _onExport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6E8F68),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: _isExporting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        "Export Entries",
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildFormatTile(String title, String subtitle, int index) {
    final isSelected = _selectedFormat == index;
    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? const Color(0xFF6E8F68) : Colors.black38,
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black45)),
      onTap: () => setState(() => _selectedFormat = index),
    );
  }
}