import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';

class AsteroidService {

  Future<List<Map<String, dynamic>>> fetchAsteroids(DateTime date) async {
    if (kIsWeb) {
      return _mockAsteroids();
    } else {
      return _fetchFromNasa(date);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchFromNasa(DateTime date) async {
    final startDate =
        '${date.year}-${_two(date.month)}-${_two(date.day)}';

    final uri = Uri.parse(
      'https://api.nasa.gov/neo/rest/v1/feed'
      '?start_date=$startDate'
      '&end_date=$startDate'
      '&api_key=${ApiConstants.nasaApiKey}',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load asteroid data');
    }

    final decoded = jsonDecode(response.body);

    
    final neoMap =
        decoded['near_earth_objects'] as Map<String, dynamic>?;

    if (neoMap == null || !neoMap.containsKey(startDate)) {
      
      return [];
    }

    final nearEarthObjects =
        neoMap[startDate] as List<dynamic>? ?? [];

    if (nearEarthObjects.isEmpty) {
      return [];
    }

    return nearEarthObjects.map<Map<String, dynamic>>((a) {
      final approachList = a['close_approach_data'] as List?;

      if (approachList == null || approachList.isEmpty) {
        return {};
      }

      final approach = approachList[0];

      return {
        'name': a['name'] ?? 'Unknown',

        'date': approach['close_approach_date'] ?? 'N/A',

        'distance':
            '${double.tryParse(approach['miss_distance']?['kilometers'] ?? '0')?.toStringAsFixed(0) ?? '0'} km',

        'size':
            '${(((a['estimated_diameter']?['meters']?['estimated_diameter_min'] ?? 0) +
                        (a['estimated_diameter']?['meters']?['estimated_diameter_max'] ?? 0)) /
                    2)
                .toStringAsFixed(0)} m',

        'hazardous':
            a['is_potentially_hazardous_asteroid'] ?? false,

        
        'reminder': false,
      };
    }).where((e) => e.isNotEmpty).toList(); 
  }

  /// ─────────────────────────────────────────────
  /// MOCK DATA (web & testing)
  /// ─────────────────────────────────────────────

  List<Map<String, dynamic>> _mockAsteroids() {
    return [
      {
        'name': '2026 AB',
        'date': '2026-02-14',
        'distance': '384,000 km',
        'size': '420 m',
        'hazardous': false,
        'reminder': false,
      },
      {
        'name': 'Apophis',
        'date': '2029-04-13',
        'distance': '31,000 km',
        'size': '370 m',
        'hazardous': true,
        'reminder': true,
      },
      {
        'name': '2024 QX',
        'date': '2024-11-02',
        'distance': '1.2 million km',
        'size': '180 m',
        'hazardous': false,
        'reminder': false,
      },
    ];
  }

  /// Helper
  String _two(int n) => n.toString().padLeft(2, '0');
}