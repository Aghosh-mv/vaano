import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class VideoProcessor {
  html.VideoElement? _video;
  html.CanvasElement? _canvas;
  html.CanvasRenderingContext2D? _ctx;
  html.MediaRecorder? _recorder;
  List<html.Blob> _chunks = [];
  bool _isProcessing = false;
  double _progress = 0;
  StreamSubscription? _timeSub;
  List<void Function()> _cleanups = [];

  bool get isProcessing => _isProcessing;
  double get progress => _progress;

  VoidCallback? onProgress;

  Future<html.VideoElement> loadVideo(html.File file) async {
    final completer = Completer<html.VideoElement>();
    final url = html.Url.createObjectUrl(file);
    _video = html.VideoElement()
      ..src = url
      ..preload = 'auto'
      ..muted = true;
    _video!.onLoadedMetadata.listen((_) {
      _video!.onCanPlay.listen((_) => completer.complete(_video));
      _video!.play();
    });
    final v = await completer.future;
    v.pause();
    return v;
  }

  Future<void> trimVideo({
    required html.VideoElement video,
    required double startTime,
    required double endTime,
    required String outputFileName,
  }) async {
    _isProcessing = true;
    _progress = 0;
    _chunks = [];
    _cleanups = [];

    final w = video.videoWidth;
    final h = video.videoHeight;
    if (w == 0 || h == 0) {
      _isProcessing = false;
      return;
    }

    _canvas = html.CanvasElement(width: w, height: h);
    _ctx = _canvas!.context2D;

    final stream = _canvas!.captureStream(30) as html.MediaStream;
    _recorder = html.MediaRecorder(stream, {});

    final completer = Completer<void>();

    void onData(html.Event e) {
      final be = e as html.BlobEvent;
      if (be.data != null && be.data!.size > 0) _chunks.add(be.data!);
    }
    void onStop(html.Event _) {
      final blob = html.Blob(_chunks, 'video/webm');
      _downloadBlob(blob, outputFileName.replaceAll(RegExp(r'\.[^.]+$'), '.webm'));
      _isProcessing = false;
      completer.complete();
    }
    void onError(html.Event _) {
      _isProcessing = false;
      if (!completer.isCompleted) completer.complete();
    }

    _recorder!.addEventListener('dataavailable', onData);
    _recorder!.addEventListener('stop', onStop);
    _recorder!.addEventListener('error', onError);
    _cleanups = [
      () => _recorder!.removeEventListener('dataavailable', onData),
      () => _recorder!.removeEventListener('stop', onStop),
      () => _recorder!.removeEventListener('error', onError),
    ];

    _recorder!.start(100);
    video.currentTime = startTime;
    video.muted = true;

    _timeSub = video.onTimeUpdate.listen((_) {
      if (!_isProcessing) return;
      final ct = video.currentTime as double;
      if (ct >= endTime) {
        video.pause();
        _recorder!.stop();
        return;
      }
      _ctx!.drawImage(video, 0, 0);
      _progress = ((ct - startTime) / (endTime - startTime)).clamp(0.0, 1.0);
      onProgress?.call();
    });

    video.play();
    return completer.future;
  }

  Future<void> captureFrame({
    required html.VideoElement video,
    required double time,
  }) async {
    video.currentTime = time;
    await Future.delayed(const Duration(milliseconds: 200));
    final w = video.videoWidth;
    final h = video.videoHeight;
    if (w == 0 || h == 0) return;
    _canvas = html.CanvasElement(width: w, height: h);
    _ctx = _canvas!.context2D;
    _ctx!.drawImage(video, 0, 0);
    final blob = await _canvas!.toBlob('image/png');
    if (blob != null) {
      _downloadBlob(blob, 'frame_${time.toStringAsFixed(1)}s.png');
    }
  }

  void _downloadBlob(html.Blob blob, String fileName) {
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..style.display = 'none';
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  void dispose() {
    _timeSub?.cancel();
    for (final c in _cleanups) { c(); }
    _recorder?.stop();
    _video?.pause();
    _canvas?.remove();
  }
}
