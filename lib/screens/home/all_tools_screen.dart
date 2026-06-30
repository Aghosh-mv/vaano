import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/feature_item.dart';
import '../../widgets/section_header.dart';
import '../../widgets/category_grid.dart';

class AllToolsScreen extends StatelessWidget {
  const AllToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tools'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Photo Editor'),
            CategoryGrid(features: _photoFeatures),
            const SectionHeader(title: 'Video Editor'),
            CategoryGrid(features: _videoFeatures),
            const SectionHeader(title: 'AI Studio'),
            CategoryGrid(features: _aiFeatures, crossAxisCount: 4),
            const SectionHeader(title: 'Audio Studio'),
            CategoryGrid(features: _audioFeatures, crossAxisCount: 4),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  static const List<FeatureItem> _photoFeatures = [
    FeatureItem(title: 'Crop, Rotate', icon: Icons.crop, color: Colors.green, route: '/crop-tool'),
    FeatureItem(title: 'Filters', icon: Icons.photo_filter, color: Colors.orange, route: '/filters'),
    FeatureItem(title: 'Bg Removal', icon: Icons.person_remove, color: Colors.purple, route: '/bg-removal', isPremium: true),
    FeatureItem(title: 'AI Object Removal', icon: Icons.auto_fix_high, color: Colors.teal, route: '/ai-object-removal', isPremium: true),
    FeatureItem(title: 'Beauty Retouch', icon: Icons.face_retouching_natural, color: Colors.pink, route: '/beauty-retouch', isPremium: true),
    FeatureItem(title: 'HDR Enhancement', icon: Icons.brightness_high, color: Colors.amber, route: '/hdr-enhancement'),
    FeatureItem(title: 'Collage Maker', icon: Icons.grid_view, color: Colors.indigo, route: '/collage-maker'),
    FeatureItem(title: 'Text & Stickers', icon: Icons.text_fields, color: Colors.cyan, route: '/text-stickers'),
    FeatureItem(title: 'Watermark', icon: Icons.copyright, color: Colors.red, route: '/watermark'),
  ];

  static const List<FeatureItem> _videoFeatures = [
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

  static const List<FeatureItem> _aiFeatures = [
    FeatureItem(title: 'AI Image Gen', icon: Icons.image, color: Colors.blue, route: '/ai-image-generator', isPremium: true),
    FeatureItem(title: 'AI Avatar', icon: Icons.face, color: Colors.purple, route: '/ai-avatar', isPremium: true),
    FeatureItem(title: 'AI Face Swap', icon: Icons.swap_horiz, color: Colors.orange, route: '/ai-face-swap', isPremium: true),
    FeatureItem(title: 'AI Bg Replace', icon: Icons.wallpaper, color: Colors.teal, route: '/ai-bg-replace', isPremium: true),
    FeatureItem(title: 'AI Video Gen', icon: Icons.video_call, color: Colors.red, route: '/ai-video-generator', isPremium: true),
    FeatureItem(title: 'AI Highlights', icon: Icons.auto_awesome, color: Colors.amber, route: '/ai-highlights', isPremium: true),
    FeatureItem(title: 'AI Captions', icon: Icons.closed_caption, color: Colors.indigo, route: '/ai-captions'),
    FeatureItem(title: 'AI Translate', icon: Icons.translate, color: Colors.cyan, route: '/ai-translate', isPremium: true),
    FeatureItem(title: 'AI Voice Clone', icon: Icons.record_voice_over, color: Colors.pink, route: '/ai-voice-clone', isPremium: true),
  ];

  static const List<FeatureItem> _audioFeatures = [
    FeatureItem(title: 'Music Library', icon: Icons.library_music, color: Colors.blue, route: '/music-library'),
    FeatureItem(title: 'Malayalam Songs', icon: Icons.language, color: Colors.deepOrange, route: '/malayalam-songs', isPremium: true),
    FeatureItem(title: 'Sound Effects', icon: Icons.music_note, color: Colors.amber, route: '/sound-effects'),
    FeatureItem(title: 'Voice Recording', icon: Icons.mic, color: Colors.red, route: '/voice-recording'),
    FeatureItem(title: 'Audio Extract', icon: Icons.audio_file, color: Colors.purple, route: '/audio-extract', isPremium: true),
    FeatureItem(title: 'Noise Reduction', icon: Icons.hearing, color: Colors.teal, route: '/noise-reduction', isPremium: true),
    FeatureItem(title: 'Voice Changer', icon: Icons.change_circle, color: Colors.orange, route: '/voice-changer', isPremium: true),
    FeatureItem(title: 'AI Voice Clone', icon: Icons.record_voice_over, color: Colors.pink, route: '/ai-voice-clone', isPremium: true),
  ];
}
