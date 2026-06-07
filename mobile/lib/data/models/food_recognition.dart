import 'package:equatable/equatable.dart';
import 'package:health_app/data/models/food.dart';

class FoodRecognition extends Equatable {
  const FoodRecognition({
    required this.food,
    required this.confidence,
  });

  final Food food;
  final double confidence;

  @override
  List<Object?> get props => [food, confidence];
}
