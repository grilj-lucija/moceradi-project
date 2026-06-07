import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/features/auth/presentation/providers/auth_controller.dart';
import 'package:health_app/shared/widgets/buttons/ghost_button.dart';
import 'package:health_app/shared/widgets/buttons/primary_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _errorText = null);

    final failure = await ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (failure != null && mounted) {
      setState(() => _errorText = failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(spacing.stackLg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Health App',
                      style: typography.displayLg,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: spacing.stackSm),
                    Text(
                      'Track your endurance journey',
                      style: typography.bodyLg.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: spacing.sectionGap),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(hintText: 'Email'),
                      validator: (v) =>
                          (v == null || !v.contains('@')) ? 'Invalid email' : null,
                    ),
                    SizedBox(height: spacing.stackMd),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: 'Password'),
                      validator: (v) =>
                          (v == null || v.length < 6) ? 'Min 6 characters' : null,
                    ),
                    if (_errorText != null) ...[
                      SizedBox(height: spacing.stackMd),
                      Text(
                        _errorText!,
                        style: typography.bodyMd.copyWith(color: colors.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    SizedBox(height: spacing.stackLg),
                    PrimaryButton(
                      label: 'Sign in',
                      onPressed: _submit,
                      isLoading: isLoading,
                    ),
                    SizedBox(height: spacing.stackMd),
                    GhostButton(
                      label: 'Create account',
                      onPressed: isLoading
                          ? null
                          : () => context.push(AppRoutes.register),
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
