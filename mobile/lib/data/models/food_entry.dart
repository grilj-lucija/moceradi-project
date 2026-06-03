import 'package:equatable/equatable.dart';
import 'package:health_app/data/models/food.dart';
import 'package:health_app/data/models/meal_slot.dart';
import 'package:health_app/data/models/nutrition_facts.dart';

class FoodEntry extends Equatable {
  const FoodEntry({
    required this.id,
    required this.foodSnapshot,
    required this.grams,
    required this.loggedAt,
    required this.mealSlot,
  });

  factory FoodEntry.fromJson(Map<String, dynamic> json) => FoodEntry(
        id: json['id'] as String,
        foodSnapshot: Food.fromJson(
          json['food_snapshot'] as Map<String, dynamic>,
        ),
        grams: (json['grams'] as num).toDouble(),
        loggedAt: DateTime.parse(json['logged_at'] as String),
        mealSlot: MealSlotX.fromWire(json['meal_slot'] as String?),
      );

  final String id;
  final Food foodSnapshot;
  final double grams;
  final DateTime loggedAt;
  final MealSlot mealSlot;

  String get foodId => foodSnapshot.id;

  NutritionTotals get totals => foodSnapshot.facts.forAmount(grams);

  Map<String, dynamic> toJson() => {
        'id': id,
        'food_snapshot': foodSnapshot.toJson(),
        'grams': grams,
        'logged_at': loggedAt.toIso8601String(),
        'meal_slot': mealSlot.wireValue,
      };

  @override
  List<Object?> get props => [id, foodSnapshot, grams, loggedAt, mealSlot];
}
