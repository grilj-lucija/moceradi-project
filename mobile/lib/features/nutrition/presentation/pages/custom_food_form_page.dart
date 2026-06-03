import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/data/models/food.dart';
import 'package:health_app/data/models/nutrition_facts.dart';
import 'package:health_app/features/nutrition/presentation/providers/custom_foods_controller.dart';
import 'package:health_app/shared/widgets/buttons/ghost_button.dart';
import 'package:health_app/shared/widgets/buttons/primary_button.dart';
import 'package:health_app/shared/widgets/inputs/segmented_choice.dart';
import 'package:uuid/uuid.dart';

class CustomFoodFormPage extends ConsumerStatefulWidget {
  const CustomFoodFormPage({super.key});

  @override
  ConsumerState<CustomFoodFormPage> createState() =>
      _CustomFoodFormPageState();
}

class _CustomFoodFormPageState extends ConsumerState<CustomFoodFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _kcal = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _sugar = TextEditingController();
  final _fat = TextEditingController();
  final _serving = TextEditingController();
  bool _isBeverage = false;
  bool _saving = false;

  String get _unit => _isBeverage ? 'ml' : 'g';

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _kcal.dispose();
    _protein.dispose();
    _carbs.dispose();
    _sugar.dispose();
    _fat.dispose();
    _serving.dispose();
    super.dispose();
  }

  double _parse(String v) => double.tryParse(v.trim().replaceAll(',', '.')) ?? 0;

  Food _build() => Food(
        id: 'custom:${const Uuid().v4()}',
        name: _name.text.trim(),
        brand: _brand.text.trim().isEmpty ? null : _brand.text.trim(),
        source: FoodSourceKind.custom,
        isBeverage: _isBeverage,
        defaultServingGrams:
            _serving.text.trim().isEmpty ? null : _parse(_serving.text),
        facts: NutritionFacts(
          kcalPer100g: _parse(_kcal.text),
          proteinPer100g: _parse(_protein.text),
          carbsPer100g: _parse(_carbs.text),
          fatPer100g: _parse(_fat.text),
          sugarPer100g: _parse(_sugar.text),
        ),
      );

  Future<void> _saveAndLog() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final food = _build();
    final failure =
        await ref.read(customFoodsControllerProvider.notifier).save(food);
    if (!mounted) return;
    setState(() => _saving = false);
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
      return;
    }
    context.pushReplacement(AppRoutes.nutritionEntry, extra: food);
  }

  Future<void> _saveOnly() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final failure = await ref
        .read(customFoodsControllerProvider.notifier)
        .save(_build());
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

    return Scaffold(
      appBar: AppBar(title: const Text('Custom food')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            spacing.containerMarginMobile,
            spacing.stackMd,
            spacing.containerMarginMobile,
            spacing.sectionGap,
          ),
          children: [
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
              _isBeverage ? 'Per 100ml basis' : 'Per 100g basis',
              style: typography.labelMd.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: spacing.stackMd),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            SizedBox(height: spacing.stackMd),
            TextFormField(
              controller: _brand,
              decoration: const InputDecoration(labelText: 'Brand (optional)'),
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: spacing.stackLg),
            _NumberField(
              controller: _kcal,
              label: 'Calories per 100$_unit',
              suffix: 'kcal',
              required: true,
            ),
            SizedBox(height: spacing.stackMd),
            _NumberField(
              controller: _protein,
              label: 'Protein per 100$_unit',
              suffix: 'g',
            ),
            SizedBox(height: spacing.stackMd),
            _NumberField(
              controller: _carbs,
              label: 'Carbs per 100$_unit',
              suffix: 'g',
            ),
            SizedBox(height: spacing.stackMd),
            _NumberField(
              controller: _sugar,
              label: 'Sugar per 100$_unit (of which)',
              suffix: 'g',
            ),
            SizedBox(height: spacing.stackMd),
            _NumberField(
              controller: _fat,
              label: 'Fat per 100$_unit',
              suffix: 'g',
            ),
            SizedBox(height: spacing.stackMd),
            _NumberField(
              controller: _serving,
              label: 'Default serving (optional)',
              suffix: _unit,
            ),
            SizedBox(height: spacing.stackLg),
            PrimaryButton(
              label: 'Save & log',
              icon: Icons.add,
              onPressed: _saveAndLog,
              isLoading: _saving,
            ),
            SizedBox(height: spacing.stackSm),
            GhostButton(
              label: 'Save only',
              icon: Icons.bookmark_border,
              onPressed: _saving ? null : _saveOnly,
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.suffix,
    this.required = false,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
      ],
      decoration: InputDecoration(labelText: label, suffixText: suffix),
      textInputAction: TextInputAction.next,
      validator: (v) {
        if (!required) return null;
        final n = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
        if (n == null || n <= 0) return 'Enter a value > 0';
        return null;
      },
    );
  }
}
