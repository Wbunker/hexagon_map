import 'dart:convert';

import 'package:flutter/services.dart';

class HexMapData {
  final String assetPath;
  Map<String, Map<String, String>> _mapData = {};
  HexMapData(this.assetPath);

  Future<Map<String, Map<String, String>>> fetchMapData() async {
    final String response = await rootBundle.loadString(assetPath);
    final Map<String, dynamic> jsonData = json.decode(response);
    final List<dynamic> tilemap = jsonData['tilemap'];
    final Map<String, Map<String, String>> mapData = {};

    for (var item in tilemap) {
      final List<dynamic> coordinates = item['coordinates'];
      final String key = '${coordinates[0]},${coordinates[1]}';
      mapData[key] = {
        'terrain': item['terrain'],
        'hex_art': item['hex_art'],
      };
    }

    _mapData = mapData;
    return mapData;
  }

  Map<String, Map<String, String>> get mapData => _mapData;

  int get minX {
    return _mapData.keys
        .map((key) => int.parse(key.split(',')[0]))
        .reduce((a, b) => a < b ? a : b);
  }

  int get maxX {
    return _mapData.keys
        .map((key) => int.parse(key.split(',')[0]))
        .reduce((a, b) => a > b ? a : b);
  }

  int get minY {
    return _mapData.keys
        .map((key) => int.parse(key.split(',')[1]))
        .reduce((a, b) => a < b ? a : b);
  }

  int get maxY {
    return _mapData.keys
        .map((key) => int.parse(key.split(',')[1]))
        .reduce((a, b) => a > b ? a : b);
  }
}
