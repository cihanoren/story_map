import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PredefinedMarkers {
  static Future<List<Map<String, dynamic>>> loadMarkers() async {
    final String jsonString = await rootBundle.loadString('assets/markers.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    // Gerekirse burada LatLng objelerine dönüştürülmüş marker'lar oluşturabilirsiniz
    return jsonData.map<Map<String, dynamic>>((marker) {
      final lat = marker['position']['lat'];
      final lng = marker['position']['lng'];
      return {
        "position": LatLng(lat, lng),
        "title": marker['title'],
        "image": marker['image'],
        "iconPath": marker['iconPath'],
      };
    }).toList();
  }
}
