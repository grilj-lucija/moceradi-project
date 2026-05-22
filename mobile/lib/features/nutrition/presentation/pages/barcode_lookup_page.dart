import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/di/providers.dart';
import 'package:health_app/shared/widgets/buttons/ghost_button.dart';
import 'package:health_app/shared/widgets/buttons/primary_button.dart';

class BarcodeLookupPage extends ConsumerStatefulWidget {
  const BarcodeLookupPage({required this.barcode, super.key});

  final String barcode;

  @override
  ConsumerState<BarcodeLookupPage> createState() => _BarcodeLookupPageState();
}

class _BarcodeLookupPageState extends ConsumerState<BarcodeLookupPage> {
  bool _loading = true;
  Failure? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_lookup());
  }

  Future<void> _lookup() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result =
        await ref.read(foodsRepositoryProvider).getByBarcode(widget.barcode);
    if (!mounted) return;
    result.fold(
      ok: (food) {
        context.pushReplacement(AppRoutes.nutritionEntry, extra: food);
      },
      err: (failure) {
        setState(() {
          _loading = false;
          _error = failure;
        });
      },
    );
  }

  void _addManually() {
    context.pushReplacement(AppRoutes.nutritionCustom);
  }

  void _retryScan() {
    context.pushReplacement(AppRoutes.nutritionScan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan barcode')),
      body: SafeArea(
        child: _loading ? _LoadingView(barcode: widget.barcode) : _buildError(),
      ),
    );
  }

  Widget _buildError() {
    return _ErrorView(
      barcode: widget.barcode,
      failure: _error!,
      onRetry: _retryScan,
      onAddManually: _addManually,
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.barcode});

  final String barcode;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.containerMarginMobile),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: colors.enduranceCyan),
            SizedBox(height: spacing.stackLg),
            Text(
              'Looking up product…',
              style: typography.titleMd,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.stackSm),
            Text(
              barcode,
              style: typography.bodyMd
                  .copyWith(color: colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.barcode,
    required this.failure,
    required this.onRetry,
    required this.onAddManually,
  });

  final String barcode;
  final Failure failure;
  final VoidCallback onRetry;
  final VoidCallback onAddManually;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        spacing.containerMarginMobile,
        spacing.stackLg,
        spacing.containerMarginMobile,
        spacing.stackLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh,
                      borderRadius: radius.xlRadius,
                      border: Border.all(color: colors.ghostBorder),
                    ),
                    child: Icon(
                      Icons.search_off,
                      color: colors.onSurfaceVariant,
                      size: 36,
                    ),
                  ),
                  SizedBox(height: spacing.stackLg),
                  Text(
                    failure is NotFoundFailure
                        ? "We couldn't find that product"
                        : 'Something went wrong',
                    style: typography.titleMd,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: spacing.stackSm),
                  Text(
                    'Barcode $barcode',
                    style: typography.bodyMd
                        .copyWith(color: colors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          PrimaryButton(
            label: 'Try again',
            icon: Icons.qr_code_scanner,
            onPressed: onRetry,
          ),
          SizedBox(height: spacing.stackSm),
          GhostButton(
            label: 'Add it manually',
            icon: Icons.edit_note,
            onPressed: onAddManually,
          ),
        ],
      ),
    );
  }
}
