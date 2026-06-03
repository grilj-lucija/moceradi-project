import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/features/nutrition/presentation/providers/recipes_controller.dart';
import 'package:health_app/features/nutrition/presentation/widgets/food_list_tile.dart';
import 'package:health_app/shared/widgets/buttons/primary_button.dart';

class RecipesPage extends ConsumerWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final recipes = ref.watch(recipesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My recipes')),
      body: recipes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Could not load recipes: $e',
            style: typography.bodyMd.copyWith(color: colors.error),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Padding(
              padding: EdgeInsets.all(spacing.stackLg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 64,
                    color: colors.onSurfaceVariant,
                  ),
                  SizedBox(height: spacing.stackMd),
                  Text(
                    'No recipes yet',
                    style: typography.titleMd,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: spacing.stackSm),
                  Text(
                    'Save a combination of foods you eat often to log it with one tap later.',
                    style: typography.bodyMd.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: spacing.stackLg),
                  PrimaryButton(
                    label: 'Create recipe',
                    icon: Icons.add,
                    onPressed: () => context.push(AppRoutes.nutritionRecipeNew),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(
              spacing.containerMarginMobile,
              spacing.stackMd,
              spacing.containerMarginMobile,
              spacing.sectionGap,
            ),
            itemCount: items.length + 1,
            separatorBuilder: (_, _) => SizedBox(height: spacing.stackSm),
            itemBuilder: (context, i) {
              if (i == items.length) {
                return Padding(
                  padding: EdgeInsets.only(top: spacing.stackMd),
                  child: PrimaryButton(
                    label: 'New recipe',
                    icon: Icons.add,
                    onPressed: () =>
                        context.push(AppRoutes.nutritionRecipeNew),
                  ),
                );
              }
              final recipe = items[i];
              final food = recipe.toFood();
              return FoodListTile(
                food: food,
                onTap: () => context.push(
                  AppRoutes.nutritionEntry,
                  extra: food,
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: colors.onSurfaceVariant,
                  ),
                  onPressed: () => ref
                      .read(recipesControllerProvider.notifier)
                      .delete(recipe.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
