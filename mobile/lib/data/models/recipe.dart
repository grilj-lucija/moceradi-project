import 'package:equatable/equatable.dart';
import 'package:health_app/data/models/food.dart';
import 'package:health_app/data/models/nutrition_facts.dart';

class RecipeIngredient extends Equatable {
  const RecipeIngredient({
    required this.foodSnapshot,
    required this.grams,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) =>
      RecipeIngredient(
        foodSnapshot: Food.fromJson(
          json['food_snapshot'] as Map<String, dynamic>,
        ),
        grams: (json['grams'] as num).toDouble(),
      );

  final Food foodSnapshot;
  final double grams;

  String get foodId => foodSnapshot.id;

  NutritionTotals get totals => foodSnapshot.facts.forAmount(grams);

  Map<String, dynamic> toJson() => {
        'food_snapshot': foodSnapshot.toJson(),
        'grams': grams,
      };

  @override
  List<Object?> get props => [foodSnapshot, grams];
}

class Recipe extends Equatable {
  const Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: json['id'] as String,
        name: json['name'] as String,
        ingredients: (json['ingredients'] as List<dynamic>)
            .map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final String id;
  final String name;
  final List<RecipeIngredient> ingredients;

  double get totalGrams =>
      ingredients.fold(0, (sum, ing) => sum + ing.grams);

  NutritionTotals get totals => ingredients.fold(
        NutritionTotals.zero,
        (sum, ing) => sum + ing.totals,
      );

  NutritionFacts get aggregatedFacts {
    final total = totalGrams;
    if (total <= 0) return NutritionFacts.zero;
    final t = totals;
    final factor = 100 / total;
    return NutritionFacts(
      kcalPer100g: t.kcal * factor,
      proteinPer100g: t.proteinGrams * factor,
      carbsPer100g: t.carbsGrams * factor,
      fatPer100g: t.fatGrams * factor,
      sugarPer100g: t.sugarGrams * factor,
    );
  }

  Food toFood() => Food(
        id: id,
        name: name,
        source: FoodSourceKind.recipe,
        facts: aggregatedFacts,
        defaultServingGrams: totalGrams,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'ingredients': ingredients.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [id, name, ingredients];
}
