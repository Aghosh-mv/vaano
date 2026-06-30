import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/feature_item.dart';
import '../../widgets/section_header.dart';
import '../../widgets/category_grid.dart';

class AudioStudioScreen extends StatelessWidget {
  const AudioStudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Studio')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.withOpacity(0.6), AppColors.surface],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Audio Studio',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Music, effects & voice tools',
                          style: TextStyle(color: Colors.white.withOpacity(0.8))),
                      ],
                    ),
                  ),
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.music_note, color: Colors.white, size: 32),
                  ),
                ],
              ),
            ),
            const SectionHeader(title: 'Audio Tools'),
            const CategoryGrid(features: _tools),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  static const List<FeatureItem> _tools = [
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
