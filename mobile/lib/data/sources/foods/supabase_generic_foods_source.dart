import 'package:health_app/data/models/food.dart';
import 'package:health_app/data/models/nutrition_facts.dart';
import 'package:health_app/data/models/recipe.dart';
import 'package:health_app/data/sources/foods/foods_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseGenericFoodsSource implements FoodsSource {
  SupabaseGenericFoodsSource(this._client);

  final SupabaseClient _client;

  static const _table = 'generic_foods';

  @override
  Future<List<Food>> searchByText(
    String query, {
    int limit = 30,
    FoodSearchScope scope = FoodSearchScope.all,
  }) async {
    if (scope != FoodSearchScope.all && scope != FoodSearchScope.generic) {
      return const [];
    }

    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      if (scope != FoodSearchScope.generic) return const [];
      final rows = await _client
          .from(_table)
          .select()
          .order('priority', ascending: false)
          .order('name', ascending: true)
          .limit(limit);
      return [
        for (final row in rows as List<dynamic>)
          _fromRow(row as Map<String, dynamic>),
      ];
    }

    if (trimmed.length < 2) return const [];

    final pattern = '%${_escapeForLike(trimmed)}%';
    final rows = await _client
        .from(_table)
        .select()
        .ilike('name', pattern)
        .order('priority', ascending: false)
        .order('name', ascending: true)
        .limit(limit);
    return [
      for (final row in rows as List<dynamic>)
        _fromRow(row as Map<String, dynamic>),
    ];
  }

  @override
  Future<Food?> getByBarcode(String barcode) async => null;

  @override
  Future<List<Food>> listCustomFoods() async => const [];

  @override
  Future<Food> saveCustomFood(Food food) =>
      throw UnsupportedError('Generic foods catalog is read-only');

  @override
  Future<void> deleteCustomFood(String id) =>
      throw UnsupportedError('Generic foods catalog is read-only');

  @override
  Future<List<Recipe>> listRecipes() async => const [];

  @override
  Future<Recipe> saveRecipe(Recipe recipe) =>
      throw UnsupportedError('Generic foods catalog is read-only');

  @override
  Future<void> deleteRecipe(String id) =>
      throw UnsupportedError('Generic foods catalog is read-only');

  Food _fromRow(Map<String, dynamic> row) {
    final slug = row['slug'] as String?;
    final fdcId = row['fdc_id'];
    final id = slug != null && slug.isNotEmpty
        ? 'generic:$slug'
        : (fdcId != null ? 'usda:$fdcId' : 'generic:${row['id']}');
    return Food(
      id: id,
      name: row['name'] as String,
      isBeverage: (row['is_beverage'] as bool?) ?? false,
      defaultServingGrams: _toDouble(row['default_serving_grams']),
      source: FoodSourceKind.generic,
      facts: NutritionFacts(
        kcalPer100g: _toDouble(row['kcal_per_100g']) ?? 0,
        proteinPer100g: _toDouble(row['protein_per_100g']) ?? 0,
        carbsPer100g: _toDouble(row['carbs_per_100g']) ?? 0,
        fatPer100g: _toDouble(row['fat_per_100g']) ?? 0,
        sugarPer100g: _toDouble(row['sugar_per_100g']) ?? 0,
      ),
    );
  }

  static String _escapeForLike(String input) {
    return input
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_')
        .replaceAll(',', ' ');
  }

  static double? _toDouble(Object? raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString());
  }
}
