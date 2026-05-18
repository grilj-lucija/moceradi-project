import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/features/onboarding/presentation/providers/onboarding_controller.dart';

class IdentityStep extends ConsumerStatefulWidget {
  const IdentityStep({
    required this.formKey,
    required this.autovalidateMode,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final AutovalidateMode autovalidateMode;

  @override
  ConsumerState<IdentityStep> createState() => _IdentityStepState();
}

class _IdentityStepState extends ConsumerState<IdentityStep>
    with AutomaticKeepAliveClientMixin {
  late final TextEditingController _displayNameController;
  late final TextEditingController _usernameController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(onboardingControllerProvider);
    _displayNameController =
        TextEditingController(text: initial.displayName);
    _usernameController = TextEditingController(text: initial.username);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Form(
      key: widget.formKey,
      autovalidateMode: widget.autovalidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Tell us about yourself', style: typography.headlineLgMobile),
          SizedBox(height: spacing.stackSm),
          Text(
            'We will use this to personalize your dashboard.',
            style: typography.bodyMd.copyWith(color: colors.onSurfaceVariant),
          ),
          SizedBox(height: spacing.sectionGap),
          _label(context, 'DISPLAY NAME'),
          SizedBox(height: spacing.stackSm),
          TextFormField(
            controller: _displayNameController,
            textCapitalization: TextCapitalization.words,
            onChanged: controller.setDisplayName,
            decoration: const InputDecoration(hintText: 'e.g. Timotej K.'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          SizedBox(height: spacing.stackLg),
          _label(context, 'USERNAME'),
          SizedBox(height: spacing.stackSm),
          TextFormField(
            controller: _usernameController,
            autocorrect: false,
            onChanged: controller.setUsername,
            decoration: const InputDecoration(
              hintText: 'pick a unique handle',
              prefixText: '@ ',
            ),
            validator: (v) {
              final value = (v ?? '').trim();
              if (value.length < 3) return 'Min 3 characters';
              if (!RegExp(r'^[a-z0-9_]+$').hasMatch(value)) {
                return 'Lowercase letters, numbers, underscore only';
              }
              return null;
            },
          ),
          SizedBox(height: spacing.stackSm),
          Text(
            'Your username must be unique across all athletes.',
            style: typography.labelMd.copyWith(
              color: colors.onSurfaceVariant,
              letterSpacing: 0.2,
            ),
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
