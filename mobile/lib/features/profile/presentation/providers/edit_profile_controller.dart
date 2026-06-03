import 'dart:async';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/di/providers.dart';

enum UsernameStatus { idle, checking, available, taken, invalid }

class EditProfileState extends Equatable {
  const EditProfileState({
    this.usernameStatus = UsernameStatus.idle,
    this.usernameMessage,
    this.avatarPreview,
    this.uploadedAvatarUrl,
    this.isUploading = false,
    this.isSaving = false,
  });

  final UsernameStatus usernameStatus;
  final String? usernameMessage;
  final Uint8List? avatarPreview;
  final String? uploadedAvatarUrl;
  final bool isUploading;
  final bool isSaving;

  bool get canSave =>
      !isSaving &&
      !isUploading &&
      usernameStatus != UsernameStatus.checking &&
      usernameStatus != UsernameStatus.taken &&
      usernameStatus != UsernameStatus.invalid;

  EditProfileState copyWith({
    UsernameStatus? usernameStatus,
    String? usernameMessage,
    bool clearUsernameMessage = false,
    Uint8List? avatarPreview,
    String? uploadedAvatarUrl,
    bool clearAvatarPreview = false,
    bool clearUploadedAvatar = false,
    bool? isUploading,
    bool? isSaving,
  }) =>
      EditProfileState(
        usernameStatus: usernameStatus ?? this.usernameStatus,
        usernameMessage: clearUsernameMessage
            ? null
            : (usernameMessage ?? this.usernameMessage),
        avatarPreview:
            clearAvatarPreview ? null : (avatarPreview ?? this.avatarPreview),
        uploadedAvatarUrl: clearUploadedAvatar
            ? null
            : (uploadedAvatarUrl ?? this.uploadedAvatarUrl),
        isUploading: isUploading ?? this.isUploading,
        isSaving: isSaving ?? this.isSaving,
      );

  @override
  List<Object?> get props => [
        usernameStatus,
        usernameMessage,
        avatarPreview,
        uploadedAvatarUrl,
        isUploading,
        isSaving,
      ];
}

class EditProfileController extends Notifier<EditProfileState> {
  Timer? _debounce;
  int _checkVersion = 0;
  String? _initialUsername;

  @override
  EditProfileState build() {
    ref.onDispose(() {
      _debounce?.cancel();
    });
    return const EditProfileState();
  }

  void seed(String? currentUsername) {
    _initialUsername = currentUsername?.toLowerCase();
  }

  void onUsernameChanged(String raw) {
    _debounce?.cancel();
    final trimmed = raw.trim().toLowerCase();

    if (trimmed.isEmpty) {
      state = state.copyWith(
        usernameStatus: UsernameStatus.invalid,
        usernameMessage: 'Username is required',
      );
      return;
    }
    if (trimmed.length < 3) {
      state = state.copyWith(
        usernameStatus: UsernameStatus.invalid,
        usernameMessage: 'Min 3 characters',
      );
      return;
    }
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(trimmed)) {
      state = state.copyWith(
        usernameStatus: UsernameStatus.invalid,
        usernameMessage: 'Lowercase letters, numbers, underscore only',
      );
      return;
    }
    if (trimmed.length > 24) {
      state = state.copyWith(
        usernameStatus: UsernameStatus.invalid,
        usernameMessage: 'Max 24 characters',
      );
      return;
    }
    if (trimmed == _initialUsername) {
      state = state.copyWith(
        usernameStatus: UsernameStatus.available,
        clearUsernameMessage: true,
      );
      return;
    }

    state = state.copyWith(
      usernameStatus: UsernameStatus.checking,
      clearUsernameMessage: true,
    );
    final version = ++_checkVersion;
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final result =
          await ref.read(profileRepositoryProvider).isUsernameAvailable(trimmed);
      if (version != _checkVersion) return;
      result.fold(
        ok: (available) {
          state = state.copyWith(
            usernameStatus:
                available ? UsernameStatus.available : UsernameStatus.taken,
            usernameMessage: available ? null : 'Username already taken',
            clearUsernameMessage: available,
          );
        },
        err: (f) {
          state = state.copyWith(
            usernameStatus: UsernameStatus.idle,
            usernameMessage: f.message,
          );
        },
      );
    });
  }

  Future<bool> uploadAvatar({
    required Uint8List bytes,
    required String contentType,
    required String fileExtension,
  }) async {
    state = state.copyWith(
      isUploading: true,
      avatarPreview: bytes,
    );
    final result = await ref.read(profileRepositoryProvider).uploadAvatar(
          bytes: bytes,
          contentType: contentType,
          fileExtension: fileExtension,
        );
    return result.fold(
      ok: (url) {
        state = state.copyWith(
          isUploading: false,
          uploadedAvatarUrl: url,
        );
        return true;
      },
      err: (f) {
        state = state.copyWith(
          isUploading: false,
          clearAvatarPreview: true,
          usernameMessage: f.message,
        );
        return false;
      },
    );
  }

  void _setSaving({required bool value}) {
    state = state.copyWith(isSaving: value);
  }

  Future<Failure?> save({
    required String displayName,
    required String username,
  }) async {
    _setSaving(value: true);
    final result = await ref.read(profileRepositoryProvider).upsert(
          displayName: displayName,
          username: username,
          avatarUrl: state.uploadedAvatarUrl,
        );
    _setSaving(value: false);
    return result.fold(ok: (_) => null, err: (f) => f);
  }
}

final editProfileControllerProvider =
    NotifierProvider<EditProfileController, EditProfileState>(
  EditProfileController.new,
);
