import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/features/onboarding/presentation/providers/onboarding_controller.dart';
import 'package:health_app/features/onboarding/presentation/widgets/body_step.dart';
import 'package:health_app/features/onboarding/presentation/widgets/identity_step.dart';
import 'package:health_app/shared/widgets/buttons/primary_button.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  static const _totalSteps = 2;

  final _pageController = PageController();
  final _identityFormKey = GlobalKey<FormState>();
  final _bodyFormKey = GlobalKey<FormState>();
  int _currentStep = 0;
  String? _errorText;
  bool _identityAttempted = false;
  bool _bodyAttempted = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorText = null);
    if (_currentStep == 0) {
      setState(() => _identityAttempted = true);
      if (!_identityFormKey.currentState!.validate()) return;
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      setState(() => _bodyAttempted = true);
      final formOk = _bodyFormKey.currentState!.validate();
      final form = ref.read(onboardingControllerProvider);
      final extrasOk = form.gender != null && form.dateOfBirth != null;
      if (!formOk || !extrasOk) {
        setState(() => _errorText = 'Please complete every field.');
        return;
      }
      final failure =
          await ref.read(onboardingControllerProvider.notifier).submit();
      if (!mounted) return;
      if (failure != null) {
        setState(() => _errorText = failure.message);
      }
    }
  }

  Future<void> _back() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorText = null);
    if (_currentStep == 0) return;
    await _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final state = ref.watch(onboardingControllerProvider);
    final isLast = _currentStep == _totalSteps - 1;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.containerMarginMobile,
                  vertical: spacing.stackLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(
                      currentStep: _currentStep,
                      totalSteps: _totalSteps,
                      onBack: _currentStep == 0 ? null : _back,
                    ),
                    SizedBox(height: spacing.stackLg),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (i) => setState(() => _currentStep = i),
                        children: [
                          SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: EdgeInsets.only(
                              bottom: spacing.sectionGap,
                            ),
                            child: IdentityStep(
                              formKey: _identityFormKey,
                              autovalidateMode: _identityAttempted
                                  ? AutovalidateMode.onUserInteraction
                                  : AutovalidateMode.disabled,
                            ),
                          ),
                          SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: EdgeInsets.only(
                              bottom: spacing.sectionGap,
                            ),
                            child: BodyStep(
                              formKey: _bodyFormKey,
                              autovalidateMode: _bodyAttempted
                                  ? AutovalidateMode.onUserInteraction
                                  : AutovalidateMode.disabled,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_errorText != null) ...[
                      Text(
                        _errorText!,
                        style: typography.bodyMd.copyWith(color: colors.error),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: spacing.stackMd),
                    ],
                    PrimaryButton(
                      label: isLast ? 'Finish' : 'Continue',
                      onPressed: state.isSubmitting ? null : _next,
                      icon: isLast ? null : Icons.arrow_forward,
                      isLoading: state.isSubmitting,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
  });

  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final progress = (currentStep + 1) / totalSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 40,
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: onBack == null
                    ? null
                    : IconButton(
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back),
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
              ),
              Expanded(
                child: Text(
                  'PULSE',
                  style: typography.titleMd.copyWith(
                    color: colors.enduranceCyan,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 40, height: 40),
            ],
          ),
        ),
        SizedBox(height: spacing.stackMd),
        ClipRRect(
          borderRadius: radius.pill,
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: colors.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation(colors.enduranceCyan),
          ),
        ),
        SizedBox(height: spacing.stackSm),
        Text(
          'Step ${currentStep + 1} of $totalSteps',
          style: typography.labelMd.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}
