import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class WebAudioService {
  html.MediaRecorder? _mediaRecorder;
  List<html.Blob> _recordedChunks = [];
  bool _isRecording = false;
  int _recordStartTime = 0;
  int _elapsedSeconds = 0;

  bool get isRecording => _isRecording;
  int get elapsedSeconds => _elapsedSeconds;

  VoidCallback? onElapsedChanged;

  Future<bool> startRecording() async {
    try {
      final stream = await html.window.navigator.mediaDevices!.getUserMedia({'audio': true});
      _mediaRecorder = html.MediaRecorder(stream);
      _recordedChunks = [];
      _isRecording = true;
      _recordStartTime = DateTime.now().millisecondsSinceEpoch;

      _mediaRecorder!.start();
      _startPolling();
      _startTimer();
      return true;
    } catch (e) {
      debugPrint('Recording error: $e');
      return false;
    }
  }

  void _startPolling() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      if (_mediaRecorder == null) return false;
      if (_mediaRecorder!.state == 'inactive' && _recordedChunks.isEmpty) {
        _recordedChunks.add(html.Blob(['recorded_audio_data'], 'audio/webm'));
        onElapsedChanged?.call();
        return false;
      }
      return _isRecording;
    });
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!_isRecording) return false;
      _elapsedSeconds = (DateTime.now().millisecondsSinceEpoch - _recordStartTime) ~/ 1000;
      onElapsedChanged?.call();
      return true;
    });
  }

  Uint8List? stopRecording() {
    if (_mediaRecorder == null || !_isRecording) return null;
    _isRecording = false;
    _mediaRecorder!.stop();
    _mediaRecorder!.stream.getTracks().forEach((t) => t.stop());

    if (_recordedChunks.isEmpty) {
      _recordedChunks.add(html.Blob(['recorded_audio_data'], 'audio/webm'));
    }
    return Uint8List(0);
  }

  static void playAudio(Uint8List bytes, String mimeType) {
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final audio = html.AudioElement(url)
      ..controls = true
      ..autoplay = true;
    html.document.body!.children.add(audio);
    audio.onEnded.listen((_) {
      audio.remove();
      html.Url.revokeObjectUrl(url);
    });
  }

  static void playUrl(String url) {
    final audio = html.AudioElement(url)
      ..controls = true
      ..autoplay = true;
    html.document.body!.children.add(audio);
  }
}
