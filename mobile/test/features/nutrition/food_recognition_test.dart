import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:health_app/data/models/food.dart';
import 'package:health_app/data/repositories/food_recognition_repository_impl.dart';
import 'package:health_app/data/sources/food_recognition/mock_food_recognition_source.dart';

void main() {
  group('MockFoodRecognitionSource', () {
    test('returns a recognized food with a confidence score', () async {
      final source = MockFoodRecognitionSource();

      final recognition = await source.recognize(
        bytes: Uint8List(0),
        filename: 'meal.jpg',
      );

      expect(recognition.food.name, 'Grilled chicken bowl');
      expect(recognition.food.source, FoodSourceKind.custom);
      expect(recognition.confidence, greaterThan(0));
      expect(recognition.confidence, lessThanOrEqualTo(1));
    });
  });

  group('FoodRecognitionRepositoryImpl', () {
    test('wraps a successful recognition in Result.ok', () async {
      final repository = FoodRecognitionRepositoryImpl(
        MockFoodRecognitionSource(),
      );

      final result = await repository.recognize(
        bytes: Uint8List(0),
        filename: 'meal.jpg',
      );

      expect(result.isOk, isTrue);
      expect(result.valueOrNull?.food.name, 'Grilled chicken bowl');
    });
  });
}
