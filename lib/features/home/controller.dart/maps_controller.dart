import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:story_map/features/home/controller.dart/predefined_markers.dart';
import 'package:story_map/features/home/views/bottom_sheet.dart';
import 'package:story_map/main.dart';
import 'package:story_map/utils/marker_icons.dart'; // ✅ MarkerIcons'ı ekliyoruz

final mapControllerProvider =
    StateNotifierProvider<MapController, Map<String, dynamic>>((ref) {
  return MapController();
});

class MapController extends StateNotifier<Map<String, dynamic>> {
  GoogleMapController? _googleMapController;

  MapController()
      : super({
          'location': null,
          'markers': <Marker>{},
        }) {
    _determinePosition();
    _initializeMarkers();
  }

  void setMapController(GoogleMapController controller) {
    _googleMapController = controller;
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    LatLng currentLocation = LatLng(position.latitude, position.longitude);

    state = {
      'location': currentLocation,
      'markers': state['markers'],
    };

    moveToCurrentLocation();
  }

  void moveToCurrentLocation() {
    if (_googleMapController != null && state['location'] != null) {
      _googleMapController!.animateCamera(
        CameraUpdate.newLatLngZoom(state['location'], 15.0),
      );
    }
  }

  void _initializeMarkers() async {
    // İkonları yüklemeden önce loadIcons çağırılıyor
    await MarkerIcons.loadIcons();

    for (var markerData in PredefinedMarkers.markers) {
      await addMarker(
        markerData['position'],
        markerData['title'],
        markerData['image'],
        markerData['iconPath'],
      );
    }
  }

  Future<void> addMarker(
      LatLng position, String title, String imageUrl, String iconPath) async {
    final markers = Set<Marker>.from(state['markers']);
    BitmapDescriptor customIcon;

    // İkonları MarkerIcons'dan alıyoruz
    if (iconPath == 'assets/markers/church.png') {
      customIcon = MarkerIcons.churchIcon!;
    } else if (iconPath == 'assets/markers/cave.png') {
      customIcon = MarkerIcons.caveIcon!;
    } else if (iconPath == 'assets/markers/palace.png') {
      customIcon = MarkerIcons.palaceIcon!;
    } else if (iconPath == 'assets/markers/castle.png') {
      customIcon = MarkerIcons.castleIcon!;
    } else if (iconPath == 'assets/markers/mosque.png') {
      customIcon = MarkerIcons.mosqueIcon!;
    } else if (iconPath == 'assets/markers/museum.png') {
      customIcon = MarkerIcons.museumIcon!;
    } else if (iconPath == 'assets/markers/tomb.png') {
      customIcon = MarkerIcons.tombIcon!;
    } else if (iconPath == 'assets/markers/park.png') {
      customIcon = MarkerIcons.parkIcon!;
    } else if (iconPath == 'assets/markers/theatre.png') {
      customIcon = MarkerIcons.theatreIcon!;
    } else if (iconPath == 'assets/markers/bridge.png') {
      customIcon = MarkerIcons.bridgeIcon!;
    } else if (iconPath == 'assets/markers/lake.png') {
      customIcon = MarkerIcons.lakeIcon!;
    } else if (iconPath == 'assets/markers/mountain.png') {
      customIcon = MarkerIcons.mountainIcon!;
    } else if (iconPath == 'assets/markers/ruins.png') {
      customIcon = MarkerIcons.ruinsIcon!;
    } else if (iconPath == 'assets/markers/tower.png') {
      customIcon = MarkerIcons.towerIcon!;
    } else if (iconPath == 'assets/markers/national_park.png') {
      customIcon = MarkerIcons.national_parkIcon!;
    } else if (iconPath == 'assets/markers/temple.png') {
      customIcon = MarkerIcons.templeIcon!;
    } else if (iconPath == 'assets/markers/memorial.png') {
      customIcon = MarkerIcons.memorialIcon!;
    } else if (iconPath == 'assets/markers/monument.png') {
      customIcon = MarkerIcons.monumentIcon!;
    } else {
      // Varsayılan bir ikon kullanabiliriz
      customIcon = await MarkerIcons.getBitmapDescriptor(iconPath);
    }

    markers.add(
      Marker(
        markerId: MarkerId(position.toString()),
        position: position,
        icon: customIcon,
        infoWindow: InfoWindow(title: title),
        onTap: () {
          _showBottomSheet(title, imageUrl);
        },
      ),
    );

    state = {
      'location': state['location'],
      'markers': markers,
    };
  }

  void _showBottomSheet(String title, String imageUrl) {
    final context = navigatorKey.currentContext;
    if (context == null || _googleMapController == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: StoryBottomSheet(
                title: title,
                imagePath: imageUrl,
              ),
            );
          },
        );
      },
    );
  }

  void loadMarkers() {
    _initializeMarkers();
  }

  Future<List<LatLng>> createShortestPath(int locationCount,
      {String travelMode = 'walking'}) async {
    final currentLocation = state['location'] as LatLng?;
    final markers = state['markers'] as Set<Marker>;

    if (currentLocation == null || markers.isEmpty) {
      return [];
    }

    List<LatLng> path = [];
    Set<Marker> remainingMarkers = {...markers};

    LatLng currentPoint = currentLocation;

    // Başlangıç konumunu path'e ekleyelim
    path.add(currentPoint);

    for (int i = 0; i < locationCount; i++) {
      if (remainingMarkers.isEmpty) break;

      Marker? nearestMarker;
      double minDistance = double.infinity;

      for (var marker in remainingMarkers) {
        double distance = _calculateDistance(
          currentPoint.latitude,
          currentPoint.longitude,
          marker.position.latitude,
          marker.position.longitude,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearestMarker = marker;
        }
      }

      if (nearestMarker != null) {
        path.add(nearestMarker.position);
        currentPoint = nearestMarker.position;
        remainingMarkers.remove(nearestMarker);
      }
    }

    return path;
  }

  /// İki koordinat arasındaki mesafeyi hesaplayan fonksiyon (Haversine Formula)
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000; // metre cinsinden
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadius * c;

    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Gerçek bir rota oluşturma fonksiyonu
  Future<void> createRealPath(int locationCount, String apiKey,
      {String travelMode = 'walking'}) async {
    final currentLocation = state['location'] as LatLng?;
    final markers = state['markers'] as Set<Marker>;

    if (currentLocation == null || markers.isEmpty) return;

    List<LatLng> path = [];
    Set<Marker> remainingMarkers = {...markers};

    LatLng currentPoint = currentLocation;

    for (int i = 0; i < locationCount; i++) {
      if (remainingMarkers.isEmpty) break;

      Marker? nearestMarker;
      double minDistance = double.infinity;

      for (var marker in remainingMarkers) {
        double distance = _calculateDistance(
          currentPoint.latitude,
          currentPoint.longitude,
          marker.position.latitude,
          marker.position.longitude,
        );
        if (distance < minDistance) {
          minDistance = distance;
          nearestMarker = marker;
        }
      }

      if (nearestMarker != null) {
        path.add(nearestMarker.position);
        currentPoint = nearestMarker.position;
        remainingMarkers.remove(nearestMarker);
      }
    }

    if (path.isNotEmpty) {
      await _drawRouteWithDirections(currentLocation, path, apiKey, travelMode);
    }
  }

// Google Directions API ile rota çizen fonksiyon
  Future<void> _drawRouteWithDirections(LatLng start, List<LatLng> destinations,
      String apiKey, String travelMode) async {
    List<LatLng> fullPath = [];

    LatLng currentStart = start;
    for (var dest in destinations) {
      final route =
          await _getRouteFromApi(currentStart, dest, apiKey, travelMode);
      fullPath.addAll(route);
      currentStart = dest;
    }

    final markers = state['markers'];

    final newPolyline = Polyline(
      polylineId: const PolylineId('route'),
      points: fullPath,
      color: Colors.blueAccent,
      width: 5,
    );

    state = {
      'location': state['location'],
      'markers': markers,
      'polyline': newPolyline, // yeni polyline ekledik
    };
  }

// Directions API'den veri çekiyoruz
  Future<List<LatLng>> _getRouteFromApi(LatLng origin, LatLng destination,
      String apiKey, String travelMode) async {
    final url = "https://maps.googleapis.com/maps/api/directions/json"
        "?origin=${origin.latitude},${origin.longitude}"
        "&destination=${destination.latitude},${destination.longitude}"
        "&mode=$travelMode"
        "&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // --- Buraya kontrol ekliyoruz ---
      if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
        final points = data['routes'][0]['overview_polyline']['points'];
        return _decodePolyline(points);
      } else {
        print(
            'Directions API: No route found between ${origin.latitude},${origin.longitude} and ${destination.latitude},${destination.longitude}');
        print('Fetching route: $url');
        return [];
      }
    } else {
      print('Directions API Error: ${response.body}');
      return [];
    }
  }

// Polyline verisini decode eden fonksiyon
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }
}
