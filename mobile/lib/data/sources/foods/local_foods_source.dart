import 'package:health_app/data/models/food.dart';
import 'package:health_app/data/models/recipe.dart';
import 'package:health_app/data/sources/foods/foods_source.dart';

class LocalFoodsSource implements FoodsSource {
  LocalFoodsSource();

  final Map<String, Food> _customFoods = {};
  final Map<String, Recipe> _recipes = {};

  @override
  Future<List<Food>> searchByText(
    String query, {
    int limit = 30,
    FoodSearchScope scope = FoodSearchScope.all,
  }) async {
    if (scope == FoodSearchScope.generic ||
        scope == FoodSearchScope.recent) {
      return const [];
    }

    final q = query.trim().toLowerCase();
    final pool = <Food>[];
    if (scope == FoodSearchScope.all || scope == FoodSearchScope.custom) {
      pool.addAll(_customFoods.values);
    }
    if (scope == FoodSearchScope.all || scope == FoodSearchScope.recipes) {
      pool.addAll(_recipes.values.map((r) => r.toFood()));
    }

    if (q.isEmpty) return pool.take(limit).toList();

    return pool
        .where(
          (f) =>
              f.name.toLowerCase().contains(q) ||
              (f.brand?.toLowerCase().contains(q) ?? false),
        )
        .take(limit)
        .toList();
  }

  @override
  Future<Food?> getByBarcode(String barcode) async => null;

  @override
  Future<List<Food>> listCustomFoods() async => _customFoods.values.toList();

  @override
  Future<Food> saveCustomFood(Food food) async {
    _customFoods[food.id] = food;
    return food;
  }

  @override
  Future<void> deleteCustomFood(String id) async {
    _customFoods.remove(id);
  }

  @override
  Future<List<Recipe>> listRecipes() async => _recipes.values.toList();

  @override
  Future<Recipe> saveRecipe(Recipe recipe) async {
    _recipes[recipe.id] = recipe;
    return recipe;
  }

  @override
  Future<void> deleteRecipe(String id) async {
    _recipes.remove(id);
  }
}
