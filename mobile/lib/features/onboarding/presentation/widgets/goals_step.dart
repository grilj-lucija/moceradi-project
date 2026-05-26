import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/features/onboarding/presentation/providers/onboarding_controller.dart';
import 'package:health_app/features/profile/presentation/widgets/goals_form.dart';

class GoalsStep extends ConsumerWidget {
  const GoalsStep({
    required this.formKey,
    required this.autovalidateMode,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final AutovalidateMode autovalidateMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return GoalsForm(
      formKey: formKey,
      autovalidateMode: autovalidateMode,
      intents: state.intents,
      targetWeightKg: state.targetWeightKg,
      currentWeightKg: state.weightKg,
      activityMetric: state.activityMetric,
      activityTarget: state.activityTarget,
      onToggleIntent: controller.toggleIntent,
      onTargetWeightChanged: controller.setTargetWeight,
      onActivityMetricChanged: controller.setActivityMetric,
      onActivityTargetChanged: controller.setActivityTarget,
    );
  }
}
