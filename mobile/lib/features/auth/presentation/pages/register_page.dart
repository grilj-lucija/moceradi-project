import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/auth/presentation/providers/auth_controller.dart';
import 'package:health_app/shared/widgets/buttons/ghost_button.dart';
import 'package:health_app/shared/widgets/buttons/primary_button.dart';
import 'package:health_app/shared/widgets/cards/glass_card.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorText;
  String? _pendingEmail;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _errorText = null;
      _pendingEmail = null;
    });

    final failure = await ref.read(authControllerProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    if (failure is EmailConfirmationPendingFailure) {
      setState(() => _pendingEmail = failure.email);
      return;
    }
    if (failure != null) {
      setState(() => _errorText = failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.spacing.stackLg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _pendingEmail == null
                  ? _RegisterForm(
                      formKey: _formKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                      errorText: _errorText,
                      isLoading: ref.watch(authControllerProvider).isLoading,
                      onSubmit: _submit,
                    )
                  : _EmailConfirmationCard(email: _pendingEmail!),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.errorText,
    required this.isLoading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String? errorText;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create account',
            style: typography.displayLg,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.stackSm),
          Text(
            'Start your endurance journey',
            style: typography.bodyLg.copyWith(color: colors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.sectionGap),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: const InputDecoration(hintText: 'Email'),
            validator: (v) =>
                (v == null || !v.contains('@')) ? 'Invalid email' : null,
          ),
          SizedBox(height: spacing.stackMd),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Password'),
            validator: (v) =>
                (v == null || v.length < 6) ? 'Min 6 characters' : null,
          ),
          SizedBox(height: spacing.stackMd),
          TextFormField(
            controller: confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Confirm password'),
            validator: (v) => v == passwordController.text
                ? null
                : 'Passwords do not match',
          ),
          if (errorText != null) ...[
            SizedBox(height: spacing.stackMd),
            Text(
              errorText!,
              style: typography.bodyMd.copyWith(color: colors.error),
              textAlign: TextAlign.center,
            ),
          ],
          SizedBox(height: spacing.stackLg),
          PrimaryButton(
            label: 'Create account',
            onPressed: onSubmit,
            isLoading: isLoading,
          ),
          SizedBox(height: spacing.stackMd),
          GhostButton(
            label: 'Back to sign in',
            onPressed: isLoading ? null : () => context.go(AppRoutes.login),
          ),
        ],
      ),
    );
  }
}

class _EmailConfirmationCard extends StatelessWidget {
  const _EmailConfirmationCard({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return GlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.mark_email_read_outlined,
            size: 48,
            color: colors.enduranceCyan,
          ),
          SizedBox(height: spacing.stackMd),
          Text(
            'Check your email',
            style: typography.titleMd,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.stackSm),
          Text(
            'We sent a confirmation link to $email. Open it to verify your account, then sign in.',
            style: typography.bodyMd.copyWith(color: colors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.stackLg),
          GhostButton(
            label: 'Back to sign in',
            onPressed: () => context.go(AppRoutes.login),
          ),
        ],
      ),
    );
  }
}
