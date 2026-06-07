import 'dart:typed_data';

import 'package:health_app/data/models/food.dart';
import 'package:health_app/data/models/food_recognition.dart';
import 'package:health_app/data/models/nutrition_facts.dart';
import 'package:health_app/data/sources/food_recognition/food_recognition_source.dart';

class MockFoodRecognitionSource implements FoodRecognitionSource {
  @override
  Future<FoodRecognition> recognize({
    required Uint8List bytes,
    required String filename,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    return const FoodRecognition(
      food: Food(
        id: 'foodai:grilled-chicken-bowl',
        name: 'Grilled chicken bowl',
        source: FoodSourceKind.custom,
        defaultServingGrams: 350,
        facts: NutritionFacts(
          kcalPer100g: 154,
          proteinPer100g: 11,
          carbsPer100g: 13,
          fatPer100g: 5,
        ),
      ),
      confidence: 0.92,
    );
  }
}
