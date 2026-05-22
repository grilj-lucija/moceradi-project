import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/data/models/food.dart';
import 'package:health_app/di/providers.dart';

class CustomFoodsController extends AsyncNotifier<List<Food>> {
  @override
  Future<List<Food>> build() async {
    final result = await ref.read(foodsRepositoryProvider).listCustomFoods();
    return result.fold(ok: (items) => items, err: (_) => const []);
  }

  Future<Failure?> save(Food food) async {
    final result = await ref.read(foodsRepositoryProvider).saveCustomFood(food);
    return result.fold(
      ok: (_) async {
        ref.invalidateSelf();
        return null;
      },
      err: (failure) => failure,
    );
  }

  Future<Failure?> delete(String id) async {
    final result =
        await ref.read(foodsRepositoryProvider).deleteCustomFood(id);
    return result.fold(
      ok: (_) async {
        ref.invalidateSelf();
        return null;
      },
      err: (failure) => failure,
    );
  }
}

final customFoodsControllerProvider =
    AsyncNotifierProvider<CustomFoodsController, List<Food>>(
  CustomFoodsController.new,
);
