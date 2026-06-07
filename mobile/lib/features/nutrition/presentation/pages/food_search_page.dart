import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/data/sources/foods/foods_source.dart';
import 'package:health_app/features/nutrition/presentation/providers/food_search_controller.dart';
import 'package:health_app/features/nutrition/presentation/widgets/food_list_tile.dart';
import 'package:health_app/shared/widgets/buttons/ghost_button.dart';

class FoodSearchPage extends ConsumerStatefulWidget {
  const FoodSearchPage({super.key});

  @override
  ConsumerState<FoodSearchPage> createState() => _FoodSearchPageState();
}

class _FoodSearchPageState extends ConsumerState<FoodSearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final asyncState = ref.watch(foodSearchControllerProvider);
    final notifier = ref.read(foodSearchControllerProvider.notifier);

    final state = asyncState.value ?? const FoodSearchState.initial();
    final isLoading = asyncState.isLoading || state.isFetching;

    return Scaffold(
      appBar: AppBar(title: const Text('Search foods')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.containerMarginMobile,
                spacing.stackMd,
                spacing.containerMarginMobile,
                spacing.stackSm,
              ),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onChanged: (v) => unawaited(notifier.search(v)),
                decoration: InputDecoration(
                  hintText: _hintForScope(state.scope),
                  prefixIcon: Icon(
                    Icons.search,
                    color: colors.onSurfaceVariant,
                  ),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(
                            Icons.close,
                            color: colors.onSurfaceVariant,
                          ),
                          onPressed: () {
                            _controller.clear();
                            unawaited(notifier.search(''));
                            setState(() {});
                          },
                        ),
                ),
              ),
            ),
            _ScopeChips(
              scope: state.scope,
              onChanged: (s) => unawaited(notifier.setScope(s)),
            ),
            SizedBox(height: spacing.stackSm),
            Expanded(
              child: _buildBody(
                context: context,
                state: state,
                isLoading: isLoading,
                error: asyncState.error,
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.containerMarginMobile,
                  0,
                  spacing.containerMarginMobile,
                  spacing.stackMd,
                ),
                child: GhostButton(
                  label: "Can't find it? Create custom food",
                  icon: Icons.edit_note,
                  onPressed: () => context.push(AppRoutes.nutritionCustom),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required FoodSearchState state,
    required bool isLoading,
    required Object? error,
  }) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    if (error != null && state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(spacing.stackLg),
          child: Text(
            'Search failed: $error',
            style: typography.bodyMd.copyWith(color: colors.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(spacing.stackLg),
          child: Text(
            _emptyMessage(state),
            style: typography.bodyMd.copyWith(color: colors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Stack(
      children: [
        ListView.separated(
          padding: EdgeInsets.fromLTRB(
            spacing.containerMarginMobile,
            spacing.stackSm,
            spacing.containerMarginMobile,
            spacing.stackLg,
          ),
          itemCount: state.items.length,
          separatorBuilder: (_, _) => SizedBox(height: spacing.stackSm),
          itemBuilder: (context, i) {
            final food = state.items[i];
            return FoodListTile(
              food: food,
              onTap: () =>
                  context.push(AppRoutes.nutritionEntry, extra: food),
            );
          },
        ),
        if (isLoading)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              minHeight: 2,
              color: colors.enduranceCyan,
              backgroundColor: colors.enduranceCyan.withValues(alpha: 0.15),
            ),
          ),
      ],
    );
  }

  String _hintForScope(FoodSearchScope scope) {
    return switch (scope) {
      FoodSearchScope.all => 'What did you eat?',
      FoodSearchScope.recent => 'Find something you logged recently',
      FoodSearchScope.custom => 'Find one of your custom foods',
      FoodSearchScope.recipes => 'Find one of your recipes',
      FoodSearchScope.generic => 'Search the food catalog',
    };
  }

  String _emptyMessage(FoodSearchState state) {
    if (state.query.isNotEmpty) {
      return switch (state.scope) {
        FoodSearchScope.all =>
          'No matches. Try a different term, or create a custom food.',
        FoodSearchScope.recent =>
          'No recent foods match that.',
        FoodSearchScope.custom =>
          'No matching custom food. Tap "Create custom food" below.',
        FoodSearchScope.recipes => 'No matching recipes.',
        FoodSearchScope.generic =>
          'Not in the generic catalog. Try “All” or create a custom food.',
      };
    }
    return switch (state.scope) {
      FoodSearchScope.all =>
        'Nothing to show yet.\nCreate a custom food or seed the generic catalog.',
      FoodSearchScope.recent =>
        'No recent foods yet.\nLog something once and it shows up here.',
      FoodSearchScope.custom =>
        'No custom foods yet.\nTap "Create custom food" below to add one.',
      FoodSearchScope.recipes =>
        'No recipes yet.\nCreate one from Add Food → Recipe.',
      FoodSearchScope.generic =>
        'Generic catalog is empty.\nSeed it from the scraper.',
    };
  }
}

class _ScopeChips extends StatelessWidget {
  const _ScopeChips({required this.scope, required this.onChanged});

  final FoodSearchScope scope;
  final ValueChanged<FoodSearchScope> onChanged;

  static const _options = <(FoodSearchScope, String)>[
    (FoodSearchScope.all, 'All'),
    (FoodSearchScope.recent, 'Recent'),
    (FoodSearchScope.custom, 'Custom'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: spacing.containerMarginMobile,
        ),
        itemCount: _options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final (value, label) = _options[i];
          final selected = scope == value;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => onChanged(value),
            labelStyle: typography.labelMd.copyWith(
              color: selected ? colors.onPrimary : colors.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
            selectedColor: colors.enduranceCyan,
            backgroundColor: colors.surfaceContainer,
            side: BorderSide(
              color: selected
                  ? colors.enduranceCyan
                  : colors.ghostBorder,
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}
