import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/features/onboarding/presentation/providers/onboarding_controller.dart';
import 'package:health_app/features/profile/presentation/widgets/nutrition_plan_panel.dart';

class NutritionPlanStep extends ConsumerStatefulWidget {
  const NutritionPlanStep({
    required this.formKey,
    required this.autovalidateMode,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final AutovalidateMode autovalidateMode;

  @override
  ConsumerState<NutritionPlanStep> createState() => _NutritionPlanStepState();
}

class _NutritionPlanStepState extends ConsumerState<NutritionPlanStep>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final typography = context.typography;
    final colors = context.colors;
    final spacing = context.spacing;

    return Form(
      key: widget.formKey,
      autovalidateMode: widget.autovalidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Your daily plan', style: typography.headlineLgMobile),
          SizedBox(height: spacing.stackSm),
          Text(
            'Based on your body and target. Pick a pace; the kcal updates live.',
            style: typography.bodyMd.copyWith(color: colors.onSurfaceVariant),
          ),
          SizedBox(height: spacing.sectionGap),
          NutritionPlanPanel(
            plan: state.caloriePlan,
            pace: state.pace,
            effectiveKcal: state.effectiveKcal,
            kcalOverride: state.kcalOverride,
            projectedWeeks: state.projectedWeeksAtEffectiveKcal,
            onPaceChanged: controller.setPace,
            onKcalOverrideChanged: controller.setKcalOverride,
          ),
        ],
      ),
    );
  }
}
