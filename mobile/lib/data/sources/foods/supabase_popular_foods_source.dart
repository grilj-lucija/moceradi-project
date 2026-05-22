import 'package:health_app/data/models/food.dart';
import 'package:health_app/data/models/nutrition_facts.dart';
import 'package:health_app/data/models/recipe.dart';
import 'package:health_app/data/sources/foods/foods_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabasePopularFoodsSource implements FoodsSource {
  SupabasePopularFoodsSource(this._client);

  final SupabaseClient _client;

  static const _table = 'popular_foods';

  @override
  Future<List<Food>> searchByText(
    String query, {
    int limit = 30,
    FoodSearchScope scope = FoodSearchScope.all,
  }) async {
    // popular_foods is a barcode cache only — text search is served by
    // generic_foods + the user's library.
    return const [];
  }

  @override
  Future<Food?> getByBarcode(String barcode) async {
    final trimmed = barcode.trim();
    if (trimmed.isEmpty) return null;
    final row = await _client
        .from(_table)
        .select()
        .eq('barcode', trimmed)
        .maybeSingle();
    if (row == null) return null;
    return _fromRow(row);
  }

  @override
  Future<List<Food>> listCustomFoods() async => const [];

  @override
  Future<Food> saveCustomFood(Food food) =>
      throw UnsupportedError('Popular foods catalog is read-only');

  @override
  Future<void> deleteCustomFood(String id) =>
      throw UnsupportedError('Popular foods catalog is read-only');

  @override
  Future<List<Recipe>> listRecipes() async => const [];

  @override
  Future<Recipe> saveRecipe(Recipe recipe) =>
      throw UnsupportedError('Popular foods catalog is read-only');

  @override
  Future<void> deleteRecipe(String id) =>
      throw UnsupportedError('Popular foods catalog is read-only');

  Food _fromRow(Map<String, dynamic> row) {
    final barcode = row['barcode'] as String?;
    final id = (barcode != null && barcode.isNotEmpty)
        ? 'off:$barcode'
        : 'popular:${row['id']}';
    return Food(
      id: id,
      name: row['name'] as String,
      brand: row['brand'] as String?,
      barcode: barcode,
      isBeverage: (row['is_beverage'] as bool?) ?? false,
      defaultServingGrams: _toDouble(row['default_serving_grams']),
      source: FoodSourceKind.openFoodFacts,
      facts: NutritionFacts(
        kcalPer100g: _toDouble(row['kcal_per_100g']) ?? 0,
        proteinPer100g: _toDouble(row['protein_per_100g']) ?? 0,
        carbsPer100g: _toDouble(row['carbs_per_100g']) ?? 0,
        fatPer100g: _toDouble(row['fat_per_100g']) ?? 0,
        sugarPer100g: _toDouble(row['sugar_per_100g']) ?? 0,
      ),
    );
  }

  static double? _toDouble(Object? raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString());
  }
}
