import 'dart:convert';
import 'package:http/http.dart' as http;

class EarthEpicService {
  // Direct EPIC backend 
  static const String _baseApi =
      'https://epic.gsfc.nasa.gov/api';

  static const String _baseArchive =
      'https://epic.gsfc.nasa.gov/archive';

  static const bool debugApi = true;

  // ───────────────── Images by date ─────────────────
  Future<List<Map<String, dynamic>>> fetchByDate(String date) async {
    final uri = Uri.parse(
      '$_baseApi/natural/date/$date',
    );

    if (debugApi) {
      print(' EPIC REQUEST → $uri');
    }

    final response = await http.get(uri);

    if (debugApi) {
      print(' STATUS CODE → ${response.statusCode}');
      print(' RAW BODY → ${response.body}');
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to load EPIC data for $date');
    }

    final List<dynamic> data = jsonDecode(response.body);

    if (debugApi) {
      print(' IMAGE COUNT → ${data.length}');
    }

    return data
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // ───────────────── Image URL builder ─────────────────
  String buildImageUrl(Map<String, dynamic> item) {
    final date = item['date'].split(' ').first; // yyyy-MM-dd
    final parts = date.split('-');

    final url =
        '$_baseArchive/natural/'
        '${parts[0]}/${parts[1]}/${parts[2]}/png/'
        '${item['image']}.png';

    if (debugApi) {
      print(' IMAGE URL → $url');
    }

    return url;
  }
}