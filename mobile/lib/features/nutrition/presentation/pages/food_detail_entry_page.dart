import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/data/models/food.dart';
import 'package:health_app/data/models/food_entry.dart';
import 'package:health_app/data/models/meal_slot.dart';
import 'package:health_app/features/nutrition/presentation/providers/daily_nutrition_controller.dart';
import 'package:health_app/shared/widgets/buttons/primary_button.dart';
import 'package:health_app/shared/widgets/cards/glass_card.dart';
import 'package:health_app/shared/widgets/inputs/segmented_choice.dart';
import 'package:uuid/uuid.dart';

class FoodDetailEntryPage extends ConsumerStatefulWidget {
  const FoodDetailEntryPage({required this.food, super.key});

  final Food food;

  @override
  ConsumerState<FoodDetailEntryPage> createState() =>
      _FoodDetailEntryPageState();
}

class _FoodDetailEntryPageState extends ConsumerState<FoodDetailEntryPage> {
  late final TextEditingController _gramsController;
  MealSlot _mealSlot = MealSlot.snack;
  bool _saving = false;
  late bool _isBeverage;

  String get _amountUnit => _isBeverage ? 'ml' : 'g';
  String get _per100Suffix => _isBeverage ? '/100ml' : '/100g';

  Food get _foodWithOverride => _isBeverage == widget.food.isBeverage
      ? widget.food
      : widget.food.copyWith(isBeverage: _isBeverage);

  MealSlot _defaultSlotForNow() {
    final hour = DateTime.now().hour;
    if (hour < 11) return MealSlot.breakfast;
    if (hour < 15) return MealSlot.lunch;
    if (hour < 21) return MealSlot.dinner;
    return MealSlot.snack;
  }

  @override
  void initState() {
    super.initState();
    final defaultGrams =
        widget.food.defaultServingGrams?.round().toString() ?? '100';
    _gramsController = TextEditingController(text: defaultGrams);
    _mealSlot = _defaultSlotForNow();
    _isBeverage = widget.food.isBeverage;
  }

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  double get _grams => double.tryParse(_gramsController.text.trim()) ?? 0;

  Future<void> _save() async {
    if (_grams <= 0) {
      final unit = _isBeverage ? 'milliliters' : 'grams';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter a valid amount in $unit')),
      );
      return;
    }
    setState(() => _saving = true);
    final entry = FoodEntry(
      id: const Uuid().v4(),
      foodSnapshot: _foodWithOverride,
      grams: _grams,
      loggedAt: DateTime.now(),
      mealSlot: _mealSlot,
    );
    final failure = await ref
        .read(dailyNutritionControllerProvider.notifier)
        .addEntry(entry);
    if (!mounted) return;
    setState(() => _saving = false);
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
      return;
    }
    context.go(AppRoutes.nutrition);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final totals = widget.food.facts.forAmount(_grams);

    return Scaffold(
      appBar: AppBar(title: const Text('Log amount')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          spacing.containerMarginMobile,
          spacing.stackMd,
          spacing.containerMarginMobile,
          spacing.sectionGap,
        ),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.food.name, style: typography.titleMd),
                if (widget.food.brand?.isNotEmpty ?? false) ...[
                  SizedBox(height: spacing.stackSm / 2),
                  Text(
                    widget.food.brand!,
                    style: typography.bodyMd.copyWith(
                      color: colors.enduranceCyan,
                    ),
                  ),
                ],
                SizedBox(height: spacing.stackSm),
                Text(
                  '${widget.food.facts.kcalPer100g.round()} kcal$_per100Suffix',
                  style: typography.bodyMd.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.stackLg),
          Text(
            'TYPE',
            style: typography.labelMd.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spacing.stackSm),
          SegmentedChoice<bool>(
            value: _isBeverage,
            onChanged: (v) => setState(() => _isBeverage = v),
            options: const [
              SegmentedChoiceOption(
                value: false,
                label: 'Food',
                icon: Icons.restaurant_outlined,
              ),
              SegmentedChoiceOption(
                value: true,
                label: 'Drink',
                icon: Icons.local_drink_outlined,
              ),
            ],
          ),
          SizedBox(height: spacing.stackLg),
          Text(
            'AMOUNT',
            style: typography.labelMd.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spacing.stackSm),
          TextField(
            controller: _gramsController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
            ],
            style: typography.metricXl.copyWith(color: colors.enduranceCyan),
            decoration: InputDecoration(
              suffixText: _amountUnit,
              suffixStyle: typography.titleMd.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: spacing.stackLg),
          Text(
            'MEAL',
            style: typography.labelMd.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spacing.stackSm),
          SegmentedChoice<MealSlot>(
            value: _mealSlot,
            onChanged: (v) => setState(() => _mealSlot = v),
            options: [
              for (final slot in MealSlot.values)
                SegmentedChoiceOption(
                  value: slot,
                  label: slot.label,
                ),
            ],
          ),
          SizedBox(height: spacing.stackLg),
          Container(
            padding: EdgeInsets.all(spacing.stackMd),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: radius.lgRadius,
              border: Border.all(color: colors.ghostBorder),
            ),
            child: Column(
              children: [
                _TotalRow(label: 'Calories', value: '${totals.kcal.round()} kcal'),
                _TotalRow(
                  label: 'Protein',
                  value: '${totals.proteinGrams.round()} g',
                ),
                _TotalRow(
                  label: 'Carbs',
                  value: '${totals.carbsGrams.round()} g',
                ),
                _TotalRow(
                  label: 'Fat',
                  value: '${totals.fatGrams.round()} g',
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.stackLg),
          PrimaryButton(
            label: 'Add to log',
            icon: Icons.check,
            onPressed: _save,
            isLoading: _saving,
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.stackSm / 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: typography.bodyMd.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          Text(value, style: typography.bodyLg),
        ],
      ),
    );
  }
}
