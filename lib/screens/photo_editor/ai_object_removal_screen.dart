import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../../services/image_editor_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/image_viewer.dart';

class AiObjectRemovalScreen extends StatefulWidget {
  const AiObjectRemovalScreen({super.key});

  @override
  State<AiObjectRemovalScreen> createState() => _AiObjectRemovalScreenState();
}

class _AiObjectRemovalScreenState extends State<AiObjectRemovalScreen> {
  final ImageEditorService _editor = ImageEditorService();
  ui.Image? _previewImage;
  bool _isLoading = false;
  Offset? _startPoint;
  Offset? _endPoint;
  Rect? _selectionRect;

  @override
  void initState() {
    super.initState();
    _editor.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _editor.removeListener(() {});
    _editor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _editor.currentImage != null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Object Removal'),
        actions: [
          if (_selectionRect != null && hasImage)
            TextButton(
              onPressed: _removeObject,
              child: const Text('Remove', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  hasImage ? GestureDetector(
                    onPanStart: (d) => setState(() { _startPoint = d.localPosition; _endPoint = d.localPosition; }),
                    onPanUpdate: (d) => setState(() => _endPoint = d.localPosition),
                    onPanEnd: (_) => _finalizeRect(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox.expand(
                        child: RawImage(image: _previewImage ?? _editor.currentImage, fit: BoxFit.contain, filterQuality: FilterQuality.high),
                      ),
                    ),
                  ) : GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(20)),
                      child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.add_photo_alternate, size: 48, color: AppColors.textSecondary),
                        SizedBox(height: 12), Text('Tap to Import', style: TextStyle(color: AppColors.textSecondary)),
                      ]),
                    ),
                  ),
                  if (_startPoint != null && _endPoint != null)
                    Positioned.fill(child: IgnorePointer(
                      child: CustomPaint(painter: _RectPainter(_startPoint!, _endPoint!, _selectionRect)),
                    )),
                  if (_isLoading) Container(
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                    child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  ),
                ],
              ),
            ),
          ),
          if (hasImage) Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(children: [
              const Text('Drag on the image to select an object to remove', textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              if (_selectionRect == null) const Icon(Icons.touch_app, color: AppColors.textSecondary, size: 48),
              if (_selectionRect != null) Text('Selected: ${_selectionRect!.width.toInt()} x ${_selectionRect!.height.toInt()}',
                style: const TextStyle(color: AppColors.textSecondary)),
            ]),
          ),
        ],
      ),
    );
  }

  void _finalizeRect() {
    if (_startPoint == null || _endPoint == null) return;
    final left = _startPoint!.dx < _endPoint!.dx ? _startPoint!.dx : _endPoint!.dx;
    final top = _startPoint!.dy < _endPoint!.dy ? _startPoint!.dy : _endPoint!.dy;
    final w = (_startPoint!.dx - _endPoint!.dx).abs();
    final h = (_startPoint!.dy - _endPoint!.dy).abs();
    if (w > 5 && h > 5) setState(() => _selectionRect = Rect.fromLTWH(left, top, w, h));
  }

  Future<void> _pickImage() async {
    final image = await _editor.pickAndLoadImage();
    if (image != null && mounted) setState(() {
      _previewImage = null; _selectionRect = null; _startPoint = null; _endPoint = null;
    });
  }

  Future<void> _removeObject() async {
    final wImage = _editor.workingImage;
    if (wImage == null || _selectionRect == null) return;
    setState(() => _isLoading = true);
    final r = _selectionRect!;
    final rx = r.left.toInt().clamp(0, wImage.width - 1);
    final ry = r.top.toInt().clamp(0, wImage.height - 1);
    final rw = r.width.toInt().clamp(1, wImage.width - rx);
    final rh = r.height.toInt().clamp(1, wImage.height - ry);
    final srcY = (ry - rh).clamp(0, wImage.height - 1);
    final srcH = rh.clamp(1, wImage.height - srcY);
    final sourcePatch = img.copyCrop(wImage, x: rx, y: srcY, width: rw, height: srcH);
    img.compositeImage(wImage, sourcePatch, dstX: rx, dstY: ry);
    final bytes = Uint8List.fromList(img.encodePng(wImage));
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    setState(() { _previewImage = frame.image; _selectionRect = null; _startPoint = null; _endPoint = null; _isLoading = false; });
    _editor.refresh();
  }
}

class _RectPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Rect? selectionRect;
  _RectPainter(this.start, this.end, this.selectionRect);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = selectionRect ?? Rect.fromPoints(start, end);
    canvas.drawRect(rect, Paint()..color = AppColors.primary.withOpacity(0.2)..style = PaintingStyle.fill);
    canvas.drawRect(rect, Paint()..color = AppColors.primary..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_RectPainter old) =>
      old.start != start || old.end != end || old.selectionRect != selectionRect;
}
