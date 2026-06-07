import 'dart:convert';
import 'dart:typed_data';

import 'package:health_app/core/config/env.dart';
import 'package:health_app/data/models/food.dart';
import 'package:health_app/data/models/food_recognition.dart';
import 'package:health_app/data/models/nutrition_facts.dart';
import 'package:health_app/data/sources/food_recognition/food_recognition_source.dart';
import 'package:http/http.dart' as http;

class HttpFoodRecognitionSource implements FoodRecognitionSource {
  HttpFoodRecognitionSource({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? Env.foodAiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  @override
  Future<FoodRecognition> recognize({
    required Uint8List bytes,
    required String filename,
  }) async {
    final uri = Uri.parse('$_baseUrl/recognize');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: filename),
      );

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw Exception(
        'FoodAI request failed (${response.statusCode}): ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final label = json['label'] as String? ?? 'Unknown food';
    final confidence = (json['confidence'] as num?)?.toDouble() ?? 0;
    final kcalPer100g = (json['cal_100g'] as num?)?.toDouble() ?? 0;

    return FoodRecognition(
      food: Food(
        id: 'foodai:$label',
        name: label,
        source: FoodSourceKind.custom,
        defaultServingGrams: 100,
        facts: NutritionFacts(
          kcalPer100g: kcalPer100g,
          proteinPer100g: 0,
          carbsPer100g: 0,
          fatPer100g: 0,
        ),
      ),
      confidence: confidence,
    );
  }
}
