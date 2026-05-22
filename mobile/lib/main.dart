import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/app/app.dart';
import 'package:health_app/core/config/env.dart';
import 'package:openfoodfacts/openfoodfacts.dart' as off;
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await dotenv.load();
  } on Object catch (_) {}

  off.OpenFoodAPIConfiguration.userAgent = off.UserAgent(
    name: 'HealthApp',
    version: '1.0.0',
  );
  off.OpenFoodAPIConfiguration.globalLanguages = <off.OpenFoodFactsLanguage>[
    off.OpenFoodFactsLanguage.ENGLISH,
  ];

  if (!Env.useMockData && Env.isSupabaseConfigured) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
  }

  runApp(const ProviderScope(child: HealthApp()));
}
