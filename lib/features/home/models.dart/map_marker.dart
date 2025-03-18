import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarker {
  final String id;
  final String title;
  final String description;
  final LatLng position;

  MapMarker({
    required this.id,
    required this.title,
    required this.description,
    required this.position,
  });
}
