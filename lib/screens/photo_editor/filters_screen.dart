import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/image_editor_service.dart';
import '../../widgets/image_viewer.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  final ImageEditorService _editor = ImageEditorService();
  String _selectedFilter = 'Original';
  double _brightness = 0, _contrast = 0, _saturation = 0;
  bool _isLoading = false;

  static const List<String> filterNames = [
    'Original', 'Grayscale', 'Sepia', 'Invert', 'Vivid', 'Noir',
    'Vintage', 'Cool', 'Warm', 'Fade', 'Pastel',
  ];

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
      appBar: AppBar(
        title: const Text('Filters & Adjust'),
        actions: [
          if (_editor.currentImage != null)
            IconButton(
              icon: const Icon(Icons.restart_alt),
              onPressed: _reset,
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
                            Icon(Icons.add_photo_alternate, size: 48, color: AppColors.textSecondary),
                            SizedBox(height: 12),
                            Text('Tap to Import Photo', style: TextStyle(color: AppColors.textSecondary)),
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filterNames.length,
                      itemBuilder: (_, i) {
                        final name = filterNames[i];
                        final isSelected = _selectedFilter == name;
                        return GestureDetector(
                          onTap: () => _applyFilter(name),
                          child: Container(
                            width: 70,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withOpacity(0.3) : AppColors.cardDark,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected ? Border.all(color: AppColors.primary) : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isSelected ? Icons.check_circle : Icons.photo_filter,
                                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                  size: 20,
                                ),
                                const SizedBox(height: 4),
                                Text(name, style: TextStyle(
                                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ), textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _slider('Brightness', _brightness, (v) {
                    setState(() => _brightness = v);
                    _editor.adjustBrightness(v);
                  }),
                  _slider('Contrast', _contrast, (v) {
                    setState(() => _contrast = v);
                    _editor.adjustContrast(v);
                  }),
                  _slider('Saturation', _saturation, (v) {
                    setState(() => _saturation = v);
                    _editor.adjustSaturation(v);
                  }),
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
      }
    }
  }

  Future<void> _applyFilter(String name) async {
    setState(() => _isLoading = true);
    _selectedFilter = name;
    await _editor.applyFilter(name);
    setState(() => _isLoading = false);
  }

  Future<void> _reset() async {
    await _editor.resetImage();
    setState(() {
      _selectedFilter = 'Original';
      _brightness = 0;
      _contrast = 0;
      _saturation = 0;
    });
  }

  Widget _slider(String label, double val, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
        Expanded(child: Slider(value: val, min: -1, max: 1, activeColor: AppColors.primary, onChanged: onChanged)),
      ],
    );
  }
}
