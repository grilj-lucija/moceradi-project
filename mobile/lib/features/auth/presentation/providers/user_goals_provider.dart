import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/data/models/user_goals.dart';
import 'package:health_app/di/providers.dart';
import 'package:health_app/features/auth/presentation/providers/auth_controller.dart';

final currentUserGoalsProvider = StreamProvider<UserGoals?>((ref) async* {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    yield null;
    return;
  }
  yield* ref.watch(userGoalsRepositoryProvider).watchCurrent();
});
