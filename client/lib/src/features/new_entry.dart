import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '/src/core/models/sentiment_response.dart';
import '/src/core/config/sentiment_api.dart';
import '/src/core/config/wearable_api.dart';  
import '/src/core/models/wearable_data.dart';
import 'package:universal_html/html.dart' as html;

class NewEntryScreen extends StatefulWidget {
  const NewEntryScreen({super.key});

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final _journalTextController = TextEditingController();
  late final AudioRecorder _audioRecorder;
  late final AudioPlayer _audioPlayer;
  final SentimentApi _sentimentApi = SentimentApi();
  final WearableApi _wearableApi = WearableApi();
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isAnalyzing = false;
  bool _isFetchingWearable = false;
  int _recordingTime = 0;
  String? _audioPath;
  String? _sentimentError;
  String? _wearableError;
  WearableData? _wearableData;
  final List<Map<String, dynamic>> _uploadedFiles = [];
  final List<Map<String, dynamic>> _moods = const [
    {'emoji': '😢', 'label': 'Unhappy', 'color': 0xFFF39C12, 'sentiment': 'sadness'},
    {'emoji': '😔', 'label': 'Sad', 'color': 0xFF4A4A4A, 'sentiment': 'sadness'},
    {'emoji': '😐', 'label': 'Normal', 'color': 0xFFD6B4E8, 'sentiment': 'neutral'},
    {'emoji': '😊', 'label': 'Good', 'color': 0xFF6B46C1, 'sentiment': 'joy'},
    {'emoji': '😄', 'label': 'Happy', 'color': 0xFFFFC107, 'sentiment': 'joy'},
  ];
  Map<String, dynamic>? _selectedMood;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    });
    _initializeRecorder();
    _journalTextController.addListener(_updateCharacterCount);
    _fetchWearableData();
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

  Future<void> _fetchWearableData() async {
    if (kIsWeb) return; // Skip wearable data on web
    setState(() {
      _isFetchingWearable = true;
      _wearableError = null;
    });
    try {
      _wearableData = await _wearableApi.fetchWearableData();
    } catch (e) {
      if (mounted) {
        setState(() {
          _wearableError = 'Failed to fetch wearable data: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingWearable = false);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _journalTextController.dispose();
    if (_isRecording) _audioRecorder.stop();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _updateCharacterCount() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _startRecording() async {
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio recording is not supported on web')),
        );
      }
      return;
    }
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
        if (mounted) {
          setState(() => _isRecording = true);
        }
        _startRecordingTimer();
      } catch (e) {
        debugPrint('Start recording error: $e');
        if (mounted) {
          setState(() => _isRecording = false);
        }
      }
    }
  }

  Future<void> _stopRecording() async {
    if (_isRecording) {
      try {
        await _audioRecorder.stop();
        if (mounted) {
          setState(() => _isRecording = false);
        }
        _stopRecordingTimer();
      } catch (e) {
        debugPrint('Stop recording error: $e');
        if (mounted) {
          setState(() => _isRecording = false);
        }
      }
    }
  }

  void _startRecordingTimer() {
    _recordingTime = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRecording) timer.cancel();
      if (mounted) {
        setState(() => _recordingTime++);
      }
    });
  }

  void _stopRecordingTimer() {
    _timer?.cancel();
    if (mounted) {
      setState(() {});
    }
  }

  Future<bool> _checkMicrophonePermission() async {
    if (kIsWeb) return true; // Web handles permissions differently
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      debugPrint('Microphone permission denied');
    }
    return status.isGranted;
  }

  Future<void> _handleFileUpload() async {
    try {
      if (kIsWeb) {
        // Web file picking using universal_html
        final input = html.FileUploadInputElement()..accept = '*/*';
        input.multiple = true;
        input.click();
        await input.onChange.first;
        final files = input.files;
        if (files != null && files.isNotEmpty && mounted) {
          setState(() {
            for (var file in files) {
              _uploadedFiles.add({
                'id': DateTime.now().millisecondsSinceEpoch + _uploadedFiles.length,
                'name': file.name,
                'type': file.name.split('.').last.toLowerCase(),
                'size': file.size,
                'path': null, // Path not available on web
              });
            }
          });
        }
      } else {
        // Mobile/desktop file picking using file_picker
        final result = await FilePicker.platform.pickFiles(allowMultiple: true);
        if (result != null && mounted) {
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
      }
    } catch (e) {
      debugPrint('File picking error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File picking error: $e')),
        );
      }
    }
  }

  void _removeFile(int id) {
    if (mounted) {
      setState(() => _uploadedFiles.removeWhere((file) => file['id'] == id));
    }
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
    if (_audioPath == null || kIsWeb) {
      if (kIsWeb && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio playback is not supported on web')),
        );
      }
      return;
    }
    try {
      setState(() => _isPlaying = true);
      await _audioPlayer.play(DeviceFileSource(_audioPath!));
    } catch (e) {
      debugPrint('Play error: $e');
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    }
  }

  Future<void> _saveEntry() async {
    if (_journalTextController.text.trim().isNotEmpty ||
        _uploadedFiles.isNotEmpty ||
        _audioPath != null ||
        _selectedMood != null) {
      if (_journalTextController.text.trim().isNotEmpty) {
        setState(() {
          _isAnalyzing = true;
          _sentimentError = null;
        });
        try {
          final sentiment = await _sentimentApi.analyzeSentiment(_journalTextController.text.trim());
          if (mounted) {
            setState(() {
              _selectedMood = _moods.firstWhere(
                (mood) => mood['sentiment'] == sentiment.topLabel,
                orElse: () => _moods.firstWhere((mood) => mood['label'] == 'Normal'),
              );
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Journal entry saved! Predominant emotion: ${sentiment.topLabel}'),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _sentimentError = 'Failed to analyze sentiment: $e';
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_sentimentError ?? 'Error analyzing sentiment'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() => _isAnalyzing = false);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Journal entry saved!')),
          );
        }
      }
      if (mounted) {
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
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('New Journal Entry'),
      backgroundColor: const Color(0xFF667eea),
      foregroundColor: Colors.white,
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                'How are you feeling today?',
                style: TextStyle(fontSize: 16, color: Color(0xFF666666), fontFamily: 'NotoSans'),
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'NotoSans',
                      ),
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
                                Text(
                                  mood['emoji'] as String,
                                  style: const TextStyle(fontSize: 22, fontFamily: 'NotoSans'),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  mood['label'] as String,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFFB39DDB),
                                    fontFamily: 'NotoSans',
                                  ),
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
              // Wearable Analytics
              if (!kIsWeb) // Skip wearable section on web
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
                        'Wearable Analytics',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'NotoSans',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _isFetchingWearable
                          ? const Center(
                              child: SpinKitFadingCircle(
                                color: Color(0xFF667eea),
                                size: 50.0,
                              ),
                            )
                          : _wearableError != null
                              ? Text(
                                  _wearableError!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontFamily: 'NotoSans',
                                  ),
                                )
                              : _wearableData == null
                                  ? const Text(
                                      'No wearable data available',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'NotoSans',
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (_wearableData!.heartRate != null)
                                          Text(
                                            'Heart Rate: ${_wearableData!.heartRate!.toStringAsFixed(0)} bpm',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontFamily: 'NotoSans',
                                            ),
                                          ),
                                        if (_wearableData!.sleepHours != null)
                                          Text(
                                            'Sleep: ${_wearableData!.sleepHours!.toStringAsFixed(1)} hours',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontFamily: 'NotoSans',
                                            ),
                                          ),
                                        if (_wearableData!.oxygenLevel != null)
                                          Text(
                                            'Oxygen Level: ${_wearableData!.oxygenLevel!.toStringAsFixed(1)}%',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontFamily: 'NotoSans',
                                            ),
                                          ),
                                        if (_wearableData!.steps != null)
                                          Text(
                                            'Steps: ${_wearableData!.steps} steps',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontFamily: 'NotoSans',
                                            ),
                                          ),
                                      ],
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
                        fontFamily: 'NotoSans',
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
                          fontFamily: 'NotoSans',
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
                        fontFamily: 'NotoSans',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _journalTextController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Start writing or use voice input...',
                        hintStyle: const TextStyle(fontFamily: 'NotoSans'),
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
                    if (_audioPath != null && !kIsWeb)
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
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontFamily: 'NotoSans',
                                ),
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
                            const Text(
                              'Attachments',
                              style: TextStyle(fontFamily: 'NotoSans'),
                            ),
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
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: 'NotoSans',
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _formatFileSize(file['size'] as int?),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF666666),
                                                fontFamily: 'NotoSans',
                                              ),
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
                      child: _isAnalyzing
                          ? const SpinKitFadingCircle(
                              color: Color(0xFF667eea),
                              size: 50.0,
                            )
                          : ElevatedButton(
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
                                  fontFamily: 'NotoSans',
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
      )
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