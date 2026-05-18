import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/data/models/profile.dart';
import 'package:health_app/di/providers.dart';
import 'package:health_app/features/auth/presentation/providers/auth_controller.dart';

final currentProfileProvider = StreamProvider<Profile?>((ref) async* {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    yield null;
    return;
  }
  yield* ref.watch(profileRepositoryProvider).watchCurrent();
});
