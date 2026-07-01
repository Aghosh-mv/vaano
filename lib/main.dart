import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/supabase_service.dart';
import 'services/subscription_service.dart';
import 'services/api_ai_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FATAL: ${details.exception}');
  };

  ui.PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('PLATFORM ERROR: $error');
    return true;
  };

  final geminiKey = const String.fromEnvironment('GEMINI_API_KEY',
      defaultValue: '');
  if (geminiKey.isNotEmpty) {
    ApiAiService.setGeminiKey(geminiKey);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SubscriptionService()),
        Provider.value(value: SupabaseService()),
      ],
      child: const VaanoApp(),
    ),
  );

  // Initialize Supabase asynchronously after app renders (prevents white screen)
  // Add timeout to prevent hanging on web (known supabase_flutter + Hive issue)
  try {
    final supabase = SupabaseService();
    await supabase.initialize().timeout(const Duration(seconds: 5));
  } on TimeoutException {
    debugPrint('Supabase init timed out (continuing without auth)');
  } catch (e) {
    debugPrint('Supabase init error (non-fatal): $e');
  }
}
