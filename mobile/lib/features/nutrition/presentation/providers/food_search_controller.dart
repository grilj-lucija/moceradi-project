import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/data/models/food.dart';
import 'package:health_app/data/sources/foods/foods_source.dart';
import 'package:health_app/di/providers.dart';

class FoodSearchState extends Equatable {
  const FoodSearchState({
    required this.scope,
    required this.query,
    required this.items,
    this.isFetching = false,
  });

  const FoodSearchState.initial()
      : scope = FoodSearchScope.all,
        query = '',
        items = const [],
        isFetching = false;

  final FoodSearchScope scope;
  final String query;
  final List<Food> items;
  final bool isFetching;

  FoodSearchState copyWith({
    FoodSearchScope? scope,
    String? query,
    List<Food>? items,
    bool? isFetching,
  }) =>
      FoodSearchState(
        scope: scope ?? this.scope,
        query: query ?? this.query,
        items: items ?? this.items,
        isFetching: isFetching ?? this.isFetching,
      );

  @override
  List<Object?> get props => [scope, query, items, isFetching];
}

class FoodSearchController extends AsyncNotifier<FoodSearchState> {
  Timer? _debounce;
  int _requestId = 0;

  @override
  Future<FoodSearchState> build() async {
    ref.onDispose(() => _debounce?.cancel());
    final items = await _fetch(FoodSearchScope.all, '');
    return FoodSearchState(
      scope: FoodSearchScope.all,
      query: '',
      items: items,
    );
  }

  FoodSearchState get _current =>
      state.value ?? const FoodSearchState.initial();

  Future<List<Food>> _fetch(FoodSearchScope scope, String query) async {
    final limit = switch (scope) {
      FoodSearchScope.recent => 10,
      FoodSearchScope.all => 200,
      FoodSearchScope.generic => 100,
      FoodSearchScope.custom => 100,
      FoodSearchScope.recipes => 100,
    };
    final result = await ref
        .read(foodsRepositoryProvider)
        .searchByText(query, limit: limit, scope: scope);
    return result.fold(ok: (items) => items, err: (_) => const <Food>[]);
  }

  /// Switch the active scope. Reuses the current query string.
  Future<void> setScope(FoodSearchScope scope) async {
    final current = _current;
    if (current.scope == scope) return;
    _debounce?.cancel();
    final requestId = ++_requestId;

    state = AsyncData(
      current.copyWith(scope: scope, items: const [], isFetching: true),
    );

    final items = await _fetch(scope, current.query);
    if (requestId != _requestId) return;
    state = AsyncData(
      current.copyWith(scope: scope, items: items, isFetching: false),
    );
  }

  Future<void> search(String query) async {
    final trimmed = query.trim();
    final current = _current;

    _debounce?.cancel();
    final requestId = ++_requestId;

    // Empty query: resolve immediately, no debounce.
    if (trimmed.isEmpty) {
      state = AsyncData(
        current.copyWith(query: '', isFetching: true),
      );
      final items = await _fetch(current.scope, '');
      if (requestId != _requestId) return;
      state = AsyncData(
        current.copyWith(query: '', items: items, isFetching: false),
      );
      return;
    }

    state = AsyncData(current.copyWith(query: trimmed, isFetching: true));

    final completer = Completer<void>();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (requestId != _requestId) {
        completer.complete();
        return;
      }
      try {
        final items = await _fetch(current.scope, trimmed);
        if (requestId == _requestId) {
          state = AsyncData(
            current.copyWith(
              query: trimmed,
              items: items,
              isFetching: false,
            ),
          );
        }
      } on Object catch (e, st) {
        if (requestId == _requestId) {
          state = AsyncError<FoodSearchState>(e, st);
        }
      } finally {
        completer.complete();
      }
    });
    return completer.future;
  }

  /// Force a refresh of the current scope/query (e.g. pull-to-refresh, or
  /// after saving a new custom food).
  Future<void> refresh() async {
    final current = _current;
    final requestId = ++_requestId;
    state = AsyncData(current.copyWith(isFetching: true));
    final items = await _fetch(current.scope, current.query);
    if (requestId != _requestId) return;
    state = AsyncData(current.copyWith(items: items, isFetching: false));
  }
}

final foodSearchControllerProvider =
    AsyncNotifierProvider<FoodSearchController, FoodSearchState>(
  FoodSearchController.new,
);
