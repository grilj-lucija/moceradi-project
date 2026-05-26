import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/home_shell.dart';
import 'package:health_app/data/models/activity.dart';
import 'package:health_app/data/models/food.dart';
import 'package:health_app/features/activities/presentation/pages/activities_page.dart';
import 'package:health_app/features/auth/presentation/pages/login_page.dart';
import 'package:health_app/features/auth/presentation/pages/register_page.dart';
import 'package:health_app/features/auth/presentation/providers/auth_controller.dart';
import 'package:health_app/features/auth/presentation/providers/profile_provider.dart';
import 'package:health_app/features/dashboard/presentation/pages/activity_detail_page.dart';
import 'package:health_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:health_app/features/nutrition/presentation/pages/add_food_page.dart';
import 'package:health_app/features/nutrition/presentation/pages/barcode_lookup_page.dart';
import 'package:health_app/features/nutrition/presentation/pages/barcode_scan_page.dart';
import 'package:health_app/features/nutrition/presentation/pages/custom_food_form_page.dart';
import 'package:health_app/features/nutrition/presentation/pages/food_detail_entry_page.dart';
import 'package:health_app/features/nutrition/presentation/pages/food_search_page.dart';
import 'package:health_app/features/nutrition/presentation/pages/nutrition_page.dart';
import 'package:health_app/features/nutrition/presentation/pages/photo_capture_page.dart';
import 'package:health_app/features/nutrition/presentation/pages/recipe_form_page.dart';
import 'package:health_app/features/nutrition/presentation/pages/recipes_page.dart';
import 'package:health_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:health_app/features/profile/presentation/pages/edit_goals_page.dart';
import 'package:health_app/features/profile/presentation/pages/profile_page.dart';
import 'package:health_app/features/workout/presentation/pages/active_workout_page.dart';
import 'package:health_app/features/workout/presentation/pages/select_activity_page.dart';
import 'package:health_app/features/workout/presentation/pages/workout_summary_page.dart';
import 'package:health_app/features/workout/presentation/providers/workout_controller.dart';

class AppRoutes {
  const AppRoutes._();
  static const login = '/login';
  static const register = '/register';
  static const onboarding = '/onboarding';
  static const dashboard = '/';
  static const activities = '/activities';
  static const nutrition = '/nutrition';
  static const nutritionAdd = '/nutrition/add';
  static const nutritionScan = '/nutrition/scan';
  static const nutritionScanLookup = '/nutrition/scan/lookup';
  static const nutritionSearch = '/nutrition/search';
  static const nutritionEntry = '/nutrition/entry';
  static const nutritionCustom = '/nutrition/custom';
  static const nutritionPhoto = '/nutrition/photo';
  static const nutritionRecipes = '/nutrition/recipes';
  static const nutritionRecipeNew = '/nutrition/recipes/new';
  static const activityDetail = '/activity';
  static const activitiesAll = '/activities/all';
  static const profile = '/profile';
  static const editGoals = '/profile/goals';
  static const workoutActive = '/workout/active';
  static const workoutSummary = '/workout/summary';

  static const Set<String> _publicPaths = {login, register};
  static bool isPublic(String path) => _publicPaths.contains(path);
  static const Set<String> _workoutPaths = {workoutActive, workoutSummary};
  static bool isWorkout(String path) => _workoutPaths.contains(path);
}

final routerProvider = Provider<GoRouter>((ref) {
  final navKey = GlobalKey<NavigatorState>();
  final shellKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: navKey,
    initialLocation: AppRoutes.dashboard,
    refreshListenable: _AuthChangeNotifier(ref),
    redirect: (context, state) {
      final user = ref.read(authStateProvider).value;
      final profileAsync = ref.read(currentProfileProvider);
      final loc = state.matchedLocation;
      final isPublic = AppRoutes.isPublic(loc);

      if (user == null) {
        return isPublic ? null : AppRoutes.login;
      }

      if (isPublic) return AppRoutes.dashboard;

      if (profileAsync.isLoading) return null;

      final profile = profileAsync.value;
      final needsOnboarding = profile == null || !profile.isOnboarded;

      if (needsOnboarding && loc != AppRoutes.onboarding) {
        return AppRoutes.onboarding;
      }
      if (!needsOnboarding && loc == AppRoutes.onboarding) {
        return AppRoutes.dashboard;
      }

      if (AppRoutes.isWorkout(loc) &&
          ref.read(workoutControllerProvider) == null) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.workoutActive,
        parentNavigatorKey: navKey,
        builder: (context, state) => const ActiveWorkoutPage(),
      ),
      GoRoute(
        path: AppRoutes.workoutSummary,
        parentNavigatorKey: navKey,
        builder: (context, state) => const WorkoutSummaryPage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        parentNavigatorKey: navKey,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.editGoals,
        parentNavigatorKey: navKey,
        builder: (context, state) => const EditGoalsPage(),
      ),
      GoRoute(
        path: AppRoutes.nutritionAdd,
        parentNavigatorKey: navKey,
        builder: (context, state) => const AddFoodPage(),
      ),
      GoRoute(
        path: AppRoutes.nutritionScan,
        parentNavigatorKey: navKey,
        builder: (context, state) => const BarcodeScanPage(),
      ),
      GoRoute(
        path: AppRoutes.nutritionScanLookup,
        parentNavigatorKey: navKey,
        builder: (context, state) {
          final barcode = state.extra as String?;
          if (barcode == null || barcode.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('No barcode provided')),
            );
          }
          return BarcodeLookupPage(barcode: barcode);
        },
      ),
      GoRoute(
        path: AppRoutes.nutritionSearch,
        parentNavigatorKey: navKey,
        builder: (context, state) => const FoodSearchPage(),
      ),
      GoRoute(
        path: AppRoutes.nutritionEntry,
        parentNavigatorKey: navKey,
        builder: (context, state) {
          final food = state.extra as Food?;
          if (food == null) {
            return const Scaffold(
              body: Center(child: Text('No food provided')),
            );
          }
          return FoodDetailEntryPage(food: food);
        },
      ),
      GoRoute(
        path: AppRoutes.nutritionCustom,
        parentNavigatorKey: navKey,
        builder: (context, state) => const CustomFoodFormPage(),
      ),
      GoRoute(
        path: AppRoutes.nutritionPhoto,
        parentNavigatorKey: navKey,
        builder: (context, state) => const PhotoCapturePage(),
      ),
      GoRoute(
        path: AppRoutes.nutritionRecipes,
        parentNavigatorKey: navKey,
        builder: (context, state) => const RecipesPage(),
      ),
      GoRoute(
        path: AppRoutes.nutritionRecipeNew,
        parentNavigatorKey: navKey,
        builder: (context, state) => const RecipeFormPage(),
      ),
      GoRoute(
        path: AppRoutes.activityDetail,
        parentNavigatorKey: navKey,
        builder: (context, state) {
          final activity = state.extra as Activity?;
          if (activity == null) {
            return const Scaffold(
              body: Center(child: Text('No activity provided')),
            );
          }
          return ActivityDetailPage(activity: activity);
        },
      ),
      GoRoute(
        path: AppRoutes.activitiesAll,
        parentNavigatorKey: navKey,
        builder: (context, state) => const ActivitiesPage(),
      ),
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: navKey,
        builder: (context, state, navShell) => HomeShell(
          currentIndex: navShell.currentIndex,
          onTap: (i) => navShell.goBranch(i, initialLocation: i == navShell.currentIndex),
          child: navShell,
        ),
        branches: [
          StatefulShellBranch(
            navigatorKey: shellKey,
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.activities,
                builder: (context, state) => const SelectActivityPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.nutrition,
                builder: (context, state) => const NutritionPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(this._ref) {
    _ref
      ..listen(authStateProvider, (previous, next) => notifyListeners())
      ..listen(currentProfileProvider, (previous, next) => notifyListeners())
      ..listen(
        workoutControllerProvider,
        (previous, next) => notifyListeners(),
      );
  }
  final Ref _ref;
}
