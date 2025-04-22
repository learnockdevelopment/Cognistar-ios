import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setEnableSignup(bool value) async {
    await _prefs?.setBool('enable_signup', value);
  }

  Future<void> saveCourseVideos(List<String> videoUrls) async {
    await StorageService.set("course_videos", videoUrls);
  }

  static bool getEnableSignup() {
    return _prefs?.getBool('enable_signup') ?? false;
  }

  static Future<void> setCanPurchase(bool value) async {
    await _prefs?.setBool('can_purchase', value);
  }

  static bool getCanPurchase() {
    return _prefs?.getBool('can_purchase') ?? false;
  }

  static Future<void> setUserMultiCurrency(bool value) async {
    await _prefs?.setBool('user_multi_currency', value);
  }

  static Future<void> setWhatsAppNumber(bool value) async {
    await _prefs?.setBool('whatsapp_floating_button', value);
  }

  static bool getUserMultiCurrency() {
    return _prefs?.getBool('user_multi_currency') ?? false;
  }

  static Future<String?> getWhatsAppNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('whatsapp_floating_button');
  }

  static Future<void> set(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(value));
  }

  static Future<dynamic> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);
    return data != null ? jsonDecode(data) : null;
  }
}
