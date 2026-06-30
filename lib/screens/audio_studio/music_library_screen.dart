import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class MusicLibraryScreen extends StatefulWidget {
  const MusicLibraryScreen({super.key});

  @override
  State<MusicLibraryScreen> createState() => _MusicLibraryScreenState();
}

class _MusicLibraryScreenState extends State<MusicLibraryScreen> {
  int _currentPlaying = -1;
  html.AudioElement? _audioElement;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _audioElement?.pause();
    _searchController.dispose();
    super.dispose();
  }

  void _playPause(int index) {
    if (_currentPlaying == index) {
      _audioElement?.pause();
      setState(() => _currentPlaying = -1);
      return;
    }
    // Play directly from URLs (free music sources)
    _audioElement?.pause();
    final url = _songs[index]['url'] as String;
    _audioElement = html.AudioElement(url)
      ..autoplay = true
      ..onEnded.listen((_) => setState(() => _currentPlaying = -1));
    setState(() => _currentPlaying = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Music Library')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search music...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _songs.length,
              itemBuilder: (_, i) {
                final song = _songs[i];
                final isPlaying = _currentPlaying == i;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPlaying ? AppColors.primary.withOpacity(0.15) : AppColors.cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: isPlaying ? Border.all(color: AppColors.primary.withOpacity(0.5)) : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.cardLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.music_note, color: isPlaying ? AppColors.primary : AppColors.textSecondary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(song['title'] as String,
                              style: TextStyle(color: isPlaying ? AppColors.primary : AppColors.textPrimary, fontWeight: FontWeight.w600)),
                            Text(song['artist'] as String,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text(song['duration'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle,
                          color: isPlaying ? AppColors.primary : AppColors.textSecondary),
                        onPressed: () => _playPause(i),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Free music from publicly available sources
  static const List<Map<String, String>> _songs = [
    {'title': 'Summer Vibes', 'artist': 'FMA', 'duration': '3:24', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'},
    {'title': 'Electronic Dreams', 'artist': 'Synthwave', 'duration': '4:12', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'},
    {'title': 'Acoustic Sunset', 'artist': 'Folk Band', 'duration': '2:58', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3'},
    {'title': 'Upbeat Morning', 'artist': 'Happy Tunes', 'duration': '3:45', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3'},
    {'title': 'Cinematic Epic', 'artist': 'Orchestra', 'duration': '5:30', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3'},
    {'title': 'Lo-fi Beats', 'artist': 'Chill Vibes', 'duration': '3:15', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3'},
    {'title': 'Pop Hit', 'artist': 'Top Artist', 'duration': '3:00', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3'},
    {'title': 'Jazz Night', 'artist': 'Smooth Jazz', 'duration': '4:45', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3'},
  ];
}
