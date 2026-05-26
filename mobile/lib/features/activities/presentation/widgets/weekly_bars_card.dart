import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/features/dashboard/presentation/providers/dashboard_controller.dart';
import 'package:health_app/shared/widgets/cards/glass_card.dart';

class WeeklyBarsCard extends ConsumerWidget {
  const WeeklyBarsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final values = ref.watch(weeklyCaloriesPerDayProvider);
    return GlassCard(child: _Body(values: values));
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.values});

  final List<double> values;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _minScaleMax = 200.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    final todayIdx = DateTime.now().weekday - 1;
    final maxValue = values.fold<double>(0, (m, v) => v > m ? v : m);
    final scaleMax =
        (maxValue < _minScaleMax ? _minScaleMax : maxValue) * 1.15;
    final total = values.fold<double>(0, (s, v) => s + v).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.local_fire_department_outlined,
              size: 16,
              color: colors.enduranceCyan,
            ),
            SizedBox(width: spacing.stackSm),
            Expanded(
              child: Text(
                'CALORIES BURNED',
                style: typography.labelMd.copyWith(
                  color: colors.onSurfaceVariant,
                  letterSpacing: 2,
                ),
              ),
            ),
            Text(
              '$total kcal',
              style: typography.labelMd.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.stackLg),
        SizedBox(
          height: 96,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _Bar(
                      value: values[i],
                      max: scaleMax,
                      isToday: i == todayIdx,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: spacing.stackSm),
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Text(
                    _dayLabels[i],
                    style: typography.labelMd.copyWith(
                      color: i == todayIdx
                          ? colors.enduranceCyan
                          : colors.onSurfaceVariant,
                      fontWeight:
                          i == todayIdx ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.value,
    required this.max,
    required this.isToday,
  });

  final double value;
  final double max;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fraction = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);

    final activeColor = isToday
        ? colors.enduranceCyan
        : colors.enduranceCyan.withValues(alpha: 0.45);
    final trackColor = colors.surfaceContainerHigh.withValues(alpha: 0.6);

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final barTop = h - (h * fraction);
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: const BorderRadius.all(Radius.circular(6)),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: barTop,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
