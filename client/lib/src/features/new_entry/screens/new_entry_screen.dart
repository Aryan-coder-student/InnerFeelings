import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_recorder2/audio_recorder2.dart';
import 'package:permission_handler/permission_handler.dart';

class NewEntryScreen extends StatefulWidget {
  const NewEntryScreen({super.key});

  @override
  _NewEntryScreenState createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final _journalTextController = TextEditingController();
  final AudioRecorder2 _audioRecorder = AudioRecorder2(); // Replaced with audio_recorder2
  bool _isRecording = false;
  int _recordingTime = 0;
  String? _audioPath;
  final List<Map<String, dynamic>> _uploadedFiles = [];
  String? _selectedMood;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _journalTextController.addListener(_updateCharacterCount);
  }

  Future<void> _initializeRecorder() async {
    if (await _checkMicrophonePermission()) {
      await _audioRecorder.initialize();
    }
  }

  @override
  void dispose() {
    _journalTextController.dispose();
    _audioRecorder.dispose(); // Cleanup for audio_recorder2
    super.dispose();
  }

  void _updateCharacterCount() {
    setState(() {});
  }

  Future<void> _startRecording() async {
    if (await _checkMicrophonePermission()) {
      _audioPath = await _audioRecorder.startRecording();
      setState(() => _isRecording = true);
    }
  }

  Future<void> _stopRecording() async {
    _audioPath = await _audioRecorder.stopRecording();
    setState(() => _isRecording = false);
  }

  Future<bool> _checkMicrophonePermission() async {
    var status = await Permission.microphone.request();
    return status.isGranted;
  }

  void _handleFileUpload() async {
    setState(() {
      _uploadedFiles.add({'id': DateTime.now().millisecondsSinceEpoch, 'name': 'sample.jpg', 'type': 'image/jpeg'});
    });
  }

  void _removeFile(int id) {
    setState(() => _uploadedFiles.removeWhere((file) => file['id'] == id));
  }

  void _saveEntry() {
    if (_journalTextController.text.trim().isNotEmpty || _uploadedFiles.isNotEmpty || _audioPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Journal entry saved!')));
      _journalTextController.clear();
      setState(() {
        _audioPath = null;
        _uploadedFiles.clear();
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'New Journal Entry',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 10),
            const Text(
              'How are you feeling today?',
              style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today\'s Prompt',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFf0f2f5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '"You seemed energetic yesterday. What\'s contributing to this positive momentum?"',
                      style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Color(0xFF666666)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your Thoughts',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _journalTextController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Start writing or use voice input...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFeeeeee), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton('🎤', Color(0xFFff6b6b), _isRecording ? _stopRecording : _startRecording),
                      const SizedBox(width: 20),
                      _buildActionButton('📷', Color(0xFF4ecdc4), () {}),
                      const SizedBox(width: 20),
                      _buildActionButton('📁', Color(0xFFff9ff3), _handleFileUpload),
                    ],
                  ),
                  if (_audioPath != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.green[50],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Voice Recording Ready', style: TextStyle(color: Colors.green)),
                            IconButton(icon: const Icon(Icons.play_arrow), onPressed: () {}),
                          ],
                        ),
                      ),
                    ),
                  if (_uploadedFiles.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Attached Files'),
                          ..._uploadedFiles.map((file) => ListTile(
                                title: Text(file['name']),
                                trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _removeFile(file['id'])),
                              )),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667eea),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Save Entry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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

  Widget _buildActionButton(String icon, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Center(child: Text(icon, style: const TextStyle(fontSize: 24, color: Colors.white))),
      ),
    );
  }
}