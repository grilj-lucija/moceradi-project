import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  const Env._();

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get ocrBaseUrl => dotenv.env['OCR_BASE_URL'] ?? '';
  static String get foodAiBaseUrl => dotenv.env['FOODAI_BASE_URL'] ?? '';
  static String get mapboxPublicToken =>
      dotenv.env['MAPBOX_PUBLIC_TOKEN'] ?? '';

  static String get mqttHost => dotenv.env['MQTT_HOST'] ?? '';
  static int get mqttPort =>
      int.tryParse(dotenv.env['MQTT_PORT'] ?? '') ?? 1883;

  static bool get useMockData =>
      (dotenv.env['USE_MOCK_DATA'] ?? 'true').toLowerCase() == 'true';

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get isFoodAiConfigured => foodAiBaseUrl.isNotEmpty;

  static bool get isMqttConfigured => mqttHost.isNotEmpty;
}
