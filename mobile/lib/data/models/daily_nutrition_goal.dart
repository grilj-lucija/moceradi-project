import 'package:equatable/equatable.dart';

class DailyNutritionGoal extends Equatable {
  const DailyNutritionGoal({
    required this.kcal,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.sugarGrams,
    required this.liquidsMl,
  });

  factory DailyNutritionGoal.fromJson(Map<String, dynamic> json) =>
      DailyNutritionGoal(
        kcal: (json['kcal'] as num).toDouble(),
        proteinGrams: (json['protein_grams'] as num).toDouble(),
        carbsGrams: (json['carbs_grams'] as num).toDouble(),
        fatGrams: (json['fat_grams'] as num).toDouble(),
        sugarGrams: (json['sugar_grams'] as num?)?.toDouble() ?? 50,
        liquidsMl: (json['liquids_ml'] as num?)?.toDouble() ?? 2500,
      );

  final double kcal;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double sugarGrams;
  final double liquidsMl;

  Map<String, dynamic> toJson() => {
        'kcal': kcal,
        'protein_grams': proteinGrams,
        'carbs_grams': carbsGrams,
        'fat_grams': fatGrams,
        'sugar_grams': sugarGrams,
        'liquids_ml': liquidsMl,
      };

  @override
  List<Object?> get props => [
        kcal,
        proteinGrams,
        carbsGrams,
        fatGrams,
        sugarGrams,
        liquidsMl,
      ];
}

const DailyNutritionGoal kDefaultDailyGoal = DailyNutritionGoal(
  kcal: 2400,
  proteinGrams: 150,
  carbsGrams: 280,
  fatGrams: 75,
  sugarGrams: 50,
  liquidsMl: 2500,
);
