import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;
import '../../services/image_editor_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/image_viewer.dart';

class HdrEnhancementScreen extends StatefulWidget {
  const HdrEnhancementScreen({super.key});

  @override
  State<HdrEnhancementScreen> createState() => _HdrEnhancementScreenState();
}

class _HdrEnhancementScreenState extends State<HdrEnhancementScreen> {
  final ImageEditorService _editor = ImageEditorService();
  ui.Image? _previewImage;
  bool _isLoading = false;
  String _selectedMode = 'auto';

  static const List<String> modes = ['auto', 'portrait', 'landscape', 'night'];

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
      appBar: AppBar(title: const Text('HDR Enhancement')),
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
                children: [
                  const Text('HDR Mode', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Row(
                    children: modes.map((m) {
                      final icons = {
                        'auto': Icons.auto_awesome,
                        'portrait': Icons.face,
                        'landscape': Icons.landscape,
                        'night': Icons.nightlight_round,
                      };
                      final isSelected = _selectedMode == m;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => _applyHdr(m),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary.withOpacity(0.3) : AppColors.cardDark,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected ? Border.all(color: AppColors.primary) : null,
                              ),
                              child: Column(
                                children: [
                                  Icon(icons[m]!, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 24),
                                  const SizedBox(height: 4),
                                  Text(m[0].toUpperCase() + m.substring(1),
                                      style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textSecondary, fontSize: 11)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final image = await ImageEditorService().pickAndLoadImage();
    if (image != null) {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes != null) {
        await _editor.loadBytes(bytes.buffer.asUint8List());
        _previewImage = null;
        _selectedMode = 'auto';
      }
    }
  }

  Future<void> _applyHdr(String mode) async {
    final wImage = _editor.workingImage;
    if (wImage == null) return;
    setState(() {
      _selectedMode = mode;
      _isLoading = true;
    });
    img.Image result;
    switch (mode) {
      case 'portrait':
        result = img.adjustColor(wImage, saturation: 0.3, contrast: 0.2);
        result = img.colorOffset(result, red: 10, green: 5, blue: 15);
        break;
      case 'landscape':
        result = img.adjustColor(wImage, saturation: 2.0, contrast: 1.5);
        result = img.colorOffset(result, red: 5, green: 0, blue: 15);
        break;
      case 'night':
        result = img.adjustColor(wImage, contrast: 1.3);
        result = img.colorOffset(result, red: 40, green: 40, blue: 50);
        break;
      default:
        result = img.adjustColor(wImage, saturation: 1.8, contrast: 1.4);
        result = img.colorOffset(result, red: 10, green: 5, blue: 15);
        break;
    }
    final bytes = Uint8List.fromList(img.encodePng(result));
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    setState(() {
      _previewImage = frame.image;
      _isLoading = false;
    });
    _editor.refresh();
  }
}
