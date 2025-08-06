import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
// import 'package:share_plus/share_plus.dart';
import './src/features/new_entry.dart';

void main() {
  runApp(const MoodMindApp());
}

class MoodMindApp extends StatelessWidget {
  const MoodMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoodMind',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<String> _pages = ['dashboard', 'journal', 'avatar', 'community'];

  void _showPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF667eea),
      body: Center(
        child: Container(
          width: 375,
          height: 812,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 50,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  // Status Bar
                  Container(
                    height: 44,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'MoodMind',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Content
                  Expanded(child: _buildPage(_pages[_selectedIndex])),
                  // Bottom Navigation
                  Container(
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Color(0xFFeeeeee))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(0, '📊', 'Dashboard'),
                        _buildNavItem(1, '📖', 'Journal'),
                        _buildNavItem(2, '🤖', 'Luna'),
                        _buildNavItem(3, '👥', 'Community'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _selectedIndex == 3
          ? null
          : FloatingActionButton(
              backgroundColor: const Color(0xFF667eea),
              onPressed: () => _showPage(_pages.indexOf('new-entry')),
              child: const Text(
                '✏️',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              shape: const CircleBorder(),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildNavItem(int index, String icon, String label) {
    return GestureDetector(
      onTap: () => _showPage(index),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _selectedIndex == index
              ? const Color(0x33667eea)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF667eea),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(String pageId) {
    switch (pageId) {
      case 'dashboard':
        return const DashboardPage();
      case 'journal':
        return const JournalPage();
      case 'avatar':
        return const AvatarPage();
      case 'new-entry':
        return const NewEntryScreen();
      case 'community':
        return const CommunityPage();
      default:
        return const SizedBox();
    }
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Header
            const Text(
              'Welcome back, Alex!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your emotional journey this week',
              style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 30),
            // Stats
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard('12', 'Entries This Week'),
                _buildStatCard('7', 'Day Streak'),
                _buildStatCard('68%', 'Positive Mood'),
                _buildStatCard('45m', 'Avg Usage'),
              ],
            ),
            const SizedBox(height: 30),
            // Mood Chart
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFf8f9fa),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: const [
                  Text(
                    'Mood Trends',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: 15),
                  SizedBox(
                    height: 150,
                    child: Center(
                      child: Text(
                        '📈 Interactive mood chart would appear here',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Weekly Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0x33667eea), Color(0x33764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Text(
                    'This Week\'s Journey',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        '🎨 AI-Generated Comic Summary',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'View Full Summary',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String number, String label) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
// from here 
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
            const Text(
              'My Journal',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
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
            SnackBar(content: Text('Entries can only be added for the current date.')),
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
// till here 
class AvatarPage extends StatefulWidget {
  const AvatarPage({super.key});

  @override
  _AvatarPageState createState() => _AvatarPageState();
}

class _AvatarPageState extends State<AvatarPage> {
  String speechText =
      'Hi Alex! I noticed your mood has been quite positive lately. How are you feeling about your new project? I\'m here if you want to talk about it.';
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Your AI Companion',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Luna is here to listen and support',
              style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 30),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '🌙',
                  style: TextStyle(fontSize: 48, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Luna',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'AI Emotional Companion',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFf0f2f5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      speechText,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: Container(
                      width: 20,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFFf0f2f5),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildVoiceButton(
                  '🎤',
                  const Color(0xFFff6b6b),
                  () => print('Starting voice recording...'),
                ),
                const SizedBox(width: 20),
                _buildVoiceButton(
                  '▶️',
                  const Color(0xFF4ecdc4),
                  () => print('Playing avatar response...'),
                ),
                const SizedBox(width: 20),
                _buildVoiceButton(
                  '⏹️',
                  const Color(0xFFfeca57),
                  () => print('Stopping current action...'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Tap to speak, or type below',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 15),
            Container(
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
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Type your message to Luna...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFeeeeee),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF667eea),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_controller.text.trim().isNotEmpty) {
                          setState(() {
                            speechText =
                                'That\'s really interesting! I can sense from your writing that you\'re feeling quite positive about this. Would you like to explore what specifically is making you feel this way?';
                            _controller.clear();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667eea),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Send',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceButton(String icon, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: () {
        onPressed();
        // Add visual feedback
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Center(
          child: Text(
            icon,
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// class NewEntryPage extends StatelessWidget {
//   const NewEntryPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             const Text(
//               'New Journal Entry',
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF333333),
//               ),
//             ),
//             const SizedBox(height: 10),
//             const Text(
//               'How are you feeling today?',
//               style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
//             ),
//             const SizedBox(height: 30),
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 15,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Today\'s Prompt',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF333333),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Container(
//                     padding: const EdgeInsets.all(15),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFf0f2f5),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const Text(
//                       '"You seemed energetic yesterday. What\'s contributing to this positive momentum?"',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontStyle: FontStyle.italic,
//                         color: Color(0xFF666666),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Your Thoughts',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF333333),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   TextField(
//                     maxLines: 5,
//                     decoration: InputDecoration(
//                       hintText: 'Start writing or use voice input...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(
//                           color: Color(0xFFeeeeee),
//                           width: 2,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(
//                           color: Color(0xFF667eea),
//                           width: 2,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       _buildVoiceButton(
//                         '🎤',
//                         const Color(0xFFff6b6b),
//                         () => print('Voice input...'),
//                       ),
//                       const SizedBox(width: 20),
//                       _buildVoiceButton(
//                         '📷',
//                         const Color(0xFF4ecdc4),
//                         () => print('Add photo...'),
//                       ),
//                       const SizedBox(width: 20),
//                       _buildVoiceButton(
//                         '🎥',
//                         const Color(0xFFff9ff3),
//                         () => print('Add video...'),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   Center(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         // Simulate saving
//                         Navigator.pop(context); // Return to JournalPage
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF667eea),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 24,
//                           vertical: 12,
//                         ),
//                       ),
//                       child: const Text(
//                         'Save Entry',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildVoiceButton(String icon, Color color, VoidCallback onPressed) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: Container(
//         width: 60,
//         height: 60,
//         decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//         child: Center(
//           child: Text(
//             icon,
//             style: const TextStyle(fontSize: 24, color: Colors.white),
//           ),
//         ),
//       ),
//     );
//   }
// }

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Community',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Connect and share your journey',
              style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Local Groups',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFdddddd)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Global Chat',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildCommunityCard(
              'M',
              'Mindfulness Group',
              '2 new messages',
              'Daily meditation and emotional wellness discussions',
              '12 members',
              const Color(0xFF667eea),
            ),
            const SizedBox(height: 20),
            _buildCommunityCard(
              'W',
              'Work-Life Balance',
              'Active now',
              'Managing stress and finding balance in professional life',
              '28 members',
              const Color(0xFF4ecdc4),
            ),
            const SizedBox(height: 20),
            _buildCommunityCard(
              'A',
              'Anxiety Support',
              '1 hour ago',
              'Safe space for sharing and supporting each other',
              '45 members',
              const Color(0xFFff6b6b),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityCard(
    String avatar,
    String name,
    String time,
    String description,
    String members,
    Color badgeColor,
  ) {
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    avatar,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  members,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }
}