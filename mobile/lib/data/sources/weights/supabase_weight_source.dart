import 'package:health_app/data/models/weight_entry.dart';
import 'package:health_app/data/sources/weights/weight_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseWeightSource implements WeightSource {
  SupabaseWeightSource(this._client);

  final SupabaseClient _client;

  static const _table = 'user_weights';

  String? get _uid => _client.auth.currentUser?.id;

  static String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  @override
  Future<WeightEntry?> getForWeek(DateTime weekStart) async {
    final uid = _uid;
    if (uid == null) return null;
    final row = await _client
        .from(_table)
        .select()
        .eq('user_id', uid)
        .eq('week_start', _formatDate(weekStart))
        .maybeSingle();
    return row == null ? null : WeightEntry.fromJson(row);
  }

  @override
  Future<WeightEntry> upsertForWeek({
    required DateTime weekStart,
    required double weightKg,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw const AuthException('Not signed in');
    }

    final payload = <String, dynamic>{
      'user_id': uid,
      'weight_kg': weightKg,
      'week_start': _formatDate(weekStart),
      'logged_at': DateTime.now().toUtc().toIso8601String(),
    };

    final row = await _client
        .from(_table)
        .upsert(payload, onConflict: 'user_id,week_start')
        .select()
        .single();
    return WeightEntry.fromJson(row);
  }
}
