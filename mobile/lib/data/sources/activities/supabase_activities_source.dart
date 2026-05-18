import 'package:health_app/data/models/activity.dart';
import 'package:health_app/data/sources/activities/activities_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseActivitiesSource implements ActivitiesSource {
  SupabaseActivitiesSource(this._client);

  final SupabaseClient _client;

  static const _table = 'activities';

  @override
  Future<List<Activity>> listRecent({int limit = 20}) async {
    final rows = await _client
        .from(_table)
        .select()
        .order('started_at', ascending: false)
        .limit(limit);
    return rows.map(Activity.fromJson).toList();
  }

  @override
  Future<Activity?> getById(String id) async {
    final row = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : Activity.fromJson(row);
  }
}
