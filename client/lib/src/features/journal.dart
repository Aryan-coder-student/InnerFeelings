import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
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

  // Sample mood-per-day map (emoji + tint color)
  final Map<DateTime, Map<String, dynamic>> moodByDate = {
    DateTime(2025, 8, 3): {'emoji': '😟', 'color': const Color(0xFFB3C7FF)},
    DateTime(2025, 8, 5): {'emoji': '😢', 'color': const Color(0xFFD9C6FF)},
    DateTime(2025, 8, 7): {'emoji': '🙂', 'color': const Color(0xFFFFE0B2)},
    DateTime(2025, 8, 8): {'emoji': '😊', 'color': const Color(0xFFC8F7C5)},
    DateTime(2025, 8, 10): {'emoji': '😐', 'color': const Color(0xFFE6E6E6)},
    DateTime(2025, 8, 12): {'emoji': '🙂', 'color': const Color(0xFFFFE0B2)},
    DateTime(2025, 8, 13): {'emoji': '😢', 'color': const Color(0xFFD9C6FF)},
    DateTime(2025, 8, 16): {'emoji': '😊', 'color': const Color(0xFFC8F7C5)},
    DateTime(2025, 8, 18): {'emoji': '🙂', 'color': const Color(0xFFFFE0B2)},
    DateTime(2025, 8, 22): {'emoji': '😟', 'color': const Color(0xFFB3C7FF)},
  };

  // Sample journal entries - this would come from database
  final Map<DateTime, JournalEntry> journalEntries = {
    DateTime(2025, 8, 3): JournalEntry(
      title: 'Feeling overwhelmed today',
      content: 'Today was really challenging. I had multiple meetings and deadlines that made me feel stressed. The weather was gloomy which didn\'t help my mood either.',
      time: '14:30',
      mood: '😟',
    ),
    DateTime(2025, 8, 5): JournalEntry(
      title: 'Missing my family',
      content: 'I\'ve been thinking about home a lot today. Sometimes living alone gets lonely, even though I enjoy my independence. I should call mom tomorrow.',
      time: '20:15',
      mood: '😢',
    ),
    DateTime(2025, 8, 7): JournalEntry(
      title: 'Productive morning',
      content: 'Woke up early and got a lot done before noon. The morning routine really sets the tone for the day. Feeling accomplished and ready for what\'s next.',
      time: '11:45',
      mood: '🙂',
    ),
    DateTime(2025, 8, 8): JournalEntry(
      title: 'Great coffee date',
      content: 'Met with Sarah for coffee and we talked for hours. It\'s amazing how good conversations can lift your spirits. We should do this more often.',
      time: '16:20',
      mood: '😊',
    ),
    DateTime(2025, 8, 12): JournalEntry(
      title: 'The way those leaves fell',
      content: 'Walking through the park today, I noticed how beautifully the leaves were falling. It reminded me that change can be beautiful, even when it feels like an ending.',
      time: '18:35',
      mood: '🙂',
    ),
    DateTime(2025, 8, 16): JournalEntry(
      title: 'A Day of Mixed Feelings',
      content: 'Today was a rollercoaster of emotions. Started with a burst of energy, then a dip in the afternoon, and finally a calm evening. Trying to understand these shifts.',
      time: '12:09',
      mood: '😊',
    ),
  };

  final List<_RecentEntry> recent = const [
    _RecentEntry(
      title: 'A Day of Mixed Feelings',
      subtitle: 'Today was a rollercoaster of emotions...',
      time: '12:09',
      date: 'Aug 16, 2025',
      emoji: '😊',
    ),
    _RecentEntry(
      title: 'The way those leaves fell',
      subtitle: 'Walking through the park today...',
      time: '18:35',
      date: 'Aug 12, 2025',
      emoji: '🙂',
    ),
    _RecentEntry(
      title: 'Great coffee date',
      subtitle: 'Met with Sarah for coffee...',
      time: '16:20',
      date: 'Aug 8, 2025',
      emoji: '😊',
    ),
  ];

  void _showJournalEntry(DateTime date) {
    final entry = journalEntries[DateTime(date.year, date.month, date.day)];
    
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
                      const SizedBox(width: 24), // Spacer for centering
                      Text(
                        _formatTime(date),
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
                        if (entry != null) ...[
                          // Entry exists
                          Text(
                            entry.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            entry.content,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 20),
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
                                    Text(entry.mood, style: const TextStyle(fontSize: 20)),
                                    const SizedBox(width: 8),
                                    Text(
                                      entry.time,
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
                                  _showInsights(entry, date);
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
                        ] else ...[
                          // No entry
                          const Icon(
                            Icons.edit_note_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No entry for this day',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatDate(date),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              // TODO: Navigate to new entry page
                              print('Create new entry for ${_formatDate(date)}');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667eea),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Write Entry',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
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

  void _showInsights(JournalEntry entry, DateTime date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InsightsPage(
          entry: entry,
          date: date,
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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
              child: TableCalendar<Map<String, dynamic>>(
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
                    final key = DateTime(day.year, day.month, day.day);
                    final mood = moodByDate[key];

                    if (!isCurrentMonth) {
                      return const SizedBox.shrink();
                    }

                    if (mood != null) {
                      return Center(
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: (mood['color'] as Color).withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              mood['emoji'] as String,
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

            ...recent.map((e) => _RecentEntryTile(entry: e)).toList(),

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