import 'package:health_app/data/models/food.dart';
import 'package:health_app/data/models/nutrition_facts.dart';
import 'package:health_app/data/models/recipe.dart';
import 'package:health_app/data/sources/foods/foods_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseFoodsSource implements FoodsSource {
  SupabaseFoodsSource(this._client);

  final SupabaseClient _client;

  static const _customFoodsTable = 'custom_foods';
  static const _recipesTable = 'recipes';
  static const _recipeIngredientsTable = 'recipe_ingredients';
  static const _recentFoodsTable = 'recent_foods';

  static const _customIdPrefix = 'custom:';
  static const _recipeIdPrefix = 'recipe:';

  String? get _uid => _client.auth.currentUser?.id;

  String _requireUid() {
    final uid = _uid;
    if (uid == null) throw const AuthException('Not signed in');
    return uid;
  }

  @override
  Future<List<Food>> searchByText(
    String query, {
    int limit = 30,
    FoodSearchScope scope = FoodSearchScope.all,
  }) async {
    if (_uid == null) return const [];
    final q = query.trim().toLowerCase();

    switch (scope) {
      case FoodSearchScope.generic:
        return const [];
      case FoodSearchScope.recent:
        return _filterByQuery(
          await _listRecentFoods(limit: limit * 2),
          q,
          limit,
        );
      case FoodSearchScope.custom:
        return _filterByQuery(await listCustomFoods(), q, limit);
      case FoodSearchScope.recipes:
        final recipes = await listRecipes();
        return _filterByQuery(
          recipes.map((r) => r.toFood()).toList(),
          q,
          limit,
        );
      case FoodSearchScope.all:
        return _searchAll(q, limit);
    }
  }

  Future<List<Food>> _searchAll(String q, int limit) async {
    // Empty query default view: only show recent foods (fast, single round-trip).
    // Custom foods and recipes are reachable via their dedicated scope chips.
    if (q.isEmpty) {
      return _listRecentFoods(limit: limit);
    }

    // Active query: parallelize the three reads to cut latency.
    final results = await Future.wait([
      listCustomFoods(),
      listRecipes(),
      _listRecentFoods(limit: 50),
    ]);
    final customs = results[0] as List<Food>;
    final recipes = results[1] as List<Recipe>;
    final recent = results[2] as List<Food>;

    final seen = <String>{};
    final merged = <Food>[];
    void addAll(Iterable<Food> items) {
      for (final f in items) {
        if (seen.add(f.id)) merged.add(f);
      }
    }

    addAll(customs);
    addAll(recipes.map((r) => r.toFood()));
    addAll(recent);

    return _filterByQuery(merged, q, limit);
  }

  static List<Food> _filterByQuery(List<Food> items, String q, int limit) {
    if (q.isEmpty) return items.take(limit).toList();
    return items
        .where(
          (f) =>
              f.name.toLowerCase().contains(q) ||
              (f.brand?.toLowerCase().contains(q) ?? false),
        )
        .take(limit)
        .toList();
  }

  Future<List<Food>> _listRecentFoods({int limit = 50}) async {
    final uid = _uid;
    if (uid == null) return const [];
    final rows = await _client
        .from(_recentFoodsTable)
        .select()
        .eq('user_id', uid)
        .order('last_logged_at', ascending: false)
        .limit(limit);
    return [
      for (final row in rows as List<dynamic>)
        _snapshotFromRow(row as Map<String, dynamic>),
    ];
  }

  @override
  Future<Food?> getByBarcode(String barcode) async => null;

  @override
  Future<List<Food>> listCustomFoods() async {
    final uid = _uid;
    if (uid == null) return [];
    final rows = await _client
        .from(_customFoodsTable)
        .select()
        .eq('user_id', uid)
        .order('name');
    return [
      for (final row in rows as List<dynamic>)
        _customFoodFromRow(row as Map<String, dynamic>),
    ];
  }

  @override
  Future<Food> saveCustomFood(Food food) async {
    final uid = _requireUid();
    final rawId = _stripPrefix(food.id, _customIdPrefix);
    final payload = <String, dynamic>{
      if (rawId.isNotEmpty) 'id': rawId,
      'user_id': uid,
      'name': food.name,
      'brand': food.brand,
      'is_beverage': food.isBeverage,
      'default_serving_grams': food.defaultServingGrams,
      'kcal_per_100g': food.facts.kcalPer100g,
      'protein_per_100g': food.facts.proteinPer100g,
      'carbs_per_100g': food.facts.carbsPer100g,
      'fat_per_100g': food.facts.fatPer100g,
      'sugar_per_100g': food.facts.sugarPer100g,
    };
    final row = await _client
        .from(_customFoodsTable)
        .upsert(payload)
        .select()
        .single();
    return _customFoodFromRow(row);
  }

  @override
  Future<void> deleteCustomFood(String id) async {
    final uid = _requireUid();
    final rawId = _stripPrefix(id, _customIdPrefix);
    await _client
        .from(_customFoodsTable)
        .delete()
        .eq('id', rawId)
        .eq('user_id', uid);
  }

  @override
  Future<List<Recipe>> listRecipes() async {
    final uid = _uid;
    if (uid == null) return [];
    final rows = await _client
        .from(_recipesTable)
        .select('*, $_recipeIngredientsTable(*)')
        .eq('user_id', uid)
        .order('name');
    return [
      for (final row in rows as List<dynamic>)
        _recipeFromRow(row as Map<String, dynamic>),
    ];
  }

  @override
  Future<Recipe> saveRecipe(Recipe recipe) async {
    final uid = _requireUid();
    final rawId = _stripPrefix(recipe.id, _recipeIdPrefix);

    final recipePayload = <String, dynamic>{
      if (rawId.isNotEmpty) 'id': rawId,
      'user_id': uid,
      'name': recipe.name,
    };
    final saved = await _client
        .from(_recipesTable)
        .upsert(recipePayload)
        .select()
        .single();

    final newRecipeId = saved['id'] as String;

    await _client
        .from(_recipeIngredientsTable)
        .delete()
        .eq('recipe_id', newRecipeId);

    if (recipe.ingredients.isNotEmpty) {
      final ingredientRows = <Map<String, dynamic>>[];
      for (var i = 0; i < recipe.ingredients.length; i++) {
        final ing = recipe.ingredients[i];
        ingredientRows.add({
          'recipe_id': newRecipeId,
          'position': i,
          'grams': ing.grams,
          ..._snapshotPayload(ing.foodSnapshot),
        });
      }
      await _client.from(_recipeIngredientsTable).insert(ingredientRows);
    }

    final fresh = await _client
        .from(_recipesTable)
        .select('*, $_recipeIngredientsTable(*)')
        .eq('id', newRecipeId)
        .single();
    return _recipeFromRow(fresh);
  }

  @override
  Future<void> deleteRecipe(String id) async {
    final uid = _requireUid();
    final rawId = _stripPrefix(id, _recipeIdPrefix);
    await _client
        .from(_recipesTable)
        .delete()
        .eq('id', rawId)
        .eq('user_id', uid);
  }

  Food _customFoodFromRow(Map<String, dynamic> row) {
    return Food(
      id: '$_customIdPrefix${row['id']}',
      name: row['name'] as String,
      brand: row['brand'] as String?,
      isBeverage: (row['is_beverage'] as bool?) ?? false,
      defaultServingGrams: _toDouble(row['default_serving_grams']),
      source: FoodSourceKind.custom,
      facts: NutritionFacts(
        kcalPer100g: _toDouble(row['kcal_per_100g']) ?? 0,
        proteinPer100g: _toDouble(row['protein_per_100g']) ?? 0,
        carbsPer100g: _toDouble(row['carbs_per_100g']) ?? 0,
        fatPer100g: _toDouble(row['fat_per_100g']) ?? 0,
        sugarPer100g: _toDouble(row['sugar_per_100g']) ?? 0,
      ),
    );
  }

  Recipe _recipeFromRow(Map<String, dynamic> row) {
    final ingredientsRaw =
        (row[_recipeIngredientsTable] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>()
            .toList()
          ..sort(
            (a, b) => ((a['position'] as int?) ?? 0)
                .compareTo((b['position'] as int?) ?? 0),
          );

    return Recipe(
      id: '$_recipeIdPrefix${row['id']}',
      name: row['name'] as String,
      ingredients: [
        for (final ing in ingredientsRaw)
          RecipeIngredient(
            grams: _toDouble(ing['grams']) ?? 0,
            foodSnapshot: _snapshotFromRow(ing),
          ),
      ],
    );
  }

  Food _snapshotFromRow(Map<String, dynamic> row) {
    return Food(
      id: row['food_external_id'] as String,
      name: row['food_name'] as String,
      brand: row['food_brand'] as String?,
      isBeverage: (row['food_is_beverage'] as bool?) ?? false,
      defaultServingGrams: _toDouble(row['food_default_serving_grams']),
      source: _sourceFromWire(row['food_source'] as String?),
      facts: NutritionFacts(
        kcalPer100g: _toDouble(row['food_kcal_per_100g']) ?? 0,
        proteinPer100g: _toDouble(row['food_protein_per_100g']) ?? 0,
        carbsPer100g: _toDouble(row['food_carbs_per_100g']) ?? 0,
        fatPer100g: _toDouble(row['food_fat_per_100g']) ?? 0,
        sugarPer100g: _toDouble(row['food_sugar_per_100g']) ?? 0,
      ),
    );
  }

  static Map<String, dynamic> _snapshotPayload(Food food) => {
        'food_external_id': food.id,
        'food_name': food.name,
        'food_brand': food.brand,
        'food_source': _sourceToWire(food.source),
        'food_is_beverage': food.isBeverage,
        'food_default_serving_grams': food.defaultServingGrams,
        'food_kcal_per_100g': food.facts.kcalPer100g,
        'food_protein_per_100g': food.facts.proteinPer100g,
        'food_carbs_per_100g': food.facts.carbsPer100g,
        'food_fat_per_100g': food.facts.fatPer100g,
        'food_sugar_per_100g': food.facts.sugarPer100g,
      };

  static String _sourceToWire(FoodSourceKind source) => switch (source) {
        FoodSourceKind.openFoodFacts => 'open_food_facts',
        FoodSourceKind.generic => 'generic',
        FoodSourceKind.custom => 'custom',
        FoodSourceKind.recipe => 'recipe',
      };

  static FoodSourceKind _sourceFromWire(String? value) => switch (value) {
        'open_food_facts' => FoodSourceKind.openFoodFacts,
        'generic' => FoodSourceKind.generic,
        'recipe' => FoodSourceKind.recipe,
        _ => FoodSourceKind.custom,
      };

  static String _stripPrefix(String id, String prefix) {
    if (id.startsWith(prefix)) return id.substring(prefix.length);
    return id;
  }

  static double? _toDouble(Object? raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString());
  }
}

extension SupabaseFoodsSourceSnapshot on Food {
  Map<String, dynamic> toSupabaseSnapshot() =>
      SupabaseFoodsSource._snapshotPayload(this);
}
