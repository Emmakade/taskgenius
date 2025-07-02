import 'dart:collection';

/// A simple in-memory cache manager for storing and retrieving key-value pairs.
class CacheManager {
  final _cache = HashMap<String, dynamic>();

  /// Stores a value in the cache with the given [key].
  void set(String key, dynamic value) {
    _cache[key] = value;
  }

  /// Retrieves a value from the cache by [key]. Returns null if not found.
  T? get<T>(String key) {
    final value = _cache[key];
    if (value is T) {
      return value;
    }
    return null;
  }

  /// Removes a value from the cache by [key].
  void remove(String key) {
    _cache.remove(key);
  }

  /// Clears all cached values.
  void clear() {
    _cache.clear();
  }
}
