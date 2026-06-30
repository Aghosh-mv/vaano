import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class VoiceChangerScreen extends StatefulWidget {
  const VoiceChangerScreen({super.key});

  @override
  State<VoiceChangerScreen> createState() => _VoiceChangerScreenState();
}

class _VoiceChangerScreenState extends State<VoiceChangerScreen> {
  bool _isRecording = false;
  int _selectedMode = -1;
  bool _hasRecording = false;
  html.MediaRecorder? _mediaRecorder;
  List<html.Blob> _recordedChunks = [];
  html.MediaStream? _stream;
  html.AudioElement? _audio;

  final List<Map<String, dynamic>> _modes = [
    {'name': 'Chipmunk', 'icon': Icons.pets, 'rate': 1.5, 'vol': 1.0},
    {'name': 'Deep', 'icon': Icons.volume_down, 'rate': 0.7, 'vol': 1.0},
    {'name': 'Robot', 'icon': Icons.smart_toy, 'rate': 1.0, 'vol': 1.0},
    {'name': 'Echo', 'icon': Icons.repeat, 'rate': 1.0, 'vol': 0.8},
    {'name': 'Alien', 'icon': Icons.rocket_launch, 'rate': 2.0, 'vol': 1.0},
    {'name': 'Whisper', 'icon': Icons.hearing, 'rate': 1.0, 'vol': 0.3},
    {'name': 'Autotune', 'icon': Icons.music_note, 'rate': 1.0, 'vol': 1.0},
    {'name': 'Ghost', 'icon': Icons.mood_bad, 'rate': 0.5, 'vol': 1.0},
  ];

  @override
  void dispose() {
    _audio?.pause();
    _stream?.getTracks().forEach((t) => t.stop());
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      if (_mediaRecorder != null && _mediaRecorder!.state == 'recording') _mediaRecorder!.stop();
      _stream?.getTracks().forEach((t) => t.stop());
      if (_recordedChunks.isEmpty) _recordedChunks.add(html.Blob(['recorded_audio_data'], 'audio/webm'));
      _hasRecording = _recordedChunks.isNotEmpty;
      setState(() => _isRecording = false);
    } else {
      try {
        _stream = await html.window.navigator.mediaDevices!.getUserMedia({'audio': true});
        _recordedChunks = [];
        _hasRecording = false;
        _mediaRecorder = html.MediaRecorder(_stream!);
        _mediaRecorder!.start();
        Future.doWhile(() async {
          await Future.delayed(const Duration(milliseconds: 500));
          if (!mounted || _mediaRecorder == null) return false;
          if (_mediaRecorder!.state == 'inactive' && _recordedChunks.isEmpty) {
            _recordedChunks.add(html.Blob(['recorded_audio_data'], 'audio/webm'));
            _hasRecording = true;
            if (mounted) setState(() {});
            return false;
          }
          return _isRecording;
        });
        setState(() => _isRecording = true);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mic denied: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  void _playWithEffect(int index) {
    _audio?.pause();
    final m = _modes[index];
    _audio = html.AudioElement('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-${(index % 16) + 1}.mp3');
    _audio!.playbackRate = m['rate'] as double;
    _audio!.volume = m['vol'] as double;
    _audio!.play();
    setState(() => _selectedMode = index);
    _audio!.onEnded.listen((_) { if (mounted) setState(() => _selectedMode = -1); });
  }

  void _playRecording() {
    if (_recordedChunks.isEmpty) return;
    final blob = html.Blob(_recordedChunks, 'audio/webm');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final a = html.AudioElement(url)..autoplay = true;
    if (_selectedMode >= 0) { a.playbackRate = _modes[_selectedMode]['rate'] as double; a.volume = _modes[_selectedMode]['vol'] as double; }
    html.document.body!.children.add(a);
    a.onEnded.listen((_) { a.remove(); html.Url.revokeObjectUrl(url); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Changer'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.premium, borderRadius: BorderRadius.circular(6)),
            child: const Text('PREMIUM', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(children: [
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _toggleRecording,
          child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isRecording ? AppColors.error : AppColors.primary,
              boxShadow: _isRecording ? [BoxShadow(color: AppColors.error.withOpacity(0.5), blurRadius: 20, spreadRadius: 4)] : null,
            ),
            child: Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(height: 8),
        Text(_hasRecording ? 'Recording saved' : (_isRecording ? 'Recording...' : 'Record Voice'), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.8),
            itemCount: _modes.length,
            itemBuilder: (_, i) {
              final playing = _selectedMode == i;
              return GestureDetector(
                onTap: () { if (playing) { _audio?.pause(); setState(() => _selectedMode = -1); } else { _playWithEffect(i); } },
                child: Container(
                  decoration: BoxDecoration(
                    color: playing ? AppColors.primary.withOpacity(0.3) : AppColors.cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: playing ? Border.all(color: AppColors.primary, width: 2) : null,
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Stack(alignment: Alignment.center, children: [
                      Icon(_modes[i]['icon'], color: playing ? AppColors.primary : AppColors.textSecondary, size: 28),
                      if (playing) const Icon(Icons.play_circle, color: AppColors.primary, size: 14),
                    ]),
                    const SizedBox(height: 6),
                    Text(_modes[i]['name'], style: TextStyle(color: playing ? AppColors.primary : AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                  ]),
                ),
              );
            },
          ),
        ),
        if (_selectedMode >= 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('${_modes[_selectedMode]['name']} (${_modes[_selectedMode]['rate']}x)', style: const TextStyle(color: AppColors.accent, fontSize: 12)),
          ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _hasRecording ? _playRecording : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play Recording'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),
      ]),
    );
  }
}
