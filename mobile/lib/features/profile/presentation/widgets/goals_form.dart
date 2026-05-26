import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/data/models/user_goals.dart';
import 'package:health_app/shared/widgets/inputs/multi_choice_chips.dart';

class GoalsForm extends StatefulWidget {
  const GoalsForm({
    required this.formKey,
    required this.autovalidateMode,
    required this.intents,
    required this.targetWeightKg,
    required this.currentWeightKg,
    required this.activityMetric,
    required this.activityTarget,
    required this.onToggleIntent,
    required this.onTargetWeightChanged,
    required this.onActivityMetricChanged,
    required this.onActivityTargetChanged,
    this.showHeader = true,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final AutovalidateMode autovalidateMode;
  final Set<GoalType> intents;
  final double? targetWeightKg;
  final double? currentWeightKg;
  final ActivityMetric? activityMetric;
  final double? activityTarget;
  final ValueChanged<GoalType> onToggleIntent;
  final ValueChanged<double?> onTargetWeightChanged;
  final ValueChanged<ActivityMetric> onActivityMetricChanged;
  final ValueChanged<double?> onActivityTargetChanged;
  final bool showHeader;

  @override
  State<GoalsForm> createState() => _GoalsFormState();
}

class _GoalsFormState extends State<GoalsForm>
    with AutomaticKeepAliveClientMixin {
  late final TextEditingController _targetWeightController;
  late final TextEditingController _activityTargetController;
  ActivityMetric? _lastMetric;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _targetWeightController = TextEditingController(
      text: widget.targetWeightKg == null
          ? ''
          : widget.targetWeightKg!.toStringAsFixed(0),
    );
    _activityTargetController = TextEditingController(
      text: _formatTarget(widget.activityTarget, widget.activityMetric),
    );
    _lastMetric = widget.activityMetric;
  }

  @override
  void didUpdateWidget(covariant GoalsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activityMetric != widget.activityMetric ||
        oldWidget.activityTarget != widget.activityTarget) {
      final externalChange = _lastMetric != widget.activityMetric;
      _lastMetric = widget.activityMetric;
      final text = _formatTarget(widget.activityTarget, widget.activityMetric);
      if (externalChange || _activityTargetController.text != text) {
        _activityTargetController.text = text;
      }
    }
  }

  @override
  void dispose() {
    _targetWeightController.dispose();
    _activityTargetController.dispose();
    super.dispose();
  }

  String _formatTarget(double? value, ActivityMetric? metric) {
    if (value == null) return '';
    if (metric?.isInteger ?? true) return value.toStringAsFixed(0);
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    final current = widget.currentWeightKg;
    final target = widget.targetWeightKg;
    final delta = (current != null && target != null)
        ? (target - current)
        : null;

    return Form(
      key: widget.formKey,
      autovalidateMode: widget.autovalidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showHeader) ...[
            Text(
              'Set your goals',
              style: typography.headlineLgMobile,
            ),
            SizedBox(height: spacing.stackSm),
            Text(
              'Pick what matters, set a target weight, and choose one weekly activity goal.',
              style: typography.bodyMd.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: spacing.sectionGap),
          ],
          _label(context, 'YOUR INTENTS'),
          SizedBox(height: spacing.stackSm),
          FormField<Set<GoalType>>(
            initialValue: widget.intents,
            validator: (_) =>
                widget.intents.isEmpty ? 'Pick at least one' : null,
            builder: (field) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MultiChoiceChips<GoalType>(
                  values: widget.intents,
                  onChanged: (value) {
                    widget.onToggleIntent(value);
                    field.didChange({...widget.intents}..add(value));
                  },
                  options: [
                    for (final goal in GoalType.values)
                      MultiChoiceChipOption<GoalType>(
                        value: goal,
                        label: goal.label,
                        icon: goal.icon,
                      ),
                  ],
                ),
                if (field.hasError) ...[
                  SizedBox(height: spacing.stackSm),
                  Text(
                    field.errorText!,
                    style: typography.labelMd.copyWith(color: colors.error),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: spacing.stackLg),
          _label(context, 'TARGET WEIGHT (KG)'),
          SizedBox(height: spacing.stackSm),
          TextFormField(
            controller: _targetWeightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
            ],
            decoration: InputDecoration(
              hintText: current == null
                  ? 'Optional'
                  : 'e.g. ${current.toStringAsFixed(0)}',
            ),
            onChanged: (v) {
              if (v.isEmpty) {
                widget.onTargetWeightChanged(null);
                return;
              }
              final parsed = double.tryParse(v);
              if (parsed != null) widget.onTargetWeightChanged(parsed);
            },
            validator: (v) {
              if (v == null || v.isEmpty) return null;
              final parsed = double.tryParse(v);
              if (parsed == null || parsed <= 20 || parsed >= 400) {
                return 'Enter kg';
              }
              return null;
            },
          ),
          if (delta != null && delta.abs() >= 0.1) ...[
            SizedBox(height: spacing.stackSm),
            Text(
              delta < 0
                  ? 'You want to lose ${(-delta).toStringAsFixed(1)} kg.'
                  : 'You want to gain ${delta.toStringAsFixed(1)} kg.',
              style: typography.labelMd.copyWith(
                color: colors.enduranceCyan,
              ),
            ),
          ],
          SizedBox(height: spacing.stackLg),
          _label(context, 'PRIMARY WEEKLY ACTIVITY GOAL'),
          SizedBox(height: spacing.stackSm),
          FormField<ActivityMetric>(
            initialValue: widget.activityMetric,
            validator: (_) =>
                widget.activityMetric == null ? 'Pick a metric' : null,
            builder: (field) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: spacing.gutter / 2,
                  runSpacing: spacing.gutter / 2,
                  children: [
                    for (final metric in ActivityMetric.values)
                      _MetricPill(
                        metric: metric,
                        selected: widget.activityMetric == metric,
                        onTap: () {
                          widget.onActivityMetricChanged(metric);
                          field.didChange(metric);
                        },
                      ),
                  ],
                ),
                if (field.hasError) ...[
                  SizedBox(height: spacing.stackSm),
                  Text(
                    field.errorText!,
                    style: typography.labelMd.copyWith(color: colors.error),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: spacing.stackMd),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label(
                      context,
                      widget.activityMetric == null
                          ? 'TARGET'
                          : 'TARGET (${widget.activityMetric!.unitPerWeek.toUpperCase()})',
                    ),
                    SizedBox(height: spacing.stackSm),
                    FormField<double>(
                      initialValue: widget.activityTarget,
                      validator: (_) {
                        if (widget.activityMetric == null) return null;
                        final t = widget.activityTarget;
                        if (t == null || t <= 0) return 'Set a target';
                        return null;
                      },
                      builder: (field) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _activityTargetController,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal:
                                  !(widget.activityMetric?.isInteger ?? true),
                            ),
                            inputFormatters: [
                              if (widget.activityMetric?.isInteger ?? true)
                                FilteringTextInputFormatter.digitsOnly
                              else
                                FilteringTextInputFormatter.allow(
                                  RegExp('[0-9.]'),
                                ),
                            ],
                            decoration: InputDecoration(
                              hintText: widget.activityMetric == null
                                  ? '—'
                                  : widget.activityMetric!.defaultTarget
                                      .toStringAsFixed(0),
                            ),
                            enabled: widget.activityMetric != null,
                            onChanged: (v) {
                              if (v.isEmpty) {
                                widget.onActivityTargetChanged(null);
                                field.didChange(null);
                                return;
                              }
                              final parsed = double.tryParse(v);
                              if (parsed != null) {
                                widget.onActivityTargetChanged(parsed);
                                field.didChange(parsed);
                              }
                            },
                          ),
                          if (field.hasError) ...[
                            SizedBox(height: spacing.stackSm),
                            Text(
                              field.errorText!,
                              style: typography.labelMd.copyWith(
                                color: colors.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Text(
        text,
        style: context.typography.labelMd.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      );
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.metric,
    required this.selected,
    required this.onTap,
  });

  final ActivityMetric metric;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;

    final borderColor = selected ? colors.enduranceCyan : colors.ghostBorder;
    final fillColor = selected
        ? colors.enduranceCyan.withValues(alpha: 0.12)
        : colors.surfaceContainerLow;
    final iconColor = selected ? colors.enduranceCyan : colors.onSurfaceVariant;
    final labelColor = selected ? colors.onSurface : colors.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      borderRadius: radius.pill,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius.pill,
        child: Ink(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: radius.pill,
            border: Border.all(
              color: borderColor,
              width: selected ? 1.5 : 1,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: spacing.stackMd,
            vertical: spacing.stackSm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(metric.icon, size: 18, color: iconColor),
              SizedBox(width: spacing.stackSm),
              Text(
                metric.shortLabel,
                style: typography.bodyMd.copyWith(color: labelColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
