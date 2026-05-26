import 'dart:async';

import 'package:health_app/data/models/user_goals.dart';
import 'package:health_app/data/sources/user_goals/user_goals_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUserGoalsSource implements UserGoalsSource {
  SupabaseUserGoalsSource(this._client);

  final SupabaseClient _client;

  static const _table = 'user_goals';

  String? get _uid => _client.auth.currentUser?.id;

  @override
  Future<UserGoals?> getCurrent() async {
    final uid = _uid;
    if (uid == null) return null;
    final row = await _client
        .from(_table)
        .select()
        .eq('user_id', uid)
        .maybeSingle();
    return row == null ? null : UserGoals.fromJson(row);
  }

  @override
  Stream<UserGoals?> watchCurrent() async* {
    yield await getCurrent();
    final uid = _uid;
    if (uid == null) return;

    final stream = _client
        .from(_table)
        .stream(primaryKey: ['user_id'])
        .eq('user_id', uid);

    await for (final rows in stream) {
      if (rows.isEmpty) {
        yield null;
      } else {
        yield UserGoals.fromJson(rows.first);
      }
    }
  }

  @override
  Future<UserGoals> upsert({
    List<GoalType>? intents,
    ActivityMetric? activityMetric,
    double? activityTarget,
    GoalPace? pace,
    bool? kcalOverride,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw const AuthException('Not signed in');
    }

    final payload = <String, dynamic>{
      'user_id': uid,
      'intents': ?intents?.map((g) => g.wireValue).toList(),
      'activity_metric': ?activityMetric?.wireValue,
      'activity_target': ?activityTarget,
      'pace': ?pace?.wireValue,
      'kcal_override': ?kcalOverride,
    };

    final row = await _client
        .from(_table)
        .upsert(payload)
        .select()
        .single();
    return UserGoals.fromJson(row);
  }
}
