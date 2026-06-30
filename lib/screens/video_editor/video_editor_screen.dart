import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/feature_item.dart';
import '../../widgets/category_grid.dart';

class VideoEditorScreen extends StatelessWidget {
  const VideoEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Editor')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.videocam, color: AppColors.secondary, size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text('Tap to Import Video',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    const Text('MP4, MOV, AVI supported',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20, bottom: 8),
              child: Text('Video Tools',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const CategoryGrid(features: _tools),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  static const List<FeatureItem> _tools = [
    FeatureItem(title: 'Trim/Cut/Split', icon: Icons.content_cut, color: Colors.red, route: '/trim-cut-split'),
    FeatureItem(title: 'Speed Control', icon: Icons.speed, color: Colors.orange, route: '/speed-control'),
    FeatureItem(title: 'Reverse', icon: Icons.replay, color: Colors.amber, route: '/reverse-video'),
    FeatureItem(title: 'Stabilization', icon: Icons.video_stable, color: Colors.blue, route: '/stabilization', isPremium: true),
    FeatureItem(title: 'Color Grading', icon: Icons.color_lens, color: Colors.purple, route: '/color-grading', isPremium: true),
    FeatureItem(title: 'Transitions', icon: Icons.swap_horiz, color: Colors.teal, route: '/transitions'),
    FeatureItem(title: 'Green Screen', icon: Icons.layers, color: Colors.green, route: '/green-screen', isPremium: true),
    FeatureItem(title: 'PiP', icon: Icons.picture_in_picture, color: Colors.indigo, route: '/pip', isPremium: true),
    FeatureItem(title: 'Reel Maker', icon: Icons.video_library, color: Colors.pink, route: '/reel-maker'),
    FeatureItem(title: 'Export', icon: Icons.file_upload, color: Colors.cyan, route: '/export'),
  ];
}
