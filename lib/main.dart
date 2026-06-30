import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/supabase_service.dart';
import 'services/subscription_service.dart';
import 'services/api_ai_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  final supabase = SupabaseService();
  await supabase.initialize();

  // Set Gemini API key from environment (set on Vercel as GEMINI_API_KEY)
  final geminiKey = const String.fromEnvironment('GEMINI_API_KEY',
      defaultValue: '');
  if (geminiKey.isNotEmpty) {
    ApiAiService.setGeminiKey(geminiKey);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SubscriptionService()),
        Provider.value(value: supabase),
      ],
      child: const VaanoApp(),
    ),
  );
}
