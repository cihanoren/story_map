import 'package:google_maps_flutter/google_maps_flutter.dart';

class Story {
  final String id;
  final String title;
  final String description;
  final LatLng location;

  Story({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
  });
}
