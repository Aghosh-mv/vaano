import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../../theme/app_colors.dart';
import '../../services/image_editor_service.dart';
import '../../widgets/image_viewer.dart';

class BackgroundRemovalScreen extends StatefulWidget {
  const BackgroundRemovalScreen({super.key});

  @override
  State<BackgroundRemovalScreen> createState() => _BackgroundRemovalScreenState();
}

class _BackgroundRemovalScreenState extends State<BackgroundRemovalScreen> {
  final ImageEditorService _editor = ImageEditorService();
  bool _isProcessing = false;

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
    return Scaffold(
      appBar: AppBar(title: const Text('Background Removal')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  ImageViewer(
                    image: _editor.currentImage,
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
                            Icon(Icons.person_remove, size: 64, color: AppColors.primary),
                            SizedBox(height: 16),
                            Text('Tap to Select Photo',
                              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_isProcessing)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: AppColors.primary),
                            SizedBox(height: 16),
                            Text('Removing Background...', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _editor.currentImage == null ? _pickImage : _removeBackground,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(_editor.currentImage == null ? 'Select Photo' : 'Remove Background'),
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
    await _editor.pickAndLoadImage();
  }

  Future<void> _removeBackground() async {
    if (_editor.workingImage == null) return;
    setState(() => _isProcessing = true);

    final image = _editor.workingImage!;
    final threshold = 80;

    // Sample edge pixels to find background color
    num r = 0, g = 0, b = 0;
    int count = 0;
    for (int x = 0; x < image.width; x++) {
      for (int y = 0; y < 5; y++) {
        final p = image.getPixel(x, y);
        r += p.r; g += p.g; b += p.b; count++;
      }
      for (int y = image.height - 5; y < image.height; y++) {
        final p = image.getPixel(x, y);
        r += p.r; g += p.g; b += p.b; count++;
      }
    }
    if (count > 0) { r = r / count; g = g / count; b = b / count; }

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final p = image.getPixel(x, y);
        final dr = (p.r - r).abs();
        final dg = (p.g - g).abs();
        final db = (p.b - b).abs();
        if (dr + dg + db < threshold) {
          image.setPixelRgba(x, y, p.r, p.g, p.b, 0);
        }
      }
    }

    setState(() => _isProcessing = false);
  }
}
