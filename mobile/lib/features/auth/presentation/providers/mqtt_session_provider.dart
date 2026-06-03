import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/di/providers.dart';
import 'package:health_app/features/auth/presentation/providers/auth_controller.dart';

final mqttSessionProvider = Provider<void>((ref) {
  final mqtt = ref.watch(mqttServiceProvider);
  final user = ref.watch(authStateProvider).value;
  if (user != null) {
    unawaited(mqtt.connect(user.id));
  } else {
    unawaited(mqtt.disconnect());
  }
});
