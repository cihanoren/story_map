import 'package:google_maps_flutter/google_maps_flutter.dart';

class PredefinedMarkers {
  static List<Map<String, dynamic>> markers = [
    {
      'position': LatLng(41.008469, 28.980261),
      'title': "Ayasofya",
      'image': "assets/images/ayasofya.png"
    },
    {
      'position': LatLng(41.0055, 28.9769),
      'title': "Topkapı Sarayı",
      'image': "assets/images/topkapi.png"
    }
  ];
}
