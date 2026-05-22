import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/shared/widgets/buttons/ghost_button.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanPage extends ConsumerStatefulWidget {
  const BarcodeScanPage({super.key});

  @override
  ConsumerState<BarcodeScanPage> createState() => _BarcodeScanPageState();
}

class _BarcodeScanPageState extends ConsumerState<BarcodeScanPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handling = false;

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling) return;
    final raw = capture.barcodes
        .map((b) => b.rawValue)
        .firstWhere((v) => v != null && v.isNotEmpty, orElse: () => null);
    if (raw == null || raw.isEmpty) return;

    setState(() => _handling = true);
    await _controller.stop();
    if (!mounted) return;
    context.pushReplacement(AppRoutes.nutritionScanLookup, extra: raw);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Scan barcode'),
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => unawaited(_controller.toggleTorch()),
            icon: const Icon(Icons.flash_on_outlined, color: Colors.white),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 260,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: radius.xlRadius,
                  border: Border.all(color: colors.enduranceCyan, width: 2),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.all(spacing.stackLg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_handling)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: CircularProgressIndicator(),
                      ),
                    Text(
                      _handling
                          ? 'Looking up product…'
                          : 'Align the barcode within the frame',
                      style: typography.bodyMd.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: spacing.stackMd),
                    GhostButton(
                      label: 'Enter manually',
                      icon: Icons.edit_note,
                      onPressed: () =>
                          context.pushReplacement(AppRoutes.nutritionCustom),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
