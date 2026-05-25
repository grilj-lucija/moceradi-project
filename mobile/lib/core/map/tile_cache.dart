import 'dart:io';

import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:http_cache_file_store/http_cache_file_store.dart';
import 'package:path_provider/path_provider.dart';

class MapTileCache {
  MapTileCache._();

  static FileCacheStore? _store;
  static Future<void>? _initFuture;
  static CachedTileProvider? _cachedProvider;

  static Future<void> init() {
    final pending = _initFuture;
    if (pending != null) return pending;
    if (_store != null) return Future.value();
    final future = _resolve();
    _initFuture = future;
    return future;
  }

  static Future<void> _resolve() async {
    final dir = await getApplicationCacheDirectory();
    final cacheDir = Directory('${dir.path}/map_tiles');
    if (!cacheDir.existsSync()) {
      cacheDir.createSync(recursive: true);
    }
    _store = FileCacheStore(cacheDir.path);
  }

  static CachedTileProvider? provider() {
    final store = _store;
    if (store == null) return null;
    return _cachedProvider ??= CachedTileProvider(
      store: store,
      maxStale: const Duration(days: 30),
    );
  }
}
