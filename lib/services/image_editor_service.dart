import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';

class ImageEditorService extends ChangeNotifier {
  ui.Image? _originalImage;
  ui.Image? _editedImage;
  img.Image? _workingImage;

  ui.Image? get currentImage => _editedImage ?? _originalImage;
  img.Image? get workingImage => _workingImage;
  String? fileName;

  Future<ui.Image?> pickAndLoadImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    fileName = file.name;
    return loadBytes(file.bytes!, file.name);
  }

  Future<ui.Image> loadBytes(Uint8List bytes, [String? name]) async {
    fileName = name;
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    _originalImage = frame.image;
    _workingImage = img.decodeImage(bytes);
    _editedImage = null;
    notifyListeners();
    return _originalImage!;
  }

  Future<ui.Image> applyFilter(String filterName) async {
    if (_workingImage == null) return _originalImage!;
    img.Image result;
    switch (filterName) {
      case 'Original':
        return resetImage();
      case 'Grayscale':
        result = img.grayscale(_workingImage!);
        break;
      case 'Sepia':
        result = img.sepia(_workingImage!);
        break;
      case 'Invert':
        result = img.invert(_workingImage!);
        break;
      case 'Vivid':
        result = img.adjustColor(_workingImage!, saturation: 1.8, contrast: 1.3);
        break;
      case 'Noir':
        result = img.grayscale(_workingImage!);
        result = img.adjustColor(result, contrast: 1.4);
        break;
      case 'Vintage':
        result = img.adjustColor(_workingImage!, saturation: 0.4);
        result = img.colorOffset(result, red: 20, green: 10, blue: 0);
        break;
      case 'Cool':
        result = img.adjustColor(_workingImage!, saturation: 0.6);
        result = img.colorOffset(result, red: -10, green: 0, blue: 20);
        break;
      case 'Warm':
        result = img.adjustColor(_workingImage!, saturation: 1.2);
        result = img.colorOffset(result, red: 20, green: 10, blue: -10);
        break;
      case 'Drama':
        result = img.grayscale(_workingImage!);
        result = img.adjustColor(result, contrast: 1.8);
        break;
      case 'Fade':
        result = img.adjustColor(_workingImage!, saturation: 0.2, contrast: 0.8);
        break;
      case 'Chrome':
        result = img.adjustColor(_workingImage!, saturation: 1.5, contrast: 1.2);
        break;
      case 'Pastel':
        result = img.adjustColor(_workingImage!, saturation: 0.5, contrast: 0.9);
        result = img.colorOffset(result, red: 30, green: 30, blue: 30);
        break;
      default:
        return _originalImage!;
    }
    _workingImage = result;
    return _toUiImage(result);
  }

  Future<ui.Image> cropImage(int x, int y, int w, int h) async {
    if (_workingImage == null) return _originalImage!;
    final result = img.copyCrop(_workingImage!, x: x, y: y, width: w, height: h);
    _workingImage = result;
    return _toUiImage(result);
  }

  Future<ui.Image> rotateImage(double angleDeg) async {
    if (_workingImage == null) return _originalImage!;
    final result = img.copyRotate(_workingImage!, angle: angleDeg);
    _workingImage = result;
    return _toUiImage(result);
  }

  Future<ui.Image> flipHorizontal() async {
    if (_workingImage == null) return _originalImage!;
    final result = img.copyFlip(_workingImage!, direction: img.FlipDirection.horizontal);
    _workingImage = result;
    return _toUiImage(result);
  }

  Future<ui.Image> flipVertical() async {
    if (_workingImage == null) return _originalImage!;
    final result = img.copyFlip(_workingImage!, direction: img.FlipDirection.vertical);
    _workingImage = result;
    return _toUiImage(result);
  }

  Future<ui.Image> adjustBrightness(double value) async {
    if (_workingImage == null) return _originalImage!;
    final offset = (value * 50).round();
    _workingImage = img.colorOffset(_workingImage!, red: offset, green: offset, blue: offset);
    return _toUiImage(_workingImage!);
  }

  Future<ui.Image> adjustContrast(double value) async {
    if (_workingImage == null) return _originalImage!;
    _workingImage = img.contrast(_workingImage!, contrast: value.clamp(0.0, 3.0));
    return _toUiImage(_workingImage!);
  }

  Future<ui.Image> adjustSaturation(double value) async {
    if (_workingImage == null) return _originalImage!;
    _workingImage = img.adjustColor(_workingImage!, saturation: (1.0 + value).clamp(0.0, 3.0));
    return _toUiImage(_workingImage!);
  }

  Future<ui.Image> resetImage() async {
    if (_originalImage == null) return _originalImage!;
    final bytes = await _imageToBytes(_originalImage!);
    _workingImage = img.decodeImage(bytes);
    _editedImage = null;
    notifyListeners();
    return _originalImage!;
  }

  Future<Uint8List> exportPng() async {
    if (_workingImage == null) return Uint8List(0);
    return Uint8List.fromList(img.encodePng(_workingImage!));
  }

  Future<Uint8List> exportJpg({int quality = 95}) async {
    if (_workingImage == null) return Uint8List(0);
    return Uint8List.fromList(img.encodeJpg(_workingImage!, quality: quality));
  }

  Future<ui.Image> _toUiImage(img.Image image) async {
    final bytes = Uint8List.fromList(img.encodePng(image));
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    _editedImage = frame.image;
    notifyListeners();
    return _editedImage!;
  }

  Future<Uint8List> _imageToBytes(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void refresh() => notifyListeners();

  void dispose() {
    _originalImage = null;
    _editedImage = null;
    _workingImage = null;
  }
}
