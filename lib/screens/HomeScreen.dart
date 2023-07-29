import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRecording = false;
  bool _isPlaying = false;
  Timer? _timer;
  int _secondsElapsed = 0;
  FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  String _recordFilePath = '';
  final String apiUrl =
      'http://192.168.1.7:8080/TalkTally-HablarCuenta-1.0/S3ServiceRest/saveMeetingToS3';

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _secondsElapsed = 0;
  }

  void _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    //TODO change name of recorded meeting to: quantity of meetings recorded +1 (e.g: meeting 5)
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      _recordFilePath = '${appDocDir.path}/recorded_audio.wav';

      await _audioRecorder.openRecorder();
      await _audioRecorder.startRecorder(
        toFile: _recordFilePath,
        codec: Codec.pcm16WAV,
      );
      setState(() {
        _isRecording = true;
        _startTimer();
      });
    } catch (e) {
      print('Error starting meeting: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stopRecorder();
      await _audioRecorder.closeRecorder();
      setState(() {
        _isRecording = false;
        _stopTimer();
      });
    } catch (e) {
      print('Error stopping meeting: $e');
    }
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _stopPlayback();
    } else {
      await _playRecording();
    }
  }

  Future<void> _playRecording() async {
    if (_recordFilePath.isEmpty) {
      print('Record file path is empty.');
      return;
    }

    try {
      await _audioPlayer.openPlayer();
      await _audioPlayer.startPlayer(
        fromURI: _recordFilePath,
        codec: Codec.pcm16WAV,
      );
      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      print('Error playing recording: $e');
    }
  }

  Future<void> _stopPlayback() async {
    try {
      await _audioPlayer.stopPlayer();
      await _audioPlayer.closePlayer();
      setState(() {
        _isPlaying = false;
      });
    } catch (e) {
      print('Error stopping playback: $e');
    }
  }

  Future<String> _saveMeeting(File file) async {
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();
    //TODO show onscreen messagge
    if (response.statusCode == 200) {
      return 'File uploaded successfully.';
    } else {
      return 'Failed to upload file.';
    }
  }

  Future<void> _processMeeting() async {}

  Future<void> _deleteMeeting() async {
    try {
      if (_recordFilePath.isNotEmpty) {
        File file = File(_recordFilePath);
        if (await file.exists()) {
          await file.delete();
          setState(() {
            _recordFilePath = '';
          });
        }
      }
    } catch (e) {
      print('Error deleting recording: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _audioRecorder.openRecorder().then((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _audioRecorder.closeRecorder();
    _audioPlayer.closePlayer();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // RECORDING ICON
                  Icon(
                    _isRecording ? Icons.mic : Icons.mic_none,
                    size: 80,
                    color: Colors.blue,
                  ),

                  SizedBox(height: 16),

                  // RECORDING TEXT
                  Text(
                    _isRecording ? 'Recording...' : 'Not Recording',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 32),

                  // START / STOP MEETING BUTTON
                  ElevatedButton(
                    onPressed: _toggleRecording,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRecording ? Colors.red : Colors.green,
                      padding: EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 32.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _isRecording ? 'Stop Meeting' : 'Start Meeting',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),

                  SizedBox(height: 32),

                  // PROCESS THE MEETING
                  ElevatedButton(
                    onPressed: _isRecording && _recordFilePath.isNotEmpty
                        ? () {
                            _processMeeting();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 32.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Process Meeting',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),

                  SizedBox(height: 32),

                  // START / STOP PLAYING MEETING
                  ElevatedButton(
                    onPressed: _togglePlayback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 32.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _isPlaying ? 'Stop Playback' : 'Play Meeting',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),

                  SizedBox(height: 32),

                  // SAVE MEETING BUTTON
                  ElevatedButton(
                    onPressed: !_isRecording
                        ? () async {
                            File file = File(_recordFilePath);
                            String message = await _saveMeeting(file);
                            print(message);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 32.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Save Meeting',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),

                  SizedBox(height: 32),

                  // DELETE MEETING BUTTON
                  ElevatedButton(
                    onPressed: _recordFilePath.isNotEmpty
                        ? () {
                            _deleteMeeting();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 32.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Delete Meeting',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),

                  SizedBox(height: 32),

                  // MEETING TIME
                  Text(
                    'Meeting time: ${_formatTime(_secondsElapsed)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }
}

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('Usuario'),
            accountEmail: const Text('usuario@gmail.com'),
          ),
          ListTile(
            leading: Icon(Icons.record_voice_over_rounded),
            title: Text('Voices Manager'),
          ),
          ListTile(
            leading: Icon(Icons.record_voice_over_rounded),
            title: Text('Processed Meetings'),
          ),
          ListTile(
            leading: Icon(Icons.record_voice_over_rounded),
            title: Text('Saved Meetings'),
          ),
        ],
      ),
    );
  }
}
