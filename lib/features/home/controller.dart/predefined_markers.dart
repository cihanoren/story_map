import 'package:google_maps_flutter/google_maps_flutter.dart';

class PredefinedMarkers {
  static List<Map<String, dynamic>> markers = [
    {
      'position': LatLng(41.008469, 28.980261),
      'title': "Ayasofya",
      'image': "https://storymap-images.s3.us-east-1.amazonaws.com/ayasofya.png"
    },
    {
      'position': LatLng(41.0055, 28.9769),
      'title': "Topkapı Sarayı",
      'image': "https://storymap-images.s3.us-east-1.amazonaws.com/topkapi.png"
    },
    {
      'position': LatLng(41.4460, 31.7890), // Gökgöl Mağarası koordinatları
      'title': "Gökgöl Mağarası",
      'image': "https://storymap-images.s3.us-east-1.amazonaws.com/gokgol.jpg" // AWS S3 URL
    }
  ];
}
