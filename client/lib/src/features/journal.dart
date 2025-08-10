import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import './new_entry.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  DateTime selectedDate = DateTime.now(); // Updated to 2025-08-03 03:41 PM IST

  // Sample journal entries mapped by date
  final Map<DateTime, Map<String, dynamic>> journalEntries = {
    DateTime(2025, 7, 30): {
      'mood': '😊 Happy',
      'content':
          'Had a great meeting with the team today. Feeling really positive about the new project direction. The AI picked up on my excitement from my voice tone!',
      'time': '2:30 PM',
      'media': ['🎤', '📷'],
      'mediaLabels': 'Voice + Photo',
    },
    DateTime(2025, 7, 25): {
      'mood': '😰 Anxious',
      'content':
          'Feeling a bit overwhelmed with the upcoming deadlines. My heart rate was elevated according to my watch data. Need to practice some breathing exercises.',
      'time': '8:15 PM',
      'media': ['🎤'],
      'mediaLabels': 'Voice + Biometrics',
    },
    DateTime(2025, 8, 3): {
      'mood': '😊 Happy',
      'content': 'You logged into the app today!',
      'time': '03:41 PM',
      'media': [],
      'mediaLabels': 'None',
    },
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              'Your thoughts and emotions',
              style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 30),

            // Calendar Widget
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TableCalendar<Map<String, dynamic>>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: selectedDate,
                selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                eventLoader: (day) {
                  final entry =
                      journalEntries[DateTime(day.year, day.month, day.day)];
                  return entry != null ? [entry] : [];
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    selectedDate = selectedDay;
                  });
                },
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  markerDecoration: BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFF2196F3),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Color(0xFFFF9800),
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: Color(0xFF333333),
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Journal Entry Display
            _buildSelectedDateEntry(context),
          ],
        ),
      ),
    );
  }

  void _deleteEntry(DateTime date) {
    setState(() {
      journalEntries.remove(date);
    });
  }

 Widget _buildSelectedDateEntry(BuildContext context) {
  final entry =
      journalEntries[DateTime(selectedDate.year, selectedDate.month, selectedDate.day)];
  
  if (entry == null) {   
    return GestureDetector(
      onTap: () {
        final now = DateTime.now();
        final selected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
        if (selected.year == now.year && selected.month == now.month && selected.day == now.day) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewEntryScreen()),
          );
        } else {
          // Optionally show a message or do nothing for past/future dates
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entries can only be added for the current date.')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.edit_note, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(
              'No journal entry for ${_formatDate(selectedDate)}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
  return _buildJournalEntry(context,
    date: '${_formatDate(selectedDate)}, ${entry['time']}',
    mood: entry['mood'],
    content: entry['content'],
    media: List<String>.from(entry['media']),
    mediaLabels: entry['mediaLabels'],
    onDelete: () => _deleteEntry(DateTime(selectedDate.year, selectedDate.month, selectedDate.day)),
  );
}


  String _formatDate(DateTime date) {
    if (isSameDay(date, DateTime.now())) {
      return 'Today';
    } else if (isSameDay(
      date,
      DateTime.now().subtract(const Duration(days: 1)),
    )) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildJournalEntry(BuildContext context, {
    required String date,
    required String mood,
    required String content,
    required List<String> media,
    required String mediaLabels,
    required VoidCallback onDelete, // Added callback
  }) {
    String confirmText = '';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: const Border(
          left: BorderSide(color: Color(0xFF667eea), width: 5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  mood,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF333333),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              ...media.map(
                (icon) => Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: icon == '🎤'
                        ? const Color(0xFFff6b6b)
                        : const Color(0xFF4ecdc4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Text(
                mediaLabels,
                style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Type "permanently delete" to confirm:'),
                      TextField(
                        onChanged: (value) => confirmText = value,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (confirmText == 'permanently delete') {
                          onDelete(); // Call the callback to delete
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
            child: const Icon(Icons.delete, color: Colors.red, size: 24),
          ),
        ],
      ),
    );
  }
}