import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/data/models/recipe.dart';
import 'package:health_app/di/providers.dart';

class RecipesController extends AsyncNotifier<List<Recipe>> {
  @override
  Future<List<Recipe>> build() async {
    final result = await ref.read(foodsRepositoryProvider).listRecipes();
    return result.fold(ok: (items) => items, err: (_) => const []);
  }

  Future<Failure?> save(Recipe recipe) async {
    final result = await ref.read(foodsRepositoryProvider).saveRecipe(recipe);
    return result.fold(
      ok: (_) async {
        ref.invalidateSelf();
        return null;
      },
      err: (failure) => failure,
    );
  }

  Future<Failure?> delete(String id) async {
    final result = await ref.read(foodsRepositoryProvider).deleteRecipe(id);
    return result.fold(
      ok: (_) async {
        ref.invalidateSelf();
        return null;
      },
      err: (failure) => failure,
    );
  }
}

final recipesControllerProvider =
    AsyncNotifierProvider<RecipesController, List<Recipe>>(
  RecipesController.new,
);
