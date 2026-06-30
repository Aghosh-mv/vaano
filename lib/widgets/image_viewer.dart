import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ImageViewer extends StatelessWidget {
  final ui.Image? image;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final BoxFit fit;

  const ImageViewer({
    super.key,
    this.image,
    this.width,
    this.height,
    this.placeholder,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return placeholder ??
          Container(
            color: AppColors.cardDark,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('No Image Loaded', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
          );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: RawImage(
        image: image!,
        width: width,
        height: height,
        fit: fit,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
