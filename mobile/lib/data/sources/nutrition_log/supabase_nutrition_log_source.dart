import 'package:health_app/data/models/daily_nutrition_goal.dart';
import 'package:health_app/data/models/food.dart';
import 'package:health_app/data/models/food_entry.dart';
import 'package:health_app/data/models/meal_slot.dart';
import 'package:health_app/data/models/nutrition_facts.dart';
import 'package:health_app/data/sources/nutrition_log/nutrition_log_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseNutritionLogSource implements NutritionLogSource {
  SupabaseNutritionLogSource(this._client);

  final SupabaseClient _client;

  static const _entriesTable = 'food_entries';
  static const _goalsTable = 'daily_nutrition_goals';

  String? get _uid => _client.auth.currentUser?.id;

  String _requireUid() {
    final uid = _uid;
    if (uid == null) throw const AuthException('Not signed in');
    return uid;
  }

  @override
  Future<List<FoodEntry>> listEntriesForDate(DateTime date) async {
    final uid = _uid;
    if (uid == null) return [];
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final rows = await _client
        .from(_entriesTable)
        .select()
        .eq('user_id', uid)
        .gte('logged_at', start.toUtc().toIso8601String())
        .lt('logged_at', end.toUtc().toIso8601String())
        .order('logged_at');
    return [
      for (final row in rows as List<dynamic>)
        _entryFromRow(row as Map<String, dynamic>),
    ];
  }

  @override
  Future<FoodEntry> addEntry(FoodEntry entry) async {
    final uid = _requireUid();
    final payload = <String, dynamic>{
      'user_id': uid,
      'logged_at': entry.loggedAt.toUtc().toIso8601String(),
      'meal_slot': entry.mealSlot.wireValue,
      'grams': entry.grams,
      ..._snapshotPayload(entry.foodSnapshot),
    };
    final row = await _client
        .from(_entriesTable)
        .insert(payload)
        .select()
        .single();
    return _entryFromRow(row);
  }

  @override
  Future<FoodEntry> updateEntry(
    String id, {
    double? grams,
    MealSlot? mealSlot,
  }) async {
    final uid = _requireUid();
    final payload = <String, dynamic>{
      'grams': ?grams,
      'meal_slot': ?mealSlot?.wireValue,
    };
    if (payload.isEmpty) {
      final row = await _client
          .from(_entriesTable)
          .select()
          .eq('id', id)
          .eq('user_id', uid)
          .single();
      return _entryFromRow(row);
    }
    final row = await _client
        .from(_entriesTable)
        .update(payload)
        .eq('id', id)
        .eq('user_id', uid)
        .select()
        .single();
    return _entryFromRow(row);
  }

  @override
  Future<void> removeEntry(String id) async {
    final uid = _requireUid();
    await _client
        .from(_entriesTable)
        .delete()
        .eq('id', id)
        .eq('user_id', uid);
  }

  @override
  Future<DailyNutritionGoal> getDailyGoal() async {
    final uid = _uid;
    if (uid == null) return kDefaultDailyGoal;

    final existing = await _client
        .from(_goalsTable)
        .select()
        .eq('user_id', uid)
        .maybeSingle();
    if (existing != null) return _goalFromRow(existing);

    final inserted = await _client
        .from(_goalsTable)
        .insert({'user_id': uid})
        .select()
        .single();
    return _goalFromRow(inserted);
  }

  @override
  Future<DailyNutritionGoal> updateDailyKcal(double kcal) async {
    final uid = _requireUid();
    final row = await _client
        .from(_goalsTable)
        .upsert({'user_id': uid, 'kcal': kcal})
        .select()
        .single();
    return _goalFromRow(row);
  }

  FoodEntry _entryFromRow(Map<String, dynamic> row) {
    return FoodEntry(
      id: row['id'] as String,
      foodSnapshot: _snapshotFromRow(row),
      grams: _toDouble(row['grams']) ?? 0,
      loggedAt: DateTime.parse(row['logged_at'] as String),
      mealSlot: MealSlotX.fromWire(row['meal_slot'] as String?),
    );
  }

  Food _snapshotFromRow(Map<String, dynamic> row) {
    return Food(
      id: row['food_external_id'] as String,
      name: row['food_name'] as String,
      brand: row['food_brand'] as String?,
      isBeverage: (row['food_is_beverage'] as bool?) ?? false,
      defaultServingGrams: _toDouble(row['food_default_serving_grams']),
      source: _sourceFromWire(row['food_source'] as String?),
      facts: NutritionFacts(
        kcalPer100g: _toDouble(row['food_kcal_per_100g']) ?? 0,
        proteinPer100g: _toDouble(row['food_protein_per_100g']) ?? 0,
        carbsPer100g: _toDouble(row['food_carbs_per_100g']) ?? 0,
        fatPer100g: _toDouble(row['food_fat_per_100g']) ?? 0,
        sugarPer100g: _toDouble(row['food_sugar_per_100g']) ?? 0,
      ),
    );
  }

  DailyNutritionGoal _goalFromRow(Map<String, dynamic> row) {
    return DailyNutritionGoal(
      kcal: _toDouble(row['kcal']) ?? kDefaultDailyGoal.kcal,
      proteinGrams:
          _toDouble(row['protein_grams']) ?? kDefaultDailyGoal.proteinGrams,
      carbsGrams:
          _toDouble(row['carbs_grams']) ?? kDefaultDailyGoal.carbsGrams,
      fatGrams: _toDouble(row['fat_grams']) ?? kDefaultDailyGoal.fatGrams,
      sugarGrams:
          _toDouble(row['sugar_grams']) ?? kDefaultDailyGoal.sugarGrams,
      liquidsMl:
          _toDouble(row['liquids_ml']) ?? kDefaultDailyGoal.liquidsMl,
    );
  }

  Map<String, dynamic> _snapshotPayload(Food food) => {
        'food_external_id': food.id,
        'food_name': food.name,
        'food_brand': food.brand,
        'food_source': _sourceToWire(food.source),
        'food_is_beverage': food.isBeverage,
        'food_default_serving_grams': food.defaultServingGrams,
        'food_kcal_per_100g': food.facts.kcalPer100g,
        'food_protein_per_100g': food.facts.proteinPer100g,
        'food_carbs_per_100g': food.facts.carbsPer100g,
        'food_fat_per_100g': food.facts.fatPer100g,
        'food_sugar_per_100g': food.facts.sugarPer100g,
      };

  static String _sourceToWire(FoodSourceKind source) => switch (source) {
        FoodSourceKind.openFoodFacts => 'open_food_facts',
        FoodSourceKind.generic => 'generic',
        FoodSourceKind.custom => 'custom',
        FoodSourceKind.recipe => 'recipe',
      };

  static FoodSourceKind _sourceFromWire(String? value) => switch (value) {
        'open_food_facts' => FoodSourceKind.openFoodFacts,
        'generic' => FoodSourceKind.generic,
        'recipe' => FoodSourceKind.recipe,
        _ => FoodSourceKind.custom,
      };

  static double? _toDouble(Object? raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString());
  }
}
