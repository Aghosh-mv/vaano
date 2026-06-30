import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'services/supabase_service.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/all_tools_screen.dart';
import 'screens/photo_editor/photo_editor_screen.dart';
import 'screens/photo_editor/crop_tool_screen.dart';
import 'screens/photo_editor/filters_screen.dart';
import 'screens/photo_editor/background_removal_screen.dart';
import 'screens/photo_editor/ai_object_removal_screen.dart';
import 'screens/photo_editor/beauty_retouch_screen.dart';
import 'screens/photo_editor/hdr_enhancement_screen.dart';
import 'screens/photo_editor/collage_maker_screen.dart';
import 'screens/photo_editor/text_stickers_screen.dart';
import 'screens/photo_editor/watermark_tool_screen.dart';
import 'screens/video_editor/video_editor_screen.dart';
import 'screens/video_editor/trim_cut_split_screen.dart';
import 'screens/video_editor/speed_control_screen.dart';
import 'screens/video_editor/reverse_video_screen.dart';
import 'screens/video_editor/video_stabilization_screen.dart';
import 'screens/video_editor/color_grading_screen.dart';
import 'screens/video_editor/transitions_screen.dart';
import 'screens/video_editor/green_screen_screen.dart';
import 'screens/video_editor/picture_in_picture_screen.dart';
import 'screens/video_editor/reel_maker_screen.dart';
import 'screens/video_editor/export_screen.dart';
import 'screens/ai_studio/ai_studio_screen.dart';
import 'screens/ai_studio/ai_image_generator_screen.dart';
import 'screens/ai_studio/ai_avatar_creator_screen.dart';
import 'screens/ai_studio/ai_face_swap_screen.dart';
import 'screens/ai_studio/ai_background_replacement_screen.dart';
import 'screens/ai_studio/ai_video_generator_screen.dart';
import 'screens/ai_studio/ai_highlight_detection_screen.dart';
import 'screens/ai_studio/ai_auto_captions_screen.dart';
import 'screens/ai_studio/ai_subtitle_translation_screen.dart';
import 'screens/ai_studio/ai_voice_cloning_screen.dart';
import 'screens/audio_studio/audio_studio_screen.dart';
import 'screens/audio_studio/music_library_screen.dart';
import 'screens/audio_studio/malayalam_songs_screen.dart';
import 'screens/audio_studio/sound_effects_screen.dart';
import 'screens/audio_studio/voice_recording_screen.dart';
import 'screens/audio_studio/audio_extraction_screen.dart';
import 'screens/audio_studio/noise_reduction_screen.dart';
import 'screens/audio_studio/voice_changer_screen.dart';
import 'screens/templates/templates_screen.dart';
import 'screens/export_share/export_share_screen.dart';
import 'screens/subscription/subscription_screen.dart';

class VaanoApp extends StatelessWidget {
  const VaanoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VAÀNO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthGate(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/home': (_) => const MainShell(),
        '/all-tools': (_) => const AllToolsScreen(),
        '/photo-editor': (_) => const PhotoEditorScreen(),
        '/crop-tool': (_) => const CropToolScreen(),
        '/filters': (_) => const FiltersScreen(),
        '/bg-removal': (_) => const BackgroundRemovalScreen(),
        '/ai-object-removal': (_) => const AiObjectRemovalScreen(),
        '/beauty-retouch': (_) => const BeautyRetouchScreen(),
        '/hdr-enhancement': (_) => const HdrEnhancementScreen(),
        '/collage-maker': (_) => const CollageMakerScreen(),
        '/text-stickers': (_) => const TextStickersScreen(),
        '/watermark': (_) => const WatermarkToolScreen(),
        '/video-editor': (_) => const VideoEditorScreen(),
        '/trim-cut-split': (_) => const TrimCutSplitScreen(),
        '/speed-control': (_) => const SpeedControlScreen(),
        '/reverse-video': (_) => const ReverseVideoScreen(),
        '/stabilization': (_) => const VideoStabilizationScreen(),
        '/color-grading': (_) => const ColorGradingScreen(),
        '/transitions': (_) => const TransitionsScreen(),
        '/green-screen': (_) => const GreenScreenScreen(),
        '/pip': (_) => const PictureInPictureScreen(),
        '/reel-maker': (_) => const ReelMakerScreen(),
        '/export': (_) => const ExportScreen(),
        '/ai-studio': (_) => const AiStudioScreen(),
        '/ai-image-generator': (_) => const AiImageGeneratorScreen(),
        '/ai-avatar': (_) => const AiAvatarCreatorScreen(),
        '/ai-face-swap': (_) => const AiFaceSwapScreen(),
        '/ai-bg-replace': (_) => const AiBackgroundReplacementScreen(),
        '/ai-video-generator': (_) => const AiVideoGeneratorScreen(),
        '/ai-highlights': (_) => const AiHighlightDetectionScreen(),
        '/ai-captions': (_) => const AiAutoCaptionsScreen(),
        '/ai-translate': (_) => const AiSubtitleTranslationScreen(),
        '/ai-voice-clone': (_) => const AiVoiceCloningScreen(),
        '/audio-studio': (_) => const AudioStudioScreen(),
        '/music-library': (_) => const MusicLibraryScreen(),
        '/malayalam-songs': (_) => const MalayalamSongsScreen(),
        '/sound-effects': (_) => const SoundEffectsScreen(),
        '/voice-recording': (_) => const VoiceRecordingScreen(),
        '/audio-extract': (_) => const AudioExtractionScreen(),
        '/noise-reduction': (_) => const NoiseReductionScreen(),
        '/voice-changer': (_) => const VoiceChangerScreen(),
        '/templates': (_) => const TemplatesScreen(),
        '/export-share': (_) => const ExportShareScreen(),
        '/subscription': (_) => const SubscriptionScreen(),
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthService _authService;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _authService.authState.listen((_) {
      if (mounted) setState(() => _checking = false);
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _checking) setState(() => _checking = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    if (_authService.isLoggedIn) {
      return const MainShell();
    }
    return const LoginScreen();
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TemplatesScreen(),
    AiStudioScreen(),
    AudioStudioScreen(),
    ExportShareScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 8),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.cardLight, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view), label: 'Templates'),
            BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_outlined), activeIcon: Icon(Icons.auto_awesome), label: 'AI Studio'),
            BottomNavigationBarItem(icon: Icon(Icons.music_note_outlined), activeIcon: Icon(Icons.music_note), label: 'Audio'),
            BottomNavigationBarItem(icon: Icon(Icons.ios_share_outlined), activeIcon: Icon(Icons.ios_share), label: 'Export'),
          ],
        ),
      ),
    );
  }
}
