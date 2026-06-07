import 'package:health_app/core/result/result.dart';
import 'package:health_app/data/models/food.dart';
import 'package:health_app/data/models/recipe.dart';
import 'package:health_app/data/sources/foods/foods_source.dart' show FoodSearchScope;

export 'package:health_app/data/sources/foods/foods_source.dart' show FoodSearchScope;

abstract interface class FoodsRepository {
  Future<Result<List<Food>>> searchByText(
    String query, {
    int limit = 30,
    FoodSearchScope scope = FoodSearchScope.all,
  });

  Future<Result<Food>> getByBarcode(String barcode);

  Future<Result<List<Food>>> listCustomFoods();

  Future<Result<Food>> saveCustomFood(Food food);

  Future<Result<void>> deleteCustomFood(String id);

  Future<Result<List<Recipe>>> listRecipes();

  Future<Result<Recipe>> saveRecipe(Recipe recipe);

  Future<Result<void>> deleteRecipe(String id);
}
