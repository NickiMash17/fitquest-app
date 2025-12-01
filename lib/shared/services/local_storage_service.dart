import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

/// Service for local storage operations
@lazySingleton
class LocalStorageService {
  final Logger _logger = Logger();
  SharedPreferences? _prefs;

  /// Initialize the service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _logger.i('LocalStorageService initialized');
  }

  /// Get string value
  String? getString(String key) {
    return _prefs?.getString(key);
  }

  /// Set string value
  Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  /// Get int value
  int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  /// Set int value
  Future<bool> setInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }

  /// Get bool value
  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  /// Set bool value
  Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  /// Remove value
  Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  /// Clear all data
  Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }
}

