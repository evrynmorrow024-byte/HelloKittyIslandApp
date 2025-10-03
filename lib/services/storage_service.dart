import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  Future<void> setString(String key, String value) async {
    await _prefs!.setString(key, value);
  }

  String? getString(String key) => _prefs!.getString(key);

  Future<void> setStringList(String key, List<String> value) async {
    await _prefs!.setStringList(key, value);
  }

  List<String>? getStringList(String key) => _prefs!.getStringList(key);

  Future<void> setBool(String key, bool value) async {
    await _prefs!.setBool(key, value);
  }

  bool? getBool(String key) => _prefs!.getBool(key);

  Future<void> setInt(String key, int value) async {
    await _prefs!.setInt(key, value);
  }

  int? getInt(String key) => _prefs!.getInt(key);

  Future<void> remove(String key) async {
    await _prefs!.remove(key);
  }

  Future<void> clear() async {
    await _prefs!.clear();
  }

  Future<void> setJson(String key, Map<String, dynamic> value) async {
    await setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? getJson(String key) {
    final jsonString = getString(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> setJsonList(String key, List<Map<String, dynamic>> value) async {
    await setString(key, jsonEncode(value));
  }

  List<Map<String, dynamic>>? getJsonList(String key) {
    final jsonString = getString(key);
    if (jsonString != null) {
      try {
        final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
        return list.cast<Map<String, dynamic>>();
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}