import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/src/core/services/api_service.dart';
import './new_entry.dart';
import './insights.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, Map<String, dynamic>> _journalEntries = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJournalEntries();
  }

  Future<void> _loadJournalEntries() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final entries = await ApiService.getAllJournalEntries();
      final Map<DateTime, Map<String, dynamic>> formattedEntries = {};

      entries.forEach((dateString, entryData) {
        final date = DateTime.parse(dateString);
        formattedEntries[date] = {
          'emoji': entryData['emoji'],
          'topLabel': entryData['topLabel'],
          'topScore': entryData['topScore'],
        };
      });

      setState(() {
        _journalEntries = formattedEntries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading journal entries: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showJournalEntry(DateTime date) async {
    final today = DateTime.now();
    final isToday = date.year == today.year && 
                   date.month == today.month && 
                   date.day == today.day;
    
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    
    try {
      final entry = await ApiService.getJournalEntry(dateString);
      
      if (entry != null) {
        // Show existing entry
        _showEntryPopup(date, entry);
      } else if (isToday) {
        // Create new entry for today
        _createNewEntry(date);
      } else {
        // Show message for past dates
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No entry for this date. You can only create entries for today.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading entry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _createNewEntry(DateTime date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewEntryScreen(selectedDate: date),
      ),
    ).then((result) {
      if (result == true) {
        // Entry was created successfully, reload data
        _loadJournalEntries();
      }
    });
  }

  void _showEntryPopup(DateTime date, Map<String, dynamic> entry) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(
              maxHeight: 500,
              maxWidth: 335,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 24),
                      Text(
                        DateFormat('HH:mm:ss').format(date),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(Icons.close, size: 24),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Entry title (you might want to store this in your API)
                        Text(
                          'Journal Entry',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        
                        // Entry content (you might want to store this in your API)
                        Text(
                          'Your journal entry for ${DateFormat('MMMM d, yyyy').format(date)}',
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 20),
                        
                        // Mood and insights
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Text(entry['emoji'] ?? '😐', style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat('HH:mm').format(date),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Insights button
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                                _showInsights(date, entry);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF667eea),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Insights',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showInsights(DateTime date, Map<String, dynamic> entry) {
    // Create a mock journal entry for insights page
    final journalEntry = JournalEntry(
      title: 'Journal Entry',
      content: 'Your journal entry for ${DateFormat('MMMM d, yyyy').format(date)}',
      time: DateFormat('HH:mm').format(date),
      mood: entry['emoji'] ?? '😐',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InsightsPage(
          entry: journalEntry,
          date: date,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row (mode toggle, bell, avatar)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: const [
                      Text('LIGHT', style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(width: 6),
                      Icon(Icons.wb_sunny_outlined, size: 18),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.notifications_none),
                ),
                const SizedBox(width: 12),
                const CircleAvatar(radius: 22, backgroundColor: Color(0xFFFFC045), child: Icon(Icons.person, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 14),

            // Calendar card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: _isLoading
                  ? const SizedBox(
                      height: 400,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : TableCalendar<Map<String, dynamic>>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      calendarFormat: CalendarFormat.month,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextFormatter: (date, locale) {
                          return '${_monthName(date.month)} ${date.year}';
                        },
                        leftChevronIcon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
                        rightChevronIcon: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black87),
                        titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                        headerPadding: const EdgeInsets.only(top: 4, bottom: 8),
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(color: Colors.grey),
                        weekendStyle: TextStyle(color: Colors.grey),
                      ),
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        todayDecoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: Color(0x33667eea),
                          shape: BoxShape.circle,
                        ),
                      ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        _showJournalEntry(selectedDay);
                      },
                      onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          final isCurrentMonth = day.month == _focusedDay.month;
                          final entry = _journalEntries[DateTime(day.year, day.month, day.day)];

                          if (!isCurrentMonth) {
                            return const SizedBox.shrink();
                          }

                          if (entry != null) {
                            return Center(
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                                child: Center(
                                  child: Text(
                                    entry['emoji'] ?? '😐',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                            );
                          }

                          return Center(
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
                          );
                        },
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Recent entries',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),

            // Show recent entries from API data
            ..._journalEntries.entries.take(3).map((entry) {
              final date = entry.key;
              final data = entry.value;
              return _RecentEntryTile(
                entry: _RecentEntry(
                  title: 'Journal Entry',
                  subtitle: 'Your entry for ${DateFormat('MMM d').format(date)}',
                  time: DateFormat('HH:mm').format(date),
                  date: DateFormat('MMM d, yyyy').format(date),
                  emoji: data['emoji'] ?? '😐',
                ),
              );
            }).toList(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

class JournalEntry {
  final String title;
  final String content;
  final String time;
  final String mood;

  JournalEntry({
    required this.title,
    required this.content,
    required this.time,
    required this.mood,
  });
}

class _RecentEntry {
  final String title;
  final String subtitle;
  final String time;
  final String date;
  final String emoji;
  const _RecentEntry({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.date,
    required this.emoji,
  });
}

class _RecentEntryTile extends StatelessWidget {
  final _RecentEntry entry;
  const _RecentEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
              Container(
            width: 4,
            height: 36,
                decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                  entry.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
              Text(
                  entry.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Row(
                    children: [
                    Text(entry.time, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(width: 8),
                    Text(entry.date, style: const TextStyle(fontSize: 12, color: Colors.black45)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(entry.emoji, style: const TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
