import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart'; // For cross-platform paths
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';

class NewEntryScreen extends StatefulWidget {
  const NewEntryScreen({super.key});

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final _journalTextController = TextEditingController();
  late final AudioRecorder _audioRecorder;
  late final AudioPlayer _audioPlayer;
  bool _isRecording = false;
  bool _isPlaying = false;
  int _recordingTime = 0;
  String? _audioPath;
  final List<Map<String, dynamic>> _uploadedFiles = [];
  final List<Map<String, dynamic>> _moods = const [
    {'emoji': '😢', 'label': 'Unhappy', 'color': 0xFFF39C12},
    {'emoji': '😔', 'label': 'Sad', 'color': 0xFF4A4A4A},
    {'emoji': '😐', 'label': 'Normal', 'color': 0xFFD6B4E8},
    {'emoji': '😊', 'label': 'Good', 'color': 0xFF6B46C1},
    {'emoji': '😄', 'label': 'Happy', 'color': 0xFFFFC107},
  ];
  Map<String, dynamic>? _selectedMood;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() => _isPlaying = false);
    });
    _initializeRecorder();
    _journalTextController.addListener(_updateCharacterCount);
  }

  Future<void> _initializeRecorder() async {
    if (await _checkMicrophonePermission()) {
      try {
        bool hasPermission = await _audioRecorder.hasPermission();
        if (!hasPermission) {
          debugPrint('Microphone permission not granted');
          return;
        }
      } catch (e) {
        debugPrint('Recorder setup error: $e');
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _journalTextController.dispose();
    if (_isRecording) _audioRecorder.stop(); // Stop if recording
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _updateCharacterCount() {
    setState(() {});
  }

  Future<void> _startRecording() async {
    if (await _checkMicrophonePermission() && !_isRecording) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        _audioPath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _audioPath!,
        );
        setState(() => _isRecording = true);
        _startRecordingTimer();
      } catch (e) {
        debugPrint('Start recording error: $e');
        setState(() => _isRecording = false);
      }
    }
  }

  Future<void> _stopRecording() async {
    if (_isRecording) {
      try {
        await _audioRecorder.stop();
        setState(() => _isRecording = false);
        _stopRecordingTimer();
      } catch (e) {
        debugPrint('Stop recording error: $e');
        setState(() => _isRecording = false);
      }
    }
  }

  void _startRecordingTimer() {
    _recordingTime = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRecording) timer.cancel();
      setState(() => _recordingTime++);
    });
  }

  void _stopRecordingTimer() {
    _timer?.cancel();
    setState(() {});
  }

  Future<bool> _checkMicrophonePermission() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      debugPrint('Microphone permission denied');
    }
    return status.isGranted;
  }

  Future<void> _handleFileUpload() async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: true);
      if (result != null) {
        setState(() {
          for (final file in result.files) {
            _uploadedFiles.add({
              'id': DateTime.now().millisecondsSinceEpoch + _uploadedFiles.length,
              'name': file.name,
              'type': file.extension ?? '',
              'size': file.size,
              'path': file.path,
            });
          }
        });
      }
    } catch (e) {
      debugPrint('File picking error: $e');
    }
  }

  void _removeFile(int id) {
    setState(() => _uploadedFiles.removeWhere((file) => file['id'] == id));
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString();
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null || bytes == 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    int i = 0;
    double count = bytes.toDouble();
    while (count >= k && i < sizes.length - 1) {
      count /= k;
      i++;
    }
    return '${count.toStringAsFixed(2)} ${sizes[i]}';
  }

  IconData _fileIcon(String? extension) {
    final ext = (extension ?? '').toLowerCase();
    if (['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp', 'heic'].contains(ext)) return Icons.camera_alt;
    if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext)) return Icons.play_arrow;
    return Icons.description;
  }

  Future<void> _playAudio() async {
    if (_audioPath == null) return;
    try {
      setState(() => _isPlaying = true);
      await _audioPlayer.play(DeviceFileSource(_audioPath!));
    } catch (e) {
      debugPrint('Play error: $e');
      setState(() => _isPlaying = false);
    }
  }

  void _saveEntry() {
    if (_journalTextController.text.trim().isNotEmpty ||
        _uploadedFiles.isNotEmpty ||
        _audioPath != null ||
        _selectedMood != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Journal entry saved!')));
      _journalTextController.clear();
      setState(() {
        _audioPath = null;
        _uploadedFiles.clear();
        _selectedMood = null;
        _recordingTime = 0;
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Journal Entry'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                'How are you feeling today?',
                style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
              ),
              const SizedBox(height: 16),
              // Mood Selection
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How are you feeling today?',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _moods.map((mood) {
                        final bool selected = _selectedMood != null && _selectedMood!['label'] == mood['label'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedMood = mood),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: selected ? const Color(0xFF7C4DFF) : Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(mood['emoji'] as String, style: const TextStyle(fontSize: 22)),
                                const SizedBox(height: 4),
                                Text(
                                  mood['label'] as String,
                                  style: const TextStyle(fontSize: 10, color: Color(0xFFB39DDB)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s Prompt',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
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
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Your Thoughts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _journalTextController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Start writing or use voice input...',
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
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButton(
                          _isRecording ? '⏹️' : '🎤',
                          const Color(0xFFff6b6b),
                          _isRecording ? _stopRecording : _startRecording,
                        ),
                        const SizedBox(width: 20),
                        _buildActionButton('📁', const Color(0xFFff9ff3), _handleFileUpload),
                      ],
                    ),
                    if (_audioPath != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Voice ready (${_formatTime(_recordingTime)})',
                                style: const TextStyle(color: Colors.green),
                              ),
                              IconButton(
                                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                                onPressed: _isPlaying ? null : _playAudio,
                              ),
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
                            const Text('Attachments'),
                            const SizedBox(height: 8),
                            ..._uploadedFiles.map(
                              (file) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(_fileIcon(file['type']), color: const Color(0xFFB39DDB), size: 18),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 180,
                                              child: Text(
                                                '${file['name']}',
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ),
                                            Text(
                                              _formatFileSize(file['size'] as int?),
                                              style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                                      onPressed: () => _removeFile(file['id'] as int),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveEntry,
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
                          'Save Entry',
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
