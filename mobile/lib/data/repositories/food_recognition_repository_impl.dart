import 'dart:typed_data';

import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/result/result.dart';
import 'package:health_app/data/models/food_recognition.dart';
import 'package:health_app/data/sources/food_recognition/food_recognition_source.dart';
import 'package:health_app/domain/repositories/food_recognition_repository.dart';

class FoodRecognitionRepositoryImpl implements FoodRecognitionRepository {
  FoodRecognitionRepositoryImpl(this._source);

  final FoodRecognitionSource _source;

  @override
  Future<Result<FoodRecognition>> recognize({
    required Uint8List bytes,
    required String filename,
  }) async {
    try {
      final recognition = await _source.recognize(
        bytes: bytes,
        filename: filename,
      );
      return Result.ok(recognition);
    } on Object catch (e) {
      return Result.err(NetworkFailure(e.toString(), e));
    }
  }
}
