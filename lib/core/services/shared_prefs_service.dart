import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/checklist_item.dart';
import '../constants/mock_data.dart';

class SharedPrefsService {
  static const String _keySelectedCountryCode = 'selected_country_code';
  static const String _keyChecklist = 'ozvisa_checklist_items';
  static const String _keyDemoModeStatus = 'demo_mode_open_status';

  Future<String> getSelectedCountryCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedCountryCode) ?? 'ES'; // España por defecto
  }

  Future<void> saveSelectedCountryCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedCountryCode, code);
  }

  Future<List<ChecklistItem>> getChecklist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyChecklist);
    if (jsonString == null || jsonString.isEmpty) {
      return MockData.initialChecklist;
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => ChecklistItem.fromMap(e)).toList();
    } catch (e) {
      return MockData.initialChecklist;
    }
  }

  Future<void> saveChecklist(List<ChecklistItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> maps = items.map((e) => e.toMap()).toList();
    await prefs.setString(_keyChecklist, jsonEncode(maps));
  }

  Future<bool?> getDemoModeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDemoModeStatus);
  }

  Future<void> setDemoModeStatus(bool isOpen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDemoModeStatus, isOpen);
  }
}
