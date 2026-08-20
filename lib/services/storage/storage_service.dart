// lib/services/storage/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String KEY_BATTERY_PERCENTAGE = 'battery_percentage';
  static const String KEY_CURRENT_VERSION = 'current_version';
  static const String KEY_NEW_VERSION = 'new_version';
  static const String KEY_DEVICE_NAME = 'device_name';
  static const String KEY_LAST_CONNECTED = 'last_connected';

  static const String KEY_DOUBLE_TAP = 'double_tap';
  static const String KEY_TRIPLE_PRESS = 'triple_tap';
  static const String KEY_SWIPE_UP_THREE_SEC = 'swipe_up_three_sec';
  static const String KEY_SWIPE_DOWN_THREE_SEC = 'swipe_down_three_sec';
  static const String KEY_SWIPE_LEFT_THREE_SEC = 'swipe_left_three_sec';
  static const String KEY_SWIPE_RIGHT_THREE_SEC = 'swipe_right_three_sec';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 电池电量
  Future<void> saveBatteryPercentage(int value) async {
    await _prefs.setInt(KEY_BATTERY_PERCENTAGE, value);
  }

  int getBatteryPercentage() {
    return _prefs.getInt(KEY_BATTERY_PERCENTAGE) ?? 0;
  }

  // 当前版本
  Future<void> saveCurrentVersion(String value) async {
    await _prefs.setString(KEY_CURRENT_VERSION, value);
  }

  String getCurrentVersion() {
    return _prefs.getString(KEY_CURRENT_VERSION) ?? "1.0.0";
  }

  // 新版本
  Future<void> saveNewVersion(String value) async {
    await _prefs.setString(KEY_NEW_VERSION, value);
  }

  String getNewVersion() {
    return _prefs.getString(KEY_NEW_VERSION) ?? "";
  }

  // 设备名称
  Future<void> saveDeviceName(String value) async {
    await _prefs.setString(KEY_DEVICE_NAME, value);
  }

  String getDeviceName() {
    return _prefs.getString(KEY_DEVICE_NAME) ?? "Unknown Device";
  }

  // 最后连接状态
  Future<void> saveLastConnected(bool value) async {
    await _prefs.setBool(KEY_LAST_CONNECTED, value);
  }

  bool getLastConnected() {
    return _prefs.getBool(KEY_LAST_CONNECTED) ?? false;
  }

  Future<void> saveDoubleTap(String value) async {
    await _prefs.setString(KEY_DOUBLE_TAP, value);
  }

  String getDoubleTap() {
    return _prefs.getString(KEY_DOUBLE_TAP) ?? "";
  }

  Future<void> saveTripleTap(String value) async {
    await _prefs.setString(KEY_TRIPLE_PRESS, value);
  }

  String getTripleTap() {
    return _prefs.getString(KEY_TRIPLE_PRESS) ?? "";
  }

  Future<void> saveSwipeUpThreeSec(String value) async {
    await _prefs.setString(KEY_SWIPE_UP_THREE_SEC, value);
  }

  String getSwipeUpThreeSec() {
    return _prefs.getString(KEY_SWIPE_UP_THREE_SEC) ?? "";
  }

  Future<void> saveSwipeDownThreeSec(String value) async {
    await _prefs.setString(KEY_SWIPE_DOWN_THREE_SEC, value);
  }

  String getSwipeDownThreeSec() {
    return _prefs.getString(KEY_SWIPE_DOWN_THREE_SEC) ?? "";
  }

  Future<void> saveSwipeLeftThreeSec(String value) async {
    await _prefs.setString(KEY_SWIPE_LEFT_THREE_SEC, value);
  }

  String getSwipeLeftThreeSec() {
    return _prefs.getString(KEY_SWIPE_LEFT_THREE_SEC) ?? "";
  }

  Future<void> saveSwipeRightThreeSec(String value) async {
    await _prefs.setString(KEY_SWIPE_RIGHT_THREE_SEC, value);
  }

  String getSwipeRightThreeSec() {
    return _prefs.getString(KEY_SWIPE_RIGHT_THREE_SEC) ?? "";
  }

  // 清除所有数据
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}