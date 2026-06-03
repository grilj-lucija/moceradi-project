import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/data/models/food.dart';
import 'package:health_app/data/models/nutrition_facts.dart';
import 'package:health_app/shared/widgets/buttons/ghost_button.dart';
import 'package:image_picker/image_picker.dart';

class PhotoCapturePage extends ConsumerStatefulWidget {
  const PhotoCapturePage({super.key});

  @override
  ConsumerState<PhotoCapturePage> createState() => _PhotoCapturePageState();
}

class _PhotoCapturePageState extends ConsumerState<PhotoCapturePage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _captured;
  bool _analyzing = false;
  bool _launched = false;

  static const _hardcodedResult = Food(
    id: 'photo-ai:grilled-chicken-bowl',
    name: 'Grilled chicken bowl',
    source: FoodSourceKind.custom,
    defaultServingGrams: 350,
    facts: NutritionFacts(
      kcalPer100g: 154,
      proteinPer100g: 11,
      carbsPer100g: 13,
      fatPer100g: 5,
    ),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _capture());
  }

  Future<void> _capture() async {
    if (_launched) return;
    _launched = true;
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (!mounted) return;
      if (file == null) {
        context.pop();
        return;
      }
      setState(() {
        _captured = file;
        _analyzing = true;
      });
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      context.pushReplacement(
        AppRoutes.nutritionEntry,
        extra: _hardcodedResult,
      );
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera unavailable: $e')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final captured = _captured;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Photo AI'),
        leading: const BackButton(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (captured != null)
            Image.file(File(captured.path), fit: BoxFit.cover)
          else
            const ColoredBox(color: Colors.black),
          if (_analyzing)
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.55),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(spacing.stackLg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          color: colors.enduranceCyan,
                        ),
                      ),
                      SizedBox(height: spacing.stackLg),
                      Text(
                        'Analyzing your meal…',
                        style: typography.titleMd.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: spacing.stackSm),
                      Text(
                        'Detecting ingredients and estimating calories',
                        style: typography.bodyMd.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.all(spacing.stackLg),
                  child: GhostButton(
                    label: 'Retake photo',
                    icon: Icons.camera_alt_outlined,
                    onPressed: _capture,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
