import 'package:shared_preferences/shared_preferences.dart';

/// Service for shared preferences operations
class SharedPrefsService {
  static final SharedPrefsService _instance = SharedPrefsService._internal();
  factory SharedPrefsService() => _instance;
  SharedPrefsService._internal();

  SharedPreferences? _prefs;

  /// Initialize shared preferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Write string to shared preferences
  Future<bool> writeString(String key, String value) async {
    await init();
    return await _prefs!.setString(key, value);
  }

  /// Read string from shared preferences
  String? readString(String key) {
    return _prefs?.getString(key);
  }

  /// Write int to shared preferences
  Future<bool> writeInt(String key, int value) async {
    await init();
    return await _prefs!.setInt(key, value);
  }

  /// Read int from shared preferences
  int? readInt(String key) {
    return _prefs?.getInt(key);
  }

  /// Write bool to shared preferences
  Future<bool> writeBool(String key, bool value) async {
    await init();
    return await _prefs!.setBool(key, value);
  }

  /// Read bool from shared preferences
  bool? readBool(String key) {
    return _prefs?.getBool(key);
  }

  /// Write double to shared preferences
  Future<bool> writeDouble(String key, double value) async {
    await init();
    return await _prefs!.setDouble(key, value);
  }

  /// Read double from shared preferences
  double? readDouble(String key) {
    return _prefs?.getDouble(key);
  }

  /// Write string list to shared preferences
  Future<bool> writeStringList(String key, List<String> value) async {
    await init();
    return await _prefs!.setStringList(key, value);
  }

  /// Read string list from shared preferences
  List<String>? readStringList(String key) {
    return _prefs?.getStringList(key);
  }

  /// Remove key from shared preferences
  Future<bool> remove(String key) async {
    await init();
    return await _prefs!.remove(key);
  }

  /// Clear all shared preferences
  Future<bool> clear() async {
    await init();
    return await _prefs!.clear();
  }

  /// Check if key exists in shared preferences
  bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }
}
