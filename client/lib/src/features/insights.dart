import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import './journal.dart';

class InsightsPage extends StatelessWidget {
  final JournalEntry entry;
  final DateTime date;

  const InsightsPage({
    super.key,
    required this.entry,
    required this.date,
  });

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
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 50,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                color: Colors.white,
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
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'MoodMind',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Content Area
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Insights',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: const Icon(Icons.close, size: 24),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Date and time
                            Text(
                              '${_formatDate(date)} at ${entry.time}:25',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Entry title
                            Text(
                              entry.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Entry content
                            Text(
                              entry.content,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Mood Breakdown Section
                            const Text(
                              'Mood Breakdown',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Radar Chart
                            Container(
                              height: 250,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: RadarChart(
                                RadarChartData(
                                  dataSets: [
                                    RadarDataSet(
                                      dataEntries: [
                                        const RadarEntry(value: 3.5), // Happy
                                        const RadarEntry(value: 4.0), // Content
                                        const RadarEntry(value: 1.0), // Neutral
                                        const RadarEntry(value: 1.5), // Excited
                                        const RadarEntry(value: 2.5), // Euphoric
                                        const RadarEntry(value: 3.0), // Relaxed
                                      ],
                                      fillColor: const Color(0xFF667eea).withOpacity(0.3),
                                      borderColor: const Color(0xFF667eea),
                                      borderWidth: 2,
                                      entryRadius: 4,
                                    ),
                                  ],
                                  titleTextStyle: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  titlePositionPercentageOffset: 0.2,
                                  borderData: FlBorderData(show: false),
                                  radarBorderData: const BorderSide(color: Colors.grey, width: 1),
                                  radarBackgroundColor: Colors.transparent,
                                  gridBorderData: const BorderSide(color: Colors.grey, width: 1),
                                  getTitle: (index, angle) {
                                    const titles = ['Happy 😊', 'Content 😌', 'Neutral 😐', 'Excited 🤩', 'Euphoric 🥳', 'Relaxed 😇'];
                                    return RadarChartTitle(
                                      text: titles[index],
                                      angle: angle,
                                      positionPercentageOffset: 0.1,
                                    );
                                  },
                                  tickCount: 5,
                                  ticksTextStyle: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey,
                                  ),
                                  tickBorderData: const BorderSide(color: Colors.grey, width: 1),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Average Mood Section
                            const Text(
                              'Average Mood',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Score
                            Row(
                              children: [
                                const Text(
                                  '7.2/10 - Great',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Mood Tags
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildMoodTag('Happy', '😊', Colors.yellow.shade200),
                                _buildMoodTag('Content', '😌', Colors.blue.shade200),
                                _buildMoodTag('Neutral', '😐', Colors.grey.shade200),
                                _buildMoodTag('Excited', '🤩', Colors.orange.shade200),
                                _buildMoodTag('Euphoric', '🥳', Colors.yellow.shade100),
                                _buildMoodTag('Relaxed', '😇', Colors.purple.shade200),
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
            ),
          git checkout Nancy          ),
        ),
      ),
    );
  }

  Widget _buildMoodTag(String label, String emoji, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
} 