import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/result/result.dart';
import 'package:health_app/data/models/food.dart';
import 'package:health_app/data/models/recipe.dart';
import 'package:health_app/data/sources/foods/foods_source.dart';
import 'package:health_app/domain/repositories/foods_repository.dart';

class FoodsRepositoryImpl implements FoodsRepository {
  FoodsRepositoryImpl(this._source);

  final FoodsSource _source;

  @override
  Future<Result<List<Food>>> searchByText(
    String query, {
    int limit = 30,
    FoodSearchScope scope = FoodSearchScope.all,
  }) async {
    try {
      final items = await _source.searchByText(
        query,
        limit: limit,
        scope: scope,
      );
      return Result.ok(items);
    } on Object catch (e) {
      return Result.err(NetworkFailure(e.toString(), e));
    }
  }

  @override
  Future<Result<Food>> getByBarcode(String barcode) async {
    try {
      final food = await _source.getByBarcode(barcode);
      if (food == null) {
        return const Result.err(NotFoundFailure('Product not found'));
      }
      return Result.ok(food);
    } on Object catch (e) {
      return Result.err(NetworkFailure(e.toString(), e));
    }
  }

  @override
  Future<Result<List<Food>>> listCustomFoods() async {
    try {
      return Result.ok(await _source.listCustomFoods());
    } on Object catch (e) {
      return Result.err(UnknownFailure(e.toString(), e));
    }
  }

  @override
  Future<Result<Food>> saveCustomFood(Food food) async {
    try {
      return Result.ok(await _source.saveCustomFood(food));
    } on Object catch (e) {
      return Result.err(UnknownFailure(e.toString(), e));
    }
  }

  @override
  Future<Result<void>> deleteCustomFood(String id) async {
    try {
      await _source.deleteCustomFood(id);
      return const Result.ok(null);
    } on Object catch (e) {
      return Result.err(UnknownFailure(e.toString(), e));
    }
  }

  @override
  Future<Result<List<Recipe>>> listRecipes() async {
    try {
      return Result.ok(await _source.listRecipes());
    } on Object catch (e) {
      return Result.err(UnknownFailure(e.toString(), e));
    }
  }

  @override
  Future<Result<Recipe>> saveRecipe(Recipe recipe) async {
    try {
      return Result.ok(await _source.saveRecipe(recipe));
    } on Object catch (e) {
      return Result.err(UnknownFailure(e.toString(), e));
    }
  }

  @override
  Future<Result<void>> deleteRecipe(String id) async {
    try {
      await _source.deleteRecipe(id);
      return const Result.ok(null);
    } on Object catch (e) {
      return Result.err(UnknownFailure(e.toString(), e));
    }
  }
}
