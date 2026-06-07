import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
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

class _PhotoCapturePageState extends ConsumerState<PhotoCapturePage>
    with WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();
  CameraController? _controller;
  String? _cameraError;
  XFile? _captured;
  bool _analyzing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initCamera());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_controller?.dispose());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(controller.dispose());
      _controller = null;
    } else if (state == AppLifecycleState.resumed && _captured == null) {
      unawaited(_initCamera());
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _cameraError = 'No camera available');
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        unawaited(controller.dispose());
        return;
      }
      setState(() {
        _controller = controller;
        _cameraError = null;
      });
    } on Object catch (e) {
      if (mounted) setState(() => _cameraError = 'Could not open camera: $e');
    }
  }

  Future<void> _takePhoto() async {
    final controller = _controller;
    if (_analyzing || controller == null || !controller.value.isInitialized) {
      return;
    }
    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      setState(() {
        _captured = file;
        _analyzing = true;
      });
      await _analyze(file);
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _analyzing = false);
      _showError('Could not capture photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    if (_analyzing) return;
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
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
      _showError('Could not open gallery: $e');
    }
  }

  Future<void> _retake() async {
    setState(() {
      _captured = null;
      _analyzing = false;
    });
    if (_controller == null) {
      unawaited(_initCamera());
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
    final controller = _controller;

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
          else if (controller != null && controller.value.isInitialized)
            _CameraPreviewCover(controller: controller)
          else
            Center(
              child: _cameraError != null
                  ? Padding(
                      padding: EdgeInsets.all(spacing.stackLg),
                      child: Text(
                        _cameraError!,
                        style:
                            typography.bodyMd.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : CircularProgressIndicator(color: colors.enduranceCyan),
            ),
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
                        label: captured != null ? 'Retake photo' : 'Take photo',
                        icon: Icons.camera_alt_outlined,
                        onPressed: captured != null ? _retake : _takePhoto,
                      ),
                      SizedBox(height: spacing.stackMd),
                      GhostButton(
                        label: 'Choose from gallery',
                        icon: Icons.photo_library_outlined,
                        onPressed: _pickFromGallery,
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

class _CameraPreviewCover extends StatelessWidget {
  const _CameraPreviewCover({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final size = controller.value.previewSize;
    if (size == null) return CameraPreview(controller);
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.height,
          height: size.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}
