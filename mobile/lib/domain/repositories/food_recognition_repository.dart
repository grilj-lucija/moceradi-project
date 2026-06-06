import 'dart:typed_data';

import 'package:health_app/core/result/result.dart';
import 'package:health_app/data/models/food_recognition.dart';

abstract interface class FoodRecognitionRepository {
  Future<Result<FoodRecognition>> recognize({
    required Uint8List bytes,
    required String filename,
  });
}
