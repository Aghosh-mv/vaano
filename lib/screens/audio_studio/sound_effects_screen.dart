import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SoundEffectsScreen extends StatefulWidget {
  const SoundEffectsScreen({super.key});

  @override
  State<SoundEffectsScreen> createState() => _SoundEffectsScreenState();
}

class _SoundEffectsScreenState extends State<SoundEffectsScreen> {
  String _search = '';
  int _playingIndex = -1;
  double _volume = 0.8;
  html.AudioElement? _audio;

  final List<Map<String, dynamic>> _effects = [
    {'name': 'Applause', 'icon': Icons.handshake, 'song': 1},
    {'name': 'Laughter', 'icon': Icons.emoji_emotions, 'song': 2},
    {'name': 'Explosion', 'icon': Icons.whatshot, 'song': 3},
    {'name': 'Gunshot', 'icon': Icons.gps_fixed, 'song': 4},
    {'name': 'Doorbell', 'icon': Icons.doorbell, 'song': 5},
    {'name': 'Phone Ring', 'icon': Icons.phone, 'song': 6},
    {'name': 'Bird', 'icon': Icons.pets, 'song': 7},
    {'name': 'Thunder', 'icon': Icons.thunderstorm, 'song': 8},
    {'name': 'Rain', 'icon': Icons.water_drop, 'song': 9},
    {'name': 'Ocean', 'icon': Icons.waves, 'song': 10},
    {'name': 'Wind', 'icon': Icons.air, 'song': 11},
    {'name': 'Siren', 'icon': Icons.warning, 'song': 12},
  ];

  List<Map<String, dynamic>> get _filtered => _effects
      .where((e) => (e['name'] as String).toLowerCase().contains(_search.toLowerCase()))
      .toList();

  void _play(int index) {
    final song = _effects[index]['song'] as int;
    _audio?.pause();
    _audio = html.AudioElement('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-$song.mp3');
    _audio!.volume = _volume;
    _audio!.play();
    setState(() => _playingIndex = index);
    _audio!.onEnded.listen((_) {
      if (mounted) setState(() => _playingIndex = -1);
    });
  }

  void _stop() {
    _audio?.pause();
    if (_playingIndex >= 0) {
      setState(() => _playingIndex = -1);
    }
  }

  @override
  void dispose() {
    _audio?.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sound Effects'),
        actions: [
          if (_playingIndex >= 0)
            IconButton(
              icon: const Icon(Icons.stop, color: AppColors.error),
              onPressed: _stop,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search sound effects...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                        onPressed: () => setState(() => _search = ''),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.cardDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.volume_up, color: AppColors.textSecondary, size: 18),
                Expanded(
                  child: Slider(
                    value: _volume, min: 0, max: 1,
                    onChanged: (v) {
                      setState(() => _volume = v);
                      if (_audio != null) _audio!.volume = v;
                    },
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.cardDark,
                  ),
                ),
                Text('${(_volume * 100).round()}%',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.9,
              ),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final origIndex = _effects.indexOf(_filtered[i]);
                final isPlaying = _playingIndex == origIndex;
                return GestureDetector(
                  onTap: () => isPlaying ? _stop() : _play(origIndex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: isPlaying ? AppColors.primary.withOpacity(0.3) : AppColors.cardDark,
                      borderRadius: BorderRadius.circular(12),
                      border: isPlaying ? Border.all(color: AppColors.primary, width: 2) : null,
                      boxShadow: isPlaying
                          ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, spreadRadius: 1)]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(_filtered[i]['icon'] as IconData,
                              color: isPlaying ? AppColors.primary : AppColors.accent, size: 32),
                            if (isPlaying)
                              const Icon(Icons.play_circle, color: AppColors.primary, size: 14),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(_filtered[i]['name'] as String,
                          style: TextStyle(
                            color: isPlaying ? AppColors.primary : AppColors.textPrimary,
                            fontSize: 11, fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
