import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

/// Advanced caching service with in-memory and persistent storage
@lazySingleton
class CacheService {
  final Logger _logger = Logger();
  
  // In-memory cache
  final Map<String, _CacheEntry> _memoryCache = {};
  
  // Cache configuration
  static const Duration _defaultTtl = Duration(hours: 1);
  static const int _maxMemoryCacheSize = 100;
  
  // Hive box names
  static const String _cacheBoxName = 'app_cache';
  Box? _cacheBox;
  
  bool _initialized = false;
  
  /// Initialize cache service
  Future<void> init() async {
    if (_initialized) return;
    
    try {
      _cacheBox = await Hive.openBox(_cacheBoxName);
      _initialized = true;
      _logger.i('CacheService initialized');
      
      // Clean expired entries on startup
      _cleanExpiredEntries();
    } catch (e) {
      _logger.e('Error initializing CacheService', error: e);
    }
  }
  
  /// Get cached value
  Future<T?> get<T>(String key, {T Function(Map<String, dynamic>)? fromJson}) async {
    if (!_initialized) await init();
    
    // Check memory cache first
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null && !memoryEntry.isExpired) {
      _logger.d('Cache hit (memory): $key');
      return memoryEntry.value as T?;
    }
    
    // Check persistent cache
    try {
      final cachedData = _cacheBox?.get(key);
      if (cachedData != null) {
        final entry = _CacheEntry.fromJson(jsonDecode(cachedData as String));
        if (!entry.isExpired) {
          _logger.d('Cache hit (persistent): $key');
          // Store in memory for faster access
          _memoryCache[key] = entry;
          _evictIfNeeded();
          
          if (fromJson != null && entry.value is Map) {
            return fromJson(entry.value as Map<String, dynamic>);
          }
          return entry.value as T?;
        } else {
          // Remove expired entry
          await _cacheBox?.delete(key);
        }
      }
    } catch (e) {
      _logger.w('Error reading from cache: $key', error: e);
    }
    
    _logger.d('Cache miss: $key');
    return null;
  }
  
  /// Set cached value
  Future<void> set<T>(
    String key,
    T value, {
    Duration? ttl,
    Map<String, dynamic> Function(T)? toJson,
  }) async {
    if (!_initialized) await init();
    
    final entry = _CacheEntry(
      value: toJson != null ? toJson(value) : value,
      expiresAt: DateTime.now().add(ttl ?? _defaultTtl),
    );
    
    // Store in memory
    _memoryCache[key] = entry;
    _evictIfNeeded();
    
    // Store in persistent cache
    try {
      await _cacheBox?.put(key, jsonEncode(entry.toJson()));
    } catch (e) {
      _logger.w('Error writing to cache: $key', error: e);
    }
  }
  
  /// Invalidate cache entry
  Future<void> invalidate(String key) async {
    _memoryCache.remove(key);
    await _cacheBox?.delete(key);
    _logger.d('Cache invalidated: $key');
  }
  
  /// Invalidate cache entries matching pattern
  Future<void> invalidatePattern(String pattern) async {
    final keysToRemove = <String>[];
    
    // Memory cache
    for (final key in _memoryCache.keys) {
      if (key.contains(pattern)) {
        keysToRemove.add(key);
      }
    }
    for (final key in keysToRemove) {
      _memoryCache.remove(key);
    }
    
    // Persistent cache
    if (_cacheBox != null) {
      for (final key in _cacheBox!.keys) {
        if (key.toString().contains(pattern)) {
          await _cacheBox!.delete(key);
        }
      }
    }
    
    _logger.d('Cache invalidated (pattern: $pattern)');
  }
  
  /// Clear all cache
  Future<void> clear() async {
    _memoryCache.clear();
    await _cacheBox?.clear();
    _logger.i('Cache cleared');
  }
  
  /// Clean expired entries
  void _cleanExpiredEntries() {
    final expiredKeys = <String>[];
    
    // Memory cache
    for (final entry in _memoryCache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }
    for (final key in expiredKeys) {
      _memoryCache.remove(key);
    }
    
    // Persistent cache
    if (_cacheBox != null) {
      final persistentExpiredKeys = <String>[];
      for (final key in _cacheBox!.keys) {
        try {
          final cachedData = _cacheBox!.get(key);
          if (cachedData != null) {
            final entry = _CacheEntry.fromJson(jsonDecode(cachedData as String));
            if (entry.isExpired) {
              persistentExpiredKeys.add(key.toString());
            }
          }
        } catch (e) {
          // Invalid entry, remove it
          persistentExpiredKeys.add(key.toString());
        }
      }
      for (final key in persistentExpiredKeys) {
        _cacheBox!.delete(key);
      }
    }
  }
  
  /// Evict oldest entries if cache is full
  void _evictIfNeeded() {
    if (_memoryCache.length <= _maxMemoryCacheSize) return;
    
    // Sort by expiration time and remove oldest
    final sortedEntries = _memoryCache.entries.toList()
      ..sort((a, b) => a.value.expiresAt.compareTo(b.value.expiresAt));
    
    final toRemove = sortedEntries.length - _maxMemoryCacheSize;
    for (int i = 0; i < toRemove; i++) {
      _memoryCache.remove(sortedEntries[i].key);
    }
  }
}

/// Cache entry model
class _CacheEntry {
  final dynamic value;
  final DateTime expiresAt;
  
  _CacheEntry({
    required this.value,
    required this.expiresAt,
  });
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  Map<String, dynamic> toJson() => {
    'value': value,
    'expiresAt': expiresAt.toIso8601String(),
  };
  
  factory _CacheEntry.fromJson(Map<String, dynamic> json) => _CacheEntry(
    value: json['value'],
    expiresAt: DateTime.parse(json['expiresAt']),
  );
}

