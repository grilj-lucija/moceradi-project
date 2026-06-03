import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/data/models/food_entry.dart';
import 'package:health_app/data/models/meal_slot.dart';
import 'package:health_app/features/nutrition/presentation/providers/daily_nutrition_controller.dart';
import 'package:health_app/shared/widgets/buttons/primary_button.dart';
import 'package:health_app/shared/widgets/inputs/segmented_choice.dart';
import 'package:intl/intl.dart';

Future<void> showEntryDetailsSheet(
  BuildContext context, {
  required FoodEntry entry,
  required bool allowEdit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EntryDetailsSheet(entry: entry, allowEdit: allowEdit),
  );
}

class _EntryDetailsSheet extends ConsumerStatefulWidget {
  const _EntryDetailsSheet({required this.entry, required this.allowEdit});

  final FoodEntry entry;
  final bool allowEdit;

  @override
  ConsumerState<_EntryDetailsSheet> createState() =>
      _EntryDetailsSheetState();
}

class _EntryDetailsSheetState extends ConsumerState<_EntryDetailsSheet> {
  late final TextEditingController _amountController;
  late MealSlot _mealSlot;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.entry.grams.toStringAsFixed(0),
    );
    _mealSlot = widget.entry.mealSlot;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _amount {
    final raw = _amountController.text.trim().replaceAll(',', '.');
    return double.tryParse(raw) ?? 0;
  }

  String get _unit => widget.entry.foodSnapshot.amountUnit;

  bool get _isDirty {
    if (!widget.allowEdit) return false;
    return _amount != widget.entry.grams || _mealSlot != widget.entry.mealSlot;
  }

  Future<void> _save() async {
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter a valid amount in $_unit')),
      );
      return;
    }
    setState(() => _saving = true);
    final failure = await ref
        .read(dailyNutritionControllerProvider.notifier)
        .updateEntry(
          widget.entry.id,
          grams: _amount,
          mealSlot: _mealSlot,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    final totals = widget.entry.foodSnapshot.facts.forAmount(_amount);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final time = DateFormat('HH:mm').format(widget.entry.loggedAt.toLocal());
    final brand = (widget.entry.foodSnapshot.brand ?? '').trim();

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: colors.ghostBorder)),
        ),
        padding: EdgeInsets.fromLTRB(
          spacing.containerMarginMobile,
          spacing.stackSm,
          spacing.containerMarginMobile,
          spacing.stackLg,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: spacing.stackMd),
                  decoration: BoxDecoration(
                    color: colors.outlineVariant,
                    borderRadius: radius.pill,
                  ),
                ),
              ),
              Text(
                widget.entry.foodSnapshot.name,
                style: typography.titleMd,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (brand.isNotEmpty) ...[
                SizedBox(height: spacing.stackSm / 2),
                Text(
                  brand,
                  style: typography.bodyMd
                      .copyWith(color: colors.enduranceCyan),
                ),
              ],
              SizedBox(height: spacing.stackSm),
              Text(
                'Logged at $time',
                style: typography.labelMd
                    .copyWith(color: colors.onSurfaceVariant),
              ),
              SizedBox(height: spacing.stackLg),
              Text(
                'AMOUNT',
                style: typography.labelMd
                    .copyWith(color: colors.onSurfaceVariant),
              ),
              SizedBox(height: spacing.stackSm),
              if (widget.allowEdit)
                TextField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                  ],
                  style: typography.metricXl.copyWith(
                    color: colors.enduranceCyan,
                  ),
                  decoration: InputDecoration(
                    suffixText: _unit,
                    suffixStyle: typography.titleMd.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                )
              else
                _ReadOnlyField(
                  value: '${widget.entry.grams.round()} $_unit',
                ),
              SizedBox(height: spacing.stackLg),
              Text(
                'MEAL',
                style: typography.labelMd
                    .copyWith(color: colors.onSurfaceVariant),
              ),
              SizedBox(height: spacing.stackSm),
              if (widget.allowEdit)
                SegmentedChoice<MealSlot>(
                  value: _mealSlot,
                  onChanged: (v) => setState(() => _mealSlot = v),
                  options: [
                    for (final slot in MealSlot.values)
                      SegmentedChoiceOption(value: slot, label: slot.label),
                  ],
                )
              else
                _ReadOnlyField(value: widget.entry.mealSlot.label),
              SizedBox(height: spacing.stackLg),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.stackMd,
                  vertical: spacing.stackMd,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: radius.lgRadius,
                  border: Border.all(color: colors.ghostBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _Stat(
                        label: 'KCAL',
                        value: totals.kcal.round().toString(),
                        highlight: true,
                      ),
                    ),
                    Expanded(
                      child: _Stat(
                        label: 'PROTEIN',
                        value: '${totals.proteinGrams.round()}g',
                      ),
                    ),
                    Expanded(
                      child: _Stat(
                        label: 'CARBS',
                        value: '${totals.carbsGrams.round()}g',
                      ),
                    ),
                    Expanded(
                      child: _Stat(
                        label: 'FAT',
                        value: '${totals.fatGrams.round()}g',
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.allowEdit) ...[
                SizedBox(height: spacing.stackLg),
                PrimaryButton(
                  label: 'Save changes',
                  icon: Icons.check,
                  onPressed: _isDirty ? _save : null,
                  isLoading: _saving,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.stackMd,
        vertical: spacing.stackMd,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: radius.mdRadius,
        border: Border.all(color: colors.ghostBorder),
      ),
      child: Text(value, style: typography.bodyLg),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: typography.labelMd.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: 11,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: spacing.stackSm / 2),
        Text(
          value,
          style: typography.titleMd.copyWith(
            color: highlight ? colors.enduranceCyan : colors.onSurface,
          ),
        ),
      ],
    );
  }
}
