import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/data/models/profile.dart';
import 'package:health_app/shared/widgets/cards/glass_card.dart';

class WeightProgressCard extends ConsumerWidget {
  const WeightProgressCard({required this.profile, super.key});

  final Profile? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    final current = profile?.weightKg;
    final target = profile?.targetWeightKg;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.monitor_weight_outlined,
                size: 18,
                color: colors.enduranceCyan,
              ),
              SizedBox(width: spacing.stackSm),
              Text(
                'WEIGHT',
                style: typography.labelMd.copyWith(
                  color: colors.onSurfaceVariant,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.stackLg),
          if (current == null)
            Row(
              children: [
                Icon(
                  Icons.scale_outlined,
                  color: colors.onSurfaceVariant,
                ),
                SizedBox(width: spacing.stackMd),
                Expanded(
                  child: Text(
                    'Add your weight to start tracking progress.',
                    style: typography.bodyMd.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            )
          else
            _Body(current: current, target: target),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.current, required this.target});

  final double current;
  final double? target;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    if (target == null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const _WeightStack(
            label: 'CURRENT',
            value: '',
            unit: 'kg',
            highlight: true,
          ),
          SizedBox(width: spacing.stackMd),
          Expanded(
            child: Text(
              'Set a target weight to track progress.',
              style: typography.bodyMd.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      );
    }

    final t = target!;
    final delta = t - current;
    final atTarget = delta.abs() < 0.1;
    final isLoss = delta < 0;
    final progress = _progressTowardTarget(current, t);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _WeightStack(
              label: 'CURRENT',
              value: current.toStringAsFixed(1),
              unit: 'kg',
              highlight: true,
            ),
            const Spacer(),
            _DeltaPill(delta: delta, atTarget: atTarget),
            const Spacer(),
            _WeightStack(
              label: 'TARGET',
              value: t.toStringAsFixed(1),
              unit: 'kg',
              alignment: CrossAxisAlignment.end,
            ),
          ],
        ),
        SizedBox(height: spacing.stackMd),
        ClipRRect(
          borderRadius: radius.pill,
          child: Stack(
            children: [
              Container(
                height: 8,
                color: colors.surfaceContainerHigh,
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.velocityBlue,
                        colors.enduranceCyan,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.stackSm),
        Row(
          children: [
            Icon(
              atTarget
                  ? Icons.check_circle_outline
                  : (isLoss ? Icons.trending_down : Icons.trending_up),
              size: 14,
              color: colors.onSurfaceVariant,
            ),
            SizedBox(width: spacing.stackSm / 2),
            Text(
              atTarget
                  ? 'On target'
                  : '${delta.abs().toStringAsFixed(1)} kg ${isLoss ? 'to lose' : 'to gain'}',
              style: typography.labelMd.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              '${(progress * 100).round()}% there',
              style: typography.labelMd.copyWith(
                color: colors.enduranceCyan,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _progressTowardTarget(double current, double target) {
    if ((current - target).abs() < 0.1) return 1;
    final distance = (target - current).abs();
    const milestone = 10.0;
    final clamped = distance.clamp(0.0, milestone) / milestone;
    return (1 - clamped).clamp(0.0, 1.0);
  }
}

class _WeightStack extends StatelessWidget {
  const _WeightStack({
    required this.label,
    required this.value,
    required this.unit,
    this.highlight = false,
    this.alignment = CrossAxisAlignment.start,
  });

  final String label;
  final String value;
  final String unit;
  final bool highlight;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    final valueColor = highlight ? colors.enduranceCyan : colors.onSurface;

    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: typography.labelMd.copyWith(
            color: colors.onSurfaceVariant,
            letterSpacing: 2,
            fontSize: 11,
          ),
        ),
        SizedBox(height: spacing.stackSm / 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: typography.metricXl.copyWith(
                color: valueColor,
                fontSize: 32,
                height: 1,
              ),
            ),
            SizedBox(width: spacing.stackSm / 2),
            Text(
              unit,
              style: typography.bodyMd.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DeltaPill extends StatelessWidget {
  const _DeltaPill({required this.delta, required this.atTarget});

  final double delta;
  final bool atTarget;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    final isLoss = delta < 0;
    final icon = atTarget
        ? Icons.check_circle_outline
        : (isLoss ? Icons.south : Icons.north);
    final label = atTarget
        ? 'On target'
        : '${delta.abs().toStringAsFixed(1)} kg';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.stackSm,
        vertical: spacing.stackSm / 2,
      ),
      decoration: BoxDecoration(
        color: colors.enduranceCyan.withValues(alpha: 0.1),
        borderRadius: radius.pill,
        border: Border.all(
          color: colors.enduranceCyan.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.enduranceCyan),
          SizedBox(width: spacing.stackSm / 2),
          Text(
            label,
            style: typography.labelMd.copyWith(
              color: colors.enduranceCyan,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
