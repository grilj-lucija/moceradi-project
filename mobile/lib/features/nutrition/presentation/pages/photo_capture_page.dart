import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/di/providers.dart';
import 'package:health_app/shared/widgets/buttons/ghost_button.dart';
import 'package:health_app/shared/widgets/buttons/primary_button.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _pick(ImageSource.camera));
  }

  Future<void> _pick(ImageSource source) async {
    if (_analyzing) return;
    if (source == ImageSource.camera) _launched = true;
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (!mounted || file == null) return;
      setState(() {
        _captured = file;
        _analyzing = true;
      });
      await _analyze(file);
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _analyzing = false);
      _showError('Could not open image source: $e');
    }
  }

  Future<void> _analyze(XFile file) async {
    final bytes = await file.readAsBytes();
    final result = await ref.read(foodRecognitionRepositoryProvider).recognize(
          bytes: bytes,
          filename: file.name,
        );
    if (!mounted) return;

    result.fold(
      ok: (recognition) {
        final percent = (recognition.confidence * 100).round();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Detected ${recognition.food.name} ($percent%)',
            ),
          ),
        );
        context.pushReplacement(
          AppRoutes.nutritionEntry,
          extra: recognition.food,
        );
      },
      err: (failure) {
        setState(() {
          _analyzing = false;
          _captured = null;
        });
        _showError(failure.message);
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                        style: typography.titleMd.copyWith(color: Colors.white),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PrimaryButton(
                        label: _launched ? 'Retake photo' : 'Take photo',
                        icon: Icons.camera_alt_outlined,
                        onPressed: () => _pick(ImageSource.camera),
                      ),
                      SizedBox(height: spacing.stackMd),
                      GhostButton(
                        label: 'Choose from gallery',
                        icon: Icons.photo_library_outlined,
                        onPressed: () => _pick(ImageSource.gallery),
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
