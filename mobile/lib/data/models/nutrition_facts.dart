import 'package:equatable/equatable.dart';

class NutritionFacts extends Equatable {
  const NutritionFacts({
    required this.kcalPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.sugarPer100g = 0,
  });

  factory NutritionFacts.fromJson(Map<String, dynamic> json) => NutritionFacts(
        kcalPer100g: (json['kcal_per_100g'] as num).toDouble(),
        proteinPer100g: (json['protein_per_100g'] as num).toDouble(),
        carbsPer100g: (json['carbs_per_100g'] as num).toDouble(),
        fatPer100g: (json['fat_per_100g'] as num).toDouble(),
        sugarPer100g: (json['sugar_per_100g'] as num?)?.toDouble() ?? 0,
      );

  static const NutritionFacts zero = NutritionFacts(
    kcalPer100g: 0,
    proteinPer100g: 0,
    carbsPer100g: 0,
    fatPer100g: 0,
    sugarPer100g: 0,
  );

  final double kcalPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double sugarPer100g;

  NutritionTotals forAmount(double grams) {
    final factor = grams / 100;
    return NutritionTotals(
      kcal: kcalPer100g * factor,
      proteinGrams: proteinPer100g * factor,
      carbsGrams: carbsPer100g * factor,
      fatGrams: fatPer100g * factor,
      sugarGrams: sugarPer100g * factor,
    );
  }

  Map<String, dynamic> toJson() => {
        'kcal_per_100g': kcalPer100g,
        'protein_per_100g': proteinPer100g,
        'carbs_per_100g': carbsPer100g,
        'fat_per_100g': fatPer100g,
        'sugar_per_100g': sugarPer100g,
      };

  @override
  List<Object?> get props => [
        kcalPer100g,
        proteinPer100g,
        carbsPer100g,
        fatPer100g,
        sugarPer100g,
      ];
}

class NutritionTotals extends Equatable {
  const NutritionTotals({
    required this.kcal,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    this.sugarGrams = 0,
  });

  static const NutritionTotals zero = NutritionTotals(
    kcal: 0,
    proteinGrams: 0,
    carbsGrams: 0,
    fatGrams: 0,
    sugarGrams: 0,
  );

  final double kcal;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double sugarGrams;

  NutritionTotals operator +(NutritionTotals other) => NutritionTotals(
        kcal: kcal + other.kcal,
        proteinGrams: proteinGrams + other.proteinGrams,
        carbsGrams: carbsGrams + other.carbsGrams,
        fatGrams: fatGrams + other.fatGrams,
        sugarGrams: sugarGrams + other.sugarGrams,
      );

  @override
  List<Object?> get props => [
        kcal,
        proteinGrams,
        carbsGrams,
        fatGrams,
        sugarGrams,
      ];
}
