import 'package:health_app/data/models/food.dart';
import 'package:health_app/data/models/recipe.dart';

enum FoodSearchScope { all, recent, custom, recipes, generic }

abstract interface class FoodsSource {
  Future<List<Food>> searchByText(
    String query, {
    int limit = 30,
    FoodSearchScope scope = FoodSearchScope.all,
  });

  Future<Food?> getByBarcode(String barcode);

  Future<List<Food>> listCustomFoods();

  Future<Food> saveCustomFood(Food food);

  Future<void> deleteCustomFood(String id);

  Future<List<Recipe>> listRecipes();

  Future<Recipe> saveRecipe(Recipe recipe);

  Future<void> deleteRecipe(String id);
}
