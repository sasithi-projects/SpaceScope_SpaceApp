import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderService {
  static const String _key = 'asteroid_reminders';

  // ───────── Get all reminders ─────────
  Future<List<Map<String, dynamic>>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    return raw
        .map((s) => jsonDecode(s) as Map<String, dynamic>)
        .toList();
  }

  // ───────── Get count  ─────────
  Future<int> count() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.length;
  }

  // ───────── Check if reminder exists ─────────
  Future<bool> isSaved(Map<String, dynamic> asteroid) async {
    final id = makeId(asteroid);
    final all = await getAll();

    return all.any((a) => makeId(a) == id);
  }

  // ───────── Toggle reminder ─────────
  Future<bool> toggle(Map<String, dynamic> asteroid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    final id = makeId(asteroid);

    final filtered = raw.where((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return makeId(map) != id;
    }).toList();

    final wasSaved = filtered.length != raw.length;

   
    if (!wasSaved) {
      filtered.add(jsonEncode(asteroid));
    }

    await prefs.setStringList(_key, filtered);
    return !wasSaved;
  }

 
  Future<void> remove(Map<String, dynamic> asteroid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    final id = makeId(asteroid);

    final filtered = raw.where((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return makeId(map) != id;
    }).toList();

    await prefs.setStringList(_key, filtered);
  }

  // ───────── Clear ALL reminders (USED IN SETTINGS) ─────────
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(_key, []);
  }

  String makeId(Map<String, dynamic> asteroid) {
    return '${asteroid['name']}|${asteroid['date']}';
  }
}