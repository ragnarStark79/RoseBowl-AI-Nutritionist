// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> entries;

  const HistoryScreen({super.key, required this.entries});

  Map<String, List<Map<String, dynamic>>> _groupByDate() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var entry in entries) {
      final date = DateTime.parse(entry['timestamp']).toLocal();
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      grouped[dateKey] ??= [];
      grouped[dateKey]!.add(entry);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final groupedEntries = _groupByDate();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [const Color(0xFF1F2A44), const Color(0xFF0D1B2A)]
                : [const Color(0xFFF5F7FA), const Color(0xFFE0E7F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Calorie History',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : const Color(0xFF1A3C34),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF4CAF50)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: groupedEntries.isEmpty
                    ? Center(
                    child: Text('No history yet.',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white70 : const Color(0xFF388E3C))))
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: groupedEntries.length,
                  itemBuilder: (context, index) {
                    final date = groupedEntries.keys.elementAt(index);
                    final dayEntries = groupedEntries[date]!;
                    final dayTotal = dayEntries.fold<int>(
                        0, (sum, item) => sum + (item['nutrition']['calories'] as int));

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white.withOpacity(0.9),
                      child: ExpansionTile(
                        title: Text(date,
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                        subtitle: Text('Total: $dayTotal cal',
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: const Color(0xFF4CAF50))),
                        children: dayEntries.map((entry) {
                          final nutrition = entry['nutrition'] as Map<String, dynamic>;
                          return ListTile(
                            title: Text(entry['food'],
                                style: GoogleFonts.poppins(fontSize: 16)),
                            subtitle: Text(entry['quantity'],
                                style: GoogleFonts.poppins(
                                    fontSize: 14, color: Colors.grey[600])),
                            trailing: Text('${nutrition['calories']} cal',
                                style: GoogleFonts.poppins(
                                    fontSize: 14, color: const Color(0xFF4CAF50))),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}