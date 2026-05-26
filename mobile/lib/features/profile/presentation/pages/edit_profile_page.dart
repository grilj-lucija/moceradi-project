import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/features/auth/presentation/providers/profile_provider.dart';
import 'package:health_app/features/profile/presentation/providers/edit_profile_controller.dart';
import 'package:health_app/shared/widgets/avatars/profile_avatar.dart';
import 'package:health_app/shared/widgets/buttons/primary_button.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _picker = ImagePicker();

  bool _seeded = false;
  String? _errorText;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    final profile = ref.read(currentProfileProvider).value;
    if (profile == null) return;
    _displayNameController.text = profile.displayName ?? '';
    _usernameController.text = profile.username ?? '';
    ref.read(editProfileControllerProvider.notifier).seed(profile.username);
    _seeded = true;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final ext = picked.path.split('.').last.toLowerCase();
    final normalizedExt = ext == 'jpeg' ? 'jpg' : ext;
    final contentType = _contentTypeFor(normalizedExt);
    final ok = await ref
        .read(editProfileControllerProvider.notifier)
        .uploadAvatar(
          bytes: bytes,
          contentType: contentType,
          fileExtension: normalizedExt,
        );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not upload photo')),
      );
    }
  }

  String _contentTypeFor(String ext) => switch (ext) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        'gif' => 'image/gif',
        'heic' || 'heif' => 'image/heic',
        _ => 'image/jpeg',
      };

  Future<void> _showAvatarSheet() async {
    final colors = context.colors;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: colors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.radius.xl),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!Platform.isMacOS && !Platform.isWindows && !Platform.isLinux)
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take photo'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(ImageSource.camera),
              ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from library'),
              onTap: () =>
                  Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    await _pickAvatar(source);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorText = null);
    final formOk = _formKey.currentState!.validate();
    final state = ref.read(editProfileControllerProvider);
    if (!formOk || !state.canSave) {
      setState(() =>
          _errorText = state.usernameMessage ?? 'Please fix the highlighted fields.');
      return;
    }

    final failure =
        await ref.read(editProfileControllerProvider.notifier).save(
              displayName: _displayNameController.text.trim(),
              username: _usernameController.text.trim().toLowerCase(),
            );
    if (failure != null) {
      if (!mounted) return;
      setState(() => _errorText = failure.message);
      return;
    }
    if (!mounted) return;
    ref.invalidate(currentProfileProvider);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final state = ref.watch(editProfileControllerProvider);
    final profile = ref.watch(currentProfileProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            spacing.containerMarginMobile,
            spacing.stackMd,
            spacing.containerMarginMobile,
            spacing.stackLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            ProfileAvatar(
                              name: _displayNameController.text.isEmpty
                                  ? (profile?.presentationName ?? 'Athlete')
                                  : _displayNameController.text,
                              avatarUrl: state.uploadedAvatarUrl ??
                                  profile?.avatarUrl,
                              preview: state.avatarPreview,
                              size: ProfileAvatarSize.xl,
                              borderColor: colors.enduranceCyan
                                  .withValues(alpha: 0.4),
                              borderWidth: 1.5,
                              onTap: state.isUploading
                                  ? null
                                  : () => unawaited(_showAvatarSheet()),
                            ),
                            if (state.isUploading)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black
                                        .withValues(alpha: 0.35),
                                    borderRadius: radius.pill,
                                  ),
                                  alignment: Alignment.center,
                                  child: const SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Material(
                                color: colors.enduranceCyan,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () =>
                                      unawaited(_showAvatarSheet()),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.photo_camera_outlined,
                                      size: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: spacing.stackSm),
                      Center(
                        child: TextButton(
                          onPressed: state.isUploading
                              ? null
                              : () => unawaited(_showAvatarSheet()),
                          child: const Text('Change photo'),
                        ),
                      ),
                      SizedBox(height: spacing.stackLg),
                      Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _label(context, 'DISPLAY NAME'),
                            SizedBox(height: spacing.stackSm),
                            TextFormField(
                              controller: _displayNameController,
                              textCapitalization: TextCapitalization.words,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                hintText: 'How others see you',
                              ),
                              validator: (v) {
                                final value = (v ?? '').trim();
                                if (value.isEmpty) return 'Required';
                                if (value.length < 2) return 'Too short';
                                return null;
                              },
                            ),
                            SizedBox(height: spacing.stackLg),
                            _label(context, 'USERNAME'),
                            SizedBox(height: spacing.stackSm),
                            TextFormField(
                              controller: _usernameController,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              decoration: InputDecoration(
                                hintText: 'pick a unique handle',
                                prefixText: '@ ',
                                suffixIcon: _usernameSuffix(state),
                              ),
                              onChanged: (v) {
                                ref
                                    .read(editProfileControllerProvider
                                        .notifier)
                                    .onUsernameChanged(v);
                              },
                              validator: (v) {
                                final value = (v ?? '').trim();
                                if (value.length < 3) return 'Min 3 characters';
                                if (!RegExp(r'^[a-z0-9_]+$')
                                    .hasMatch(value)) {
                                  return 'Lowercase letters, numbers, underscore only';
                                }
                                if (state.usernameStatus ==
                                    UsernameStatus.taken) {
                                  return 'Username already taken';
                                }
                                return null;
                              },
                            ),
                            if (state.usernameMessage != null) ...[
                              SizedBox(height: spacing.stackSm),
                              Text(
                                state.usernameMessage!,
                                style: typography.labelMd.copyWith(
                                  color: state.usernameStatus ==
                                          UsernameStatus.available
                                      ? colors.enduranceCyan
                                      : colors.error,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_errorText != null) ...[
                SizedBox(height: spacing.stackMd),
                Text(
                  _errorText!,
                  textAlign: TextAlign.center,
                  style: typography.bodyMd.copyWith(color: colors.error),
                ),
              ],
              SizedBox(height: spacing.stackMd),
              PrimaryButton(
                label: 'Save',
                icon: Icons.check,
                isLoading: state.isSaving,
                onPressed: state.canSave ? _save : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _usernameSuffix(EditProfileState state) {
    final colors = context.colors;
    switch (state.usernameStatus) {
      case UsernameStatus.checking:
        return const Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      case UsernameStatus.available:
        return Icon(Icons.check_circle, color: colors.enduranceCyan);
      case UsernameStatus.taken:
      case UsernameStatus.invalid:
        return Icon(Icons.error_outline, color: colors.error);
      case UsernameStatus.idle:
        return null;
    }
  }

  Widget _label(BuildContext context, String text) => Text(
        text,
        style: context.typography.labelMd.copyWith(
          color: context.colors.onSurfaceVariant,
          letterSpacing: 2,
        ),
      );
}
