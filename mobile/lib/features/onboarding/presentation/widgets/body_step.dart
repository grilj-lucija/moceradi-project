import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/data/models/profile.dart';
import 'package:health_app/features/onboarding/presentation/providers/onboarding_controller.dart';
import 'package:health_app/shared/widgets/inputs/segmented_choice.dart';
import 'package:intl/intl.dart';

class BodyStep extends ConsumerStatefulWidget {
  const BodyStep({
    required this.formKey,
    required this.autovalidateMode,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final AutovalidateMode autovalidateMode;

  @override
  ConsumerState<BodyStep> createState() => _BodyStepState();
}

class _BodyStepState extends ConsumerState<BodyStep>
    with AutomaticKeepAliveClientMixin {
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(onboardingControllerProvider);
    _heightController = TextEditingController(
      text: initial.heightCm?.toStringAsFixed(0) ?? '',
    );
    _weightController = TextEditingController(
      text: initial.weightKg?.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final form = ref.read(onboardingControllerProvider);
    final now = DateTime.now();
    final initial = form.dateOfBirth ?? DateTime(now.year - 25);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select date of birth',
    );
    if (picked != null) {
      ref.read(onboardingControllerProvider.notifier).setDateOfBirth(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Form(
      key: widget.formKey,
      autovalidateMode: widget.autovalidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('A few body metrics', style: typography.headlineLgMobile),
          SizedBox(height: spacing.stackSm),
          Text(
            'Used to calibrate pace, calories and performance zones.',
            style: typography.bodyMd.copyWith(color: colors.onSurfaceVariant),
          ),
          SizedBox(height: spacing.sectionGap),
          _label(context, 'GENDER'),
          SizedBox(height: spacing.stackSm),
          SegmentedChoice<Gender>(
            value: state.gender,
            onChanged: controller.setGender,
            options: const [
              SegmentedChoiceOption(
                value: Gender.male,
                label: 'Male',
                icon: Icons.male,
              ),
              SegmentedChoiceOption(
                value: Gender.female,
                label: 'Female',
                icon: Icons.female,
              ),
              SegmentedChoiceOption(
                value: Gender.other,
                label: 'Other',
                icon: Icons.transgender,
              ),
            ],
          ),
          SizedBox(height: spacing.stackLg),
          _label(context, 'DATE OF BIRTH'),
          SizedBox(height: spacing.stackSm),
          InkWell(
            onTap: _pickDateOfBirth,
            borderRadius: radius.baseRadius,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: radius.baseRadius,
                border: Border.all(color: colors.ghostBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.cake_outlined, color: colors.onSurfaceVariant),
                  SizedBox(width: spacing.stackMd),
                  Expanded(
                    child: Text(
                      state.dateOfBirth == null
                          ? 'Select a date'
                          : DateFormat.yMMMMd().format(state.dateOfBirth!),
                      style: typography.bodyMd.copyWith(
                        color: state.dateOfBirth == null
                            ? colors.onSurfaceVariant
                            : colors.onSurface,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
                ],
              ),
            ),
          ),
          SizedBox(height: spacing.stackLg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label(context, 'HEIGHT (CM)'),
                    SizedBox(height: spacing.stackSm),
                    TextFormField(
                      controller: _heightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp('[0-9.]'),
                        ),
                      ],
                      decoration: const InputDecoration(hintText: '180'),
                      onChanged: (v) {
                        final parsed = double.tryParse(v);
                        if (parsed != null) controller.setHeight(parsed);
                      },
                      validator: (v) {
                        final parsed = double.tryParse(v ?? '');
                        if (parsed == null || parsed <= 0 || parsed >= 300) {
                          return 'Enter cm';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: spacing.gutter),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label(context, 'WEIGHT (KG)'),
                    SizedBox(height: spacing.stackSm),
                    TextFormField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp('[0-9.]'),
                        ),
                      ],
                      decoration: const InputDecoration(hintText: '72'),
                      onChanged: (v) {
                        final parsed = double.tryParse(v);
                        if (parsed != null) controller.setWeight(parsed);
                      },
                      validator: (v) {
                        final parsed = double.tryParse(v ?? '');
                        if (parsed == null || parsed <= 0 || parsed >= 500) {
                          return 'Enter kg';
                        }
                        return null;
                      },
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
