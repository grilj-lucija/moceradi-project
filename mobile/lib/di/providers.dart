import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/config/env.dart';
import 'package:health_app/data/repositories/activities_repository_impl.dart';
import 'package:health_app/data/repositories/auth_repository_impl.dart';
import 'package:health_app/data/repositories/profile_repository_impl.dart';
import 'package:health_app/data/sources/activities/activities_source.dart';
import 'package:health_app/data/sources/activities/mock_activities_source.dart';
import 'package:health_app/data/sources/auth/auth_source.dart';
import 'package:health_app/data/sources/auth/mock_auth_source.dart';
import 'package:health_app/data/sources/auth/supabase_auth_source.dart';
import 'package:health_app/data/sources/profile/mock_profile_source.dart';
import 'package:health_app/data/sources/profile/profile_source.dart';
import 'package:health_app/data/sources/profile/supabase_profile_source.dart';
import 'package:health_app/domain/repositories/activities_repository.dart';
import 'package:health_app/domain/repositories/auth_repository.dart';
import 'package:health_app/domain/repositories/profile_repository.dart';
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
  return MockActivitiesSource();
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

final locationServiceProvider = Provider<LocationService>((ref) {
  return const LocationService();
});
