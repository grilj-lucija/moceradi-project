import 'dart:typed_data';

import 'package:health_app/data/models/food_recognition.dart';

abstract interface class FoodRecognitionSource {
  Future<FoodRecognition> recognize({
    required Uint8List bytes,
    required String filename,
  });
}
