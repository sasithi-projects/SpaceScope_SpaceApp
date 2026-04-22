import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/nasa_image.dart';

class StarredService {
  static const String _key = 'starred_items';

  // ───────── Get all starred items ─────────
  Future<List<NasaImage>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    return raw
        .map((s) =>
            NasaImage.fromMap(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  // ───────── Get count ─────────
  Future<int> count() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.length;
  }

  // ───────── Check starred by item ─────────
  Future<bool> isStarred(NasaImage item) async {
    final id = makeId(item);
    return isStarredById(id);
  }

  // ───────── Check starred by ID ─────────
  Future<bool> isStarredById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    return raw.any((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return makeIdFromMap(map) == id;
    });
  }

  // ───────── Toggle star ─────────
  Future<bool> toggle(NasaImage item) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    final id = makeId(item);

    final filtered = raw.where((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return makeIdFromMap(map) != id;
    }).toList();

    final wasStarred = filtered.length != raw.length;

   
    if (!wasStarred) {
      filtered.add(jsonEncode(item.toMap()));
    }

    await prefs.setStringList(_key, filtered);
    return !wasStarred;
  }

  Future<void> remove(NasaImage item) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final id = makeId(item);

    final filtered = raw.where((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return makeIdFromMap(map) != id;
    }).toList();

    await prefs.setStringList(_key, filtered);
  }

  // ───────── Clear ALL starred items (USED IN SETTINGS) ─────────
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(_key, []);
  }

  
  String makeId(NasaImage item) {
    final key =
        (item.previewUrl != null && item.previewUrl!.isNotEmpty)
            ? item.previewUrl!
            : item.title;

    return '${item.mediaType}|$key';
  }

  String makeIdFromMap(Map<String, dynamic> map) {
    final mediaType = (map['mediaType'] ?? 'image') as String;
    final previewUrl = map['previewUrl'] as String?;
    final title = (map['title'] ?? '') as String;

    final key =
        (previewUrl != null && previewUrl.isNotEmpty) ? previewUrl : title;

    return '$mediaType|$key';
  }
}