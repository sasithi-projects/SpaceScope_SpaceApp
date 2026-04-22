import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nasa_image.dart';

class ImageSearchService {
  Future<List<NasaImage>> searchImages(
    String query, {
    String mediaType = 'image',
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final uri = Uri.parse(
      'https://images-api.nasa.gov/search'
      '?q=${Uri.encodeComponent(trimmed)}'
      '&media_type=$mediaType',
    );//to convert a string url to a uri object(safer for http requests)

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('NASA search failed: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;//json object, key-value pairs
    final items = (decoded['collection']?['items'] as List?) ?? [];

    final results = items
        .map((item) => NasaImage.fromJson(item as Map<String, dynamic>))
        .where((img) => img.previewUrl != null) // filter broken entries
        .toList();

    return results;
  }
    Future<String?> getVideoUrl(String assetUrl) async {
    final response = await http.get(Uri.parse(assetUrl));

    if (response.statusCode != 200) return null;

    final decoded = jsonDecode(response.body);
    final items = decoded['collection']?['items'] as List?;

    if (items == null) return null;

    // Find first MP4
    for (final item in items) {
      final href = item['href'] as String;
      if (href.endsWith('.mp4')) {
        return href;
      }
    }

    return null;
  }
}
