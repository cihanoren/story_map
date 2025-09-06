import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PredefinedMarkers {
  static Future<List<Map<String, dynamic>>> loadMarkers() async {
    // Hangi json dosyalarını okuyacağını burada listele
    final files = [
      "assets/json/markers_tr.json",
      "assets/json/markers_it.json",
      "assets/json/markers_fr.json",
      "assets/json/markers_uk.json",
      "assets/json/markers_de.json",
      "assets/json/markers_es.json",
      // yeni dosya eklemek istersen buraya yaz
    ];

    List<Map<String, dynamic>> allMarkers = [];

    for (final file in files) {
      final String jsonString = await rootBundle.loadString(file);
      final List<dynamic> jsonData = json.decode(jsonString);

      final markers = jsonData.map<Map<String, dynamic>>((marker) {
        final lat = (marker['position']['lat']).toDouble();
        final lng = (marker['position']['lng']).toDouble();

        return {
          "position": LatLng(lat, lng),
          "title": marker['title'],
          "image": marker['image'],
          "iconPath": marker['iconPath'],
        };
      }).toList();

      allMarkers.addAll(markers);
    }

    return allMarkers;
  }
}
