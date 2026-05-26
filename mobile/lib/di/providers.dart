import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/config/env.dart';
import 'package:health_app/data/repositories/activities_repository_impl.dart';
import 'package:health_app/data/repositories/auth_repository_impl.dart';
import 'package:health_app/data/repositories/foods_repository_impl.dart';
import 'package:health_app/data/repositories/nutrition_log_repository_impl.dart';
import 'package:health_app/data/repositories/profile_repository_impl.dart';
import 'package:health_app/data/repositories/user_goals_repository_impl.dart';
import 'package:health_app/data/repositories/weight_repository_impl.dart';
import 'package:health_app/data/sources/activities/activities_source.dart';
import 'package:health_app/data/sources/activities/mock_activities_source.dart';
import 'package:health_app/data/sources/activities/supabase_activities_source.dart';
import 'package:health_app/data/sources/auth/auth_source.dart';
import 'package:health_app/data/sources/auth/mock_auth_source.dart';
import 'package:health_app/data/sources/auth/supabase_auth_source.dart';
import 'package:health_app/data/sources/foods/composite_foods_source.dart';
import 'package:health_app/data/sources/foods/foods_source.dart';
import 'package:health_app/data/sources/foods/local_foods_source.dart';
import 'package:health_app/data/sources/foods/open_food_facts_foods_source.dart';
import 'package:health_app/data/sources/foods/supabase_foods_source.dart';
import 'package:health_app/data/sources/foods/supabase_generic_foods_source.dart';
import 'package:health_app/data/sources/foods/supabase_popular_foods_source.dart';
import 'package:health_app/data/sources/nutrition_log/mock_nutrition_log_source.dart';
import 'package:health_app/data/sources/nutrition_log/nutrition_log_source.dart';
import 'package:health_app/data/sources/nutrition_log/supabase_nutrition_log_source.dart';
import 'package:health_app/data/sources/profile/mock_profile_source.dart';
import 'package:health_app/data/sources/profile/profile_source.dart';
import 'package:health_app/data/sources/profile/supabase_profile_source.dart';
import 'package:health_app/data/sources/user_goals/mock_user_goals_source.dart';
import 'package:health_app/data/sources/user_goals/supabase_user_goals_source.dart';
import 'package:health_app/data/sources/user_goals/user_goals_source.dart';
import 'package:health_app/data/sources/weights/mock_weight_source.dart';
import 'package:health_app/data/sources/weights/supabase_weight_source.dart';
import 'package:health_app/data/sources/weights/weight_source.dart';
import 'package:health_app/domain/repositories/activities_repository.dart';
import 'package:health_app/domain/repositories/auth_repository.dart';
import 'package:health_app/domain/repositories/foods_repository.dart';
import 'package:health_app/domain/repositories/nutrition_log_repository.dart';
import 'package:health_app/domain/repositories/profile_repository.dart';
import 'package:health_app/domain/repositories/user_goals_repository.dart';
import 'package:health_app/domain/repositories/weight_repository.dart';
import 'package:health_app/features/workout/services/location_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authSourceProvider = Provider<AuthSource>((ref) {
  if (Env.useMockData || !Env.isSupabaseConfigured) {
    return MockAuthSource();
  }
  return SupabaseAuthSource(ref.watch(supabaseClientProvider));
});

final activitiesSourceProvider = Provider<ActivitiesSource>((ref) {
  if (Env.useMockData || !Env.isSupabaseConfigured) {
    return MockActivitiesSource();
  }
  return SupabaseActivitiesSource(ref.watch(supabaseClientProvider));
});

final profileSourceProvider = Provider<ProfileSource>((ref) {
  if (Env.useMockData || !Env.isSupabaseConfigured) {
    return MockProfileSource();
  }
  return SupabaseProfileSource(ref.watch(supabaseClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authSourceProvider));
});

final activitiesRepositoryProvider = Provider<ActivitiesRepository>((ref) {
  return ActivitiesRepositoryImpl(ref.watch(activitiesSourceProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(profileSourceProvider));
});

final userGoalsSourceProvider = Provider<UserGoalsSource>((ref) {
  if (Env.useMockData || !Env.isSupabaseConfigured) {
    return MockUserGoalsSource();
  }
  return SupabaseUserGoalsSource(ref.watch(supabaseClientProvider));
});

final userGoalsRepositoryProvider = Provider<UserGoalsRepository>((ref) {
  return UserGoalsRepositoryImpl(ref.watch(userGoalsSourceProvider));
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return const LocationService();
});

final foodsSourceProvider = Provider<FoodsSource>((ref) {
  final useRemote = !Env.useMockData && Env.isSupabaseConfigured;
  if (!useRemote) {
    final local = LocalFoodsSource();
    return CompositeFoodsSource(
      barcodeRemote: OpenFoodFactsFoodsSource(),
      barcodeCache: local,
      catalog: local,
      library: local,
    );
  }
  final client = ref.watch(supabaseClientProvider);
  return CompositeFoodsSource(
    barcodeRemote: OpenFoodFactsFoodsSource(),
    barcodeCache: SupabasePopularFoodsSource(client),
    catalog: SupabaseGenericFoodsSource(client),
    library: SupabaseFoodsSource(client),
  );
});

final nutritionLogSourceProvider = Provider<NutritionLogSource>((ref) {
  if (Env.useMockData || !Env.isSupabaseConfigured) {
    return MockNutritionLogSource();
  }
  return SupabaseNutritionLogSource(ref.watch(supabaseClientProvider));
});

final foodsRepositoryProvider = Provider<FoodsRepository>((ref) {
  return FoodsRepositoryImpl(ref.watch(foodsSourceProvider));
});

final nutritionLogRepositoryProvider = Provider<NutritionLogRepository>((ref) {
  return NutritionLogRepositoryImpl(ref.watch(nutritionLogSourceProvider));
});

final weightSourceProvider = Provider<WeightSource>((ref) {
  if (Env.useMockData || !Env.isSupabaseConfigured) {
    return MockWeightSource();
  }
  return SupabaseWeightSource(ref.watch(supabaseClientProvider));
});

final weightRepositoryProvider = Provider<WeightRepository>((ref) {
  return WeightRepositoryImpl(ref.watch(weightSourceProvider));
});
