import 'dart:developer' as developer;

import 'package:health_app/data/models/food.dart';
import 'package:health_app/data/models/recipe.dart';
import 'package:health_app/data/sources/foods/foods_source.dart';

/// Orchestrates the food data sources:
/// - [barcodeRemote]: live OFF API. Used for barcode scans.
/// - [barcodeCache]: Supabase popular_foods (cached OFF). Barcode fallback only.
/// - [catalog]: Supabase generic_foods (curated). Backs text search.
/// - [library]: per-user library — custom foods, recipes, recent foods.
class CompositeFoodsSource implements FoodsSource {
  CompositeFoodsSource({
    required this.barcodeRemote,
    required this.barcodeCache,
    required this.catalog,
    required this.library,
  });

  final FoodsSource barcodeRemote;
  final FoodsSource barcodeCache;
  final FoodsSource catalog;
  final FoodsSource library;

  static const _recentLimit = 10;

  @override
  Future<List<Food>> searchByText(
    String query, {
    int limit = 30,
    FoodSearchScope scope = FoodSearchScope.all,
  }) async {
    switch (scope) {
      case FoodSearchScope.generic:
        return _safeSearch(catalog, query, limit, scope);
      case FoodSearchScope.recent:
        return _safeSearch(library, query, _recentLimit, scope);
      case FoodSearchScope.custom:
      case FoodSearchScope.recipes:
        return _safeSearch(library, query, limit, scope);
      case FoodSearchScope.all:
        return _searchAll(query, limit);
    }
  }

  Future<List<Food>> _searchAll(String query, int limit) async {
    final results = await Future.wait([
      _safeList(library.listCustomFoods),
      _safeRecipesAsFoods(),
      _safeSearch(catalog, query, limit, FoodSearchScope.generic),
    ]);
    final customs = results[0];
    final recipeFoods = results[1];
    final generics = results[2];

    final q = query.trim().toLowerCase();
    bool matches(Food f) =>
        q.isEmpty ||
        f.name.toLowerCase().contains(q) ||
        (f.brand?.toLowerCase().contains(q) ?? false);

    final seen = <String>{};
    final merged = <Food>[];
    for (final list in [customs, recipeFoods, generics]) {
      for (final f in list) {
        if (matches(f) && seen.add(f.id)) merged.add(f);
      }
    }
    merged.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return merged.take(limit).toList();
  }

  Future<List<Food>> _safeRecipesAsFoods() async {
    try {
      final recipes = await library.listRecipes();
      return [for (final r in recipes) r.toFood()];
    } on Object catch (e, st) {
      developer.log(
        'listRecipes failed in ${library.runtimeType}',
        name: 'CompositeFoodsSource',
        error: e,
        stackTrace: st,
      );
      return const [];
    }
  }

  Future<List<Food>> _safeList(Future<List<Food>> Function() op) async {
    try {
      return await op();
    } on Object catch (e, st) {
      developer.log(
        'list op failed',
        name: 'CompositeFoodsSource',
        error: e,
        stackTrace: st,
      );
      return const [];
    }
  }

  @override
  Future<Food?> getByBarcode(String barcode) async {
    try {
      final remoteHit = await barcodeRemote.getByBarcode(barcode);
      if (remoteHit != null) return remoteHit;
    } on Object catch (_) {
      // Fall through to local fallbacks.
    }
    final cached = await _safeBarcode(barcodeCache, barcode);
    if (cached != null) return cached;
    return _safeBarcode(library, barcode);
  }

  @override
  Future<List<Food>> listCustomFoods() => library.listCustomFoods();

  @override
  Future<Food> saveCustomFood(Food food) => library.saveCustomFood(food);

  @override
  Future<void> deleteCustomFood(String id) => library.deleteCustomFood(id);

  @override
  Future<List<Recipe>> listRecipes() => library.listRecipes();

  @override
  Future<Recipe> saveRecipe(Recipe recipe) => library.saveRecipe(recipe);

  @override
  Future<void> deleteRecipe(String id) => library.deleteRecipe(id);

  Future<List<Food>> _safeSearch(
    FoodsSource source,
    String query,
    int limit,
    FoodSearchScope scope,
  ) async {
    try {
      return await source.searchByText(query, limit: limit, scope: scope);
    } on Object catch (e, st) {
      developer.log(
        'searchByText failed in ${source.runtimeType}',
        name: 'CompositeFoodsSource',
        error: e,
        stackTrace: st,
      );
      return const [];
    }
  }

  Future<Food?> _safeBarcode(FoodsSource source, String barcode) async {
    try {
      return await source.getByBarcode(barcode);
    } on Object catch (e, st) {
      developer.log(
        'getByBarcode failed in ${source.runtimeType}',
        name: 'CompositeFoodsSource',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
