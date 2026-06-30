import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../../services/image_editor_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/image_viewer.dart';

class WatermarkToolScreen extends StatefulWidget {
  const WatermarkToolScreen({super.key});

  @override
  State<WatermarkToolScreen> createState() => _WatermarkToolScreenState();
}

class _WatermarkToolScreenState extends State<WatermarkToolScreen> {
  final ImageEditorService _editor = ImageEditorService();
  final TextEditingController _textController = TextEditingController();
  ui.Image? _previewImage;
  bool _isLoading = false;
  String _watermarkType = 'text';

  static const List<String> types = ['text', 'logo', 'tiled'];

  @override
  void initState() {
    super.initState();
    _editor.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _editor.removeListener(() {});
    _editor.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Watermark')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  ImageViewer(
                    image: _previewImage ?? _editor.currentImage,
                    placeholder: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 48, color: AppColors.textSecondary),
                            SizedBox(height: 12),
                            Text('Tap to Import', style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_isLoading)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    ),
                ],
              ),
            ),
          ),
          if (_editor.currentImage != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Watermark Type', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    children: types.map((t) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(t[0].toUpperCase() + t.substring(1),
                              style: const TextStyle(color: Colors.white, fontSize: 12)),
                          selected: _watermarkType == t,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.cardDark,
                          onSelected: (_) => setState(() => _watermarkType = t),
                        ),
                      ),
                    )).toList(),
                  ),
                  if (_watermarkType != 'logo') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Watermark text...',
                        hintStyle: const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.cardDark,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _applyWatermark,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('Apply Watermark'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final image = await _editor.pickAndLoadImage();
    if (image != null && mounted) setState(() => _previewImage = null);
  }

  Future<void> _applyWatermark() async {
    final wImage = _editor.workingImage;
    if (wImage == null) return;
    setState(() => _isLoading = true);
    if (_watermarkType == 'text') {
      _applyTextWatermark(wImage);
    } else if (_watermarkType == 'logo') {
      _applyLogoWatermark(wImage);
    } else {
      _applyTiledWatermark(wImage);
    }
    final bytes = Uint8List.fromList(img.encodePng(wImage));
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    setState(() {
      _previewImage = frame.image;
      _isLoading = false;
    });
    _editor.refresh();
  }

  void _applyTextWatermark(img.Image wImage) {
    final text = _textController.text.isEmpty ? 'Watermark' : _textController.text;
    img.drawString(wImage, text,
        font: img.arial24, x: 20, y: wImage.height - 40, color: img.ColorRgb8(255, 255, 255));
  }

  void _applyLogoWatermark(img.Image wImage) {
    final logo = img.Image(width: 80, height: 80);
    final c1 = img.ColorRgb8(108, 63, 255);
    final c2 = img.ColorRgb8(255, 101, 132);
    for (int y = 0; y < 80; y++) {
      for (int x = 0; x < 80; x++) {
        logo.setPixel(x, y, (x + y) < 80 ? c1 : c2);
      }
    }
    img.compositeImage(wImage, logo, dstX: 20, dstY: 20);
  }

  void _applyTiledWatermark(img.Image wImage) {
    final text = _textController.text.isEmpty ? 'WM' : _textController.text;
    for (int y = 0; y < wImage.height; y += 80) {
      for (int x = 0; x < wImage.width; x += 120) {
        img.drawString(wImage, text,
            font: img.arial14, x: x, y: y, color: img.ColorRgb8(255, 255, 255));
      }
    }
  }
}
