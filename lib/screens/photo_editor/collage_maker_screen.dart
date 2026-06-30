import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;
import '../../services/image_editor_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/image_viewer.dart';

class CollageMakerScreen extends StatefulWidget {
  const CollageMakerScreen({super.key});

  @override
  State<CollageMakerScreen> createState() => _CollageMakerScreenState();
}

class _CollageMakerScreenState extends State<CollageMakerScreen> {
  final List<img.Image> _images = [];
  String _layout = '1';
  ui.Image? _resultImage;
  bool _isLoading = false;

  static const List<String> layouts = ['1', '2h', '2v', '3', '4'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Collage Maker')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _resultImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: RawImage(
                        image: _resultImage!,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    )
                  : _buildPickerArea(),
            ),
          ),
          if (_images.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Layout', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: layouts.map((l) {
                      final label = l == '1' ? '1' : l == '2h' ? '2H' : l == '2v' ? '2V' : l == '3' ? '3' : '4';
                      return ChoiceChip(
                        label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        selected: _layout == l,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.cardDark,
                        onSelected: (_) => setState(() => _layout = l),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (_images.length < 4)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _addImage,
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.cardDark),
                            child: const Text('+ Add Image'),
                          ),
                        ),
                      if (_images.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _images.length >= _neededImages ? _createCollage : null,
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                            child: const Text('Create'),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (_images.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _images.removeAt(i)),
                            child: Container(
                              width: 50,
                              decoration: BoxDecoration(
                                color: AppColors.cardDark,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.error, width: 1),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.close, color: AppColors.error, size: 18),
                                  Text('${i + 1}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  int get _neededImages {
    switch (_layout) {
      case '1': return 1;
      case '2h': case '2v': return 2;
      case '3': return 3;
      case '4': return 4;
      default: return 1;
    }
  }

  Widget _buildPickerArea() {
    return GestureDetector(
      onTap: _addImage,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            const Text('Add Photos', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text('${_images.length} of 4 selected', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Future<void> _addImage() async {
    final picker = ImageEditorService();
    final uiImage = await picker.pickAndLoadImage();
    if (uiImage != null) {
      final bytes = await uiImage.toByteData(format: ui.ImageByteFormat.png);
      if (bytes != null) {
        final decoded = img.decodeImage(bytes.buffer.asUint8List());
        if (decoded != null) {
          setState(() => _images.add(decoded));
        }
      }
    }
  }

  Future<void> _createCollage() async {
    if (_images.length < _neededImages) return;
    setState(() => _isLoading = true);
    final collage = _buildCollage();
    if (collage != null) {
      final bytes = Uint8List.fromList(img.encodePng(collage));
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      setState(() {
        _resultImage = frame.image;
        _isLoading = false;
      });
    }
  }

  img.Image? _buildCollage() {
    if (_images.isEmpty) return null;
    const int cw = 800;
    const int ch = 800;
    final canvas = img.Image(width: cw, height: ch);
    switch (_layout) {
      case '1':
        final resized = img.copyResize(_images[0], width: cw, height: ch);
        img.compositeImage(canvas, resized, dstX: 0, dstY: 0);
        break;
      case '2h':
        final half = img.copyResize(_images[0], width: cw ~/ 2, height: ch);
        img.compositeImage(canvas, half, dstX: 0, dstY: 0);
        if (_images.length > 1) {
          final half2 = img.copyResize(_images[1], width: cw ~/ 2, height: ch);
          img.compositeImage(canvas, half2, dstX: cw ~/ 2, dstY: 0);
        }
        break;
      case '2v':
        final half = img.copyResize(_images[0], width: cw, height: ch ~/ 2);
        img.compositeImage(canvas, half, dstX: 0, dstY: 0);
        if (_images.length > 1) {
          final half2 = img.copyResize(_images[1], width: cw, height: ch ~/ 2);
          img.compositeImage(canvas, half2, dstX: 0, dstY: ch ~/ 2);
        }
        break;
      case '3':
        final top = img.copyResize(_images[0], width: cw, height: ch ~/ 2);
        img.compositeImage(canvas, top, dstX: 0, dstY: 0);
        if (_images.length > 1) {
          final bl = img.copyResize(_images[1], width: cw ~/ 2, height: ch ~/ 2);
          img.compositeImage(canvas, bl, dstX: 0, dstY: ch ~/ 2);
        }
        if (_images.length > 2) {
          final br = img.copyResize(_images[2], width: cw ~/ 2, height: ch ~/ 2);
          img.compositeImage(canvas, br, dstX: cw ~/ 2, dstY: ch ~/ 2);
        }
        break;
      case '4':
        for (int i = 0; i < _images.length && i < 4; i++) {
          final cell = img.copyResize(_images[i], width: cw ~/ 2, height: ch ~/ 2);
          final dx = (i % 2) * (cw ~/ 2);
          final dy = (i ~/ 2) * (ch ~/ 2);
          img.compositeImage(canvas, cell, dstX: dx, dstY: dy);
        }
        break;
    }
    return canvas;
  }
}
