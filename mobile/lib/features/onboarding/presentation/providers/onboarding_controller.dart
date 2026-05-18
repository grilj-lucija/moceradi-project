import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/data/models/profile.dart';
import 'package:health_app/di/providers.dart';
import 'package:health_app/features/auth/presentation/providers/profile_provider.dart';

class OnboardingFormState extends Equatable {
  const OnboardingFormState({
    this.displayName = '',
    this.username = '',
    this.gender,
    this.dateOfBirth,
    this.heightCm,
    this.weightKg,
    this.isSubmitting = false,
  });

  final String displayName;
  final String username;
  final Gender? gender;
  final DateTime? dateOfBirth;
  final double? heightCm;
  final double? weightKg;
  final bool isSubmitting;

  OnboardingFormState copyWith({
    String? displayName,
    String? username,
    Gender? gender,
    DateTime? dateOfBirth,
    double? heightCm,
    double? weightKg,
    bool? isSubmitting,
  }) =>
      OnboardingFormState(
        displayName: displayName ?? this.displayName,
        username: username ?? this.username,
        gender: gender ?? this.gender,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );

  @override
  List<Object?> get props => [
        displayName,
        username,
        gender,
        dateOfBirth,
        heightCm,
        weightKg,
        isSubmitting,
      ];
}

class OnboardingController extends Notifier<OnboardingFormState> {
  @override
  OnboardingFormState build() => const OnboardingFormState();

  void setDisplayName(String value) =>
      state = state.copyWith(displayName: value);
  void setUsername(String value) => state = state.copyWith(username: value);
  void setGender(Gender value) => state = state.copyWith(gender: value);
  void setDateOfBirth(DateTime value) =>
      state = state.copyWith(dateOfBirth: value);
  void setHeight(double value) => state = state.copyWith(heightCm: value);
  void setWeight(double value) => state = state.copyWith(weightKg: value);

  Future<Failure?> submit() async {
    state = state.copyWith(isSubmitting: true);
    final result = await ref.read(profileRepositoryProvider).upsert(
          username: state.username.trim(),
          displayName: state.displayName.trim(),
          gender: state.gender,
          dateOfBirth: state.dateOfBirth,
          heightCm: state.heightCm,
          weightKg: state.weightKg,
          markOnboarded: true,
        );
    state = state.copyWith(isSubmitting: false);
    return result.fold(
      ok: (_) {
        ref.invalidate(currentProfileProvider);
        return null;
      },
      err: (failure) => failure,
    );
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingFormState>(
  OnboardingController.new,
);
