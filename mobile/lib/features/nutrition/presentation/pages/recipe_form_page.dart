import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/data/models/food.dart';
import 'package:health_app/data/models/recipe.dart';
import 'package:health_app/features/nutrition/presentation/providers/food_search_controller.dart';
import 'package:health_app/features/nutrition/presentation/providers/recipes_controller.dart';
import 'package:health_app/features/nutrition/presentation/widgets/food_list_tile.dart';
import 'package:health_app/shared/widgets/buttons/ghost_button.dart';
import 'package:health_app/shared/widgets/buttons/primary_button.dart';
import 'package:uuid/uuid.dart';

class RecipeFormPage extends ConsumerStatefulWidget {
  const RecipeFormPage({super.key});

  @override
  ConsumerState<RecipeFormPage> createState() => _RecipeFormPageState();
}

class _RecipeFormPageState extends ConsumerState<RecipeFormPage> {
  final _name = TextEditingController();
  final List<RecipeIngredient> _ingredients = [];
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _addIngredient() async {
    final food = await showModalBottomSheet<Food>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surfaceContainer,
      builder: (_) => const _FoodPickerSheet(),
    );
    if (food == null || !mounted) return;
    final grams = await showDialog<double>(
      context: context,
      builder: (_) => _GramsDialog(
        initial: food.defaultServingGrams ?? 100,
        unit: food.amountUnit,
      ),
    );
    if (grams == null || grams <= 0) return;
    setState(() {
      _ingredients.add(RecipeIngredient(foodSnapshot: food, grams: grams));
    });
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give the recipe a name')),
      );
      return;
    }
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one ingredient')),
      );
      return;
    }
    setState(() => _saving = true);
    final recipe = Recipe(
      id: 'recipe:${const Uuid().v4()}',
      name: _name.text.trim(),
      ingredients: List.unmodifiable(_ingredients),
    );
    final failure =
        await ref.read(recipesControllerProvider.notifier).save(recipe);
    if (!mounted) return;
    setState(() => _saving = false);
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
      return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    final totalGrams =
        _ingredients.fold<double>(0, (s, e) => s + e.grams);
    final totalKcal =
        _ingredients.fold<double>(0, (s, e) => s + e.totals.kcal);

    return Scaffold(
      appBar: AppBar(title: const Text('New recipe')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          spacing.containerMarginMobile,
          spacing.stackMd,
          spacing.containerMarginMobile,
          spacing.sectionGap,
        ),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Recipe name'),
          ),
          SizedBox(height: spacing.stackLg),
          Row(
            children: [
              Expanded(
                child: Text('Ingredients', style: typography.titleMd),
              ),
              Text(
                '${totalGrams.round()} g · ${totalKcal.round()} kcal',
                style: typography.labelMd.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.stackSm),
          if (_ingredients.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.stackMd),
              child: Text(
                'No ingredients yet. Add foods from your custom list or search.',
                style: typography.bodyMd.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            )
          else
            for (var i = 0; i < _ingredients.length; i++) ...[
              Padding(
                padding: EdgeInsets.only(bottom: spacing.stackSm),
                child: FoodListTile(
                  food: _ingredients[i].foodSnapshot,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_ingredients[i].grams.round()}'
                        '${_ingredients[i].foodSnapshot.amountUnit}',
                        style: typography.bodyMd,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: colors.onSurfaceVariant,
                          size: 18,
                        ),
                        onPressed: () =>
                            setState(() => _ingredients.removeAt(i)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          SizedBox(height: spacing.stackMd),
          GhostButton(
            label: 'Add ingredient',
            icon: Icons.add,
            onPressed: _addIngredient,
          ),
          SizedBox(height: spacing.stackLg),
          PrimaryButton(
            label: 'Save recipe',
            icon: Icons.save_outlined,
            onPressed: _save,
            isLoading: _saving,
          ),
        ],
      ),
    );
  }
}

class _FoodPickerSheet extends ConsumerStatefulWidget {
  const _FoodPickerSheet();

  @override
  ConsumerState<_FoodPickerSheet> createState() => _FoodPickerSheetState();
}

class _FoodPickerSheetState extends ConsumerState<_FoodPickerSheet> {
  final TextEditingController _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final results = ref.watch(foodSearchControllerProvider);
    final notifier = ref.read(foodSearchControllerProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          spacing.containerMarginMobile,
          spacing.stackMd,
          spacing.containerMarginMobile,
          MediaQuery.of(context).viewInsets.bottom + spacing.stackMd,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: spacing.stackMd),
            TextField(
              controller: _query,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search foods…',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => unawaited(notifier.search(v)),
            ),
            SizedBox(height: spacing.stackMd),
            SizedBox(
              height: 400,
              child: results.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Search failed: $e')),
                data: (state) {
                  final items = state.items;
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        _query.text.isEmpty
                            ? 'Type to search.'
                            : 'No matches.',
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: spacing.stackSm),
                    itemBuilder: (_, i) => FoodListTile(
                      food: items[i],
                      onTap: () => Navigator.of(context).pop(items[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GramsDialog extends StatefulWidget {
  const _GramsDialog({required this.initial, required this.unit});

  final double initial;
  final String unit;

  @override
  State<_GramsDialog> createState() => _GramsDialogState();
}

class _GramsDialogState extends State<_GramsDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial.round().toString());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Amount'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
        ],
        decoration: InputDecoration(suffixText: widget.unit),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final v = double.tryParse(
              _controller.text.trim().replaceAll(',', '.'),
            );
            Navigator.of(context).pop(v);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
