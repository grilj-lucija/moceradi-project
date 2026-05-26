import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/features/auth/presentation/providers/profile_provider.dart';
import 'package:health_app/features/weight/presentation/providers/weight_controller.dart';
import 'package:health_app/shared/widgets/buttons/primary_button.dart';

class LogWeightSheet extends ConsumerStatefulWidget {
  const LogWeightSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LogWeightSheet(),
    );
  }

  @override
  ConsumerState<LogWeightSheet> createState() => _LogWeightSheetState();
}

class _LogWeightSheetState extends ConsumerState<LogWeightSheet> {
  late final TextEditingController _controller;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(currentProfileProvider).value;
    final weight = profile?.weightKg;
    _controller = TextEditingController(
      text: weight == null ? '' : weight.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? _parsed() {
    final raw = _controller.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  Future<void> _save() async {
    final value = _parsed();
    if (value == null) {
      setState(() => _error = 'Enter a valid number');
      return;
    }
    if (value < 20 || value > 500) {
      setState(() => _error = 'Weight must be between 20 and 500 kg');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final failure =
        await ref.read(weightControllerProvider.notifier).log(value);
    if (!mounted) return;
    setState(() => _saving = false);
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Weight logged for this week')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: colors.ghostBorder)),
        ),
        padding: EdgeInsets.fromLTRB(
          spacing.containerMarginMobile,
          spacing.stackSm,
          spacing.containerMarginMobile,
          spacing.stackLg,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: spacing.stackMd),
                  decoration: BoxDecoration(
                    color: colors.outlineVariant,
                    borderRadius: radius.pill,
                  ),
                ),
              ),
              Text("Log this week's weight", style: typography.titleMd),
              SizedBox(height: spacing.stackSm / 2),
              Text(
                'Weigh yourself first thing in the morning for the most consistent reading.',
                style:
                    typography.bodyMd.copyWith(color: colors.onSurfaceVariant),
              ),
              SizedBox(height: spacing.stackLg),
              TextField(
                controller: _controller,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                ],
                style: typography.headlineLgMobile,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  suffixText: 'kg',
                  suffixStyle: typography.titleMd.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                onSubmitted: (_) => unawaited(_save()),
              ),
              if (_error != null) ...[
                SizedBox(height: spacing.stackSm),
                Text(
                  _error!,
                  style: typography.bodyMd.copyWith(color: colors.error),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: spacing.stackLg),
              PrimaryButton(
                label: 'Save',
                isLoading: _saving,
                onPressed: _saving ? null : () => unawaited(_save()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
