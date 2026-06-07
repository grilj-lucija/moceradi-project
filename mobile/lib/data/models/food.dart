import 'package:equatable/equatable.dart';
import 'package:health_app/data/models/nutrition_facts.dart';

enum FoodSourceKind { openFoodFacts, generic, custom, recipe }

extension FoodSourceKindX on FoodSourceKind {
  String get wireValue => name;

  static FoodSourceKind fromWire(String? value) {
    for (final v in FoodSourceKind.values) {
      if (v.name == value) return v;
    }
    return FoodSourceKind.custom;
  }
}

class Food extends Equatable {
  const Food({
    required this.id,
    required this.name,
    required this.source,
    required this.facts,
    this.brand,
    this.barcode,
    this.defaultServingGrams,
    this.isBeverage = false,
  });

  factory Food.fromJson(Map<String, dynamic> json) => Food(
        id: json['id'] as String,
        name: json['name'] as String,
        source: FoodSourceKindX.fromWire(json['source'] as String?),
        facts: NutritionFacts.fromJson(
          json['facts'] as Map<String, dynamic>,
        ),
        brand: json['brand'] as String?,
        barcode: json['barcode'] as String?,
        defaultServingGrams: (json['default_serving_grams'] as num?)?.toDouble(),
        isBeverage: json['is_beverage'] as bool? ?? false,
      );

  final String id;
  final String name;
  final FoodSourceKind source;
  final NutritionFacts facts;
  final String? brand;
  final String? barcode;
  final double? defaultServingGrams;
  final bool isBeverage;

  String get amountUnit => isBeverage ? 'ml' : 'g';
  String get per100Suffix => isBeverage ? '/100ml' : '/100g';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'source': source.wireValue,
        'facts': facts.toJson(),
        'brand': brand,
        'barcode': barcode,
        'default_serving_grams': defaultServingGrams,
        'is_beverage': isBeverage,
      };

  Food copyWith({
    String? name,
    NutritionFacts? facts,
    String? brand,
    String? barcode,
    double? defaultServingGrams,
    bool? isBeverage,
  }) =>
      Food(
        id: id,
        source: source,
        name: name ?? this.name,
        facts: facts ?? this.facts,
        brand: brand ?? this.brand,
        barcode: barcode ?? this.barcode,
        defaultServingGrams: defaultServingGrams ?? this.defaultServingGrams,
        isBeverage: isBeverage ?? this.isBeverage,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        source,
        facts,
        brand,
        barcode,
        defaultServingGrams,
        isBeverage,
      ];
}
