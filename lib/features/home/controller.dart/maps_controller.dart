import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:story_map/features/home/controller.dart/predefined_markers.dart';
import 'package:story_map/features/home/models.dart/route_model.dart';
import 'package:story_map/features/home/services.dart/route_service.dart';
import 'package:story_map/features/home/views/bottom_sheet.dart';
import 'package:story_map/main.dart';
import 'package:story_map/utils/marker_icons.dart';

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
    final context = navigatorKey.currentContext;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context != null) {
        _showDialog(
          context: context,
          title: 'Konum Servisi Kapalı',
          content: 'Konum servisleri kapalı. Lütfen cihaz ayarlarından açın.',
          actionText: 'Ayarlar',
          onPressed: () => Geolocator.openLocationSettings(),
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context != null) {
          _showDialog(
            context: context,
            title: 'İzin Gerekli',
            content: 'Uygulamanın konum iznine ihtiyacı var.',
            actionText: 'Tamam',
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context != null) {
        _showDialog(
          context: context,
          title: 'İzin Verilmedi',
          content:
              'Konum izni kalıcı olarak reddedilmiş. Ayarlardan manuel olarak izin verin.',
          actionText: 'Ayarlar',
          onPressed: () => Geolocator.openAppSettings(),
        );
      }
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      LatLng currentLocation = LatLng(position.latitude, position.longitude);

      state = {
        'location': currentLocation,
        'markers': state['markers'],
        'isTourActive': state['isTourActive'] ?? false,
      };

      moveToCurrentLocation();
    } catch (e) {
      if (context != null) {
        _showDialog(
          context: context,
          title: 'Konum Hatası',
          content: 'Konum alınırken bir hata oluştu. Lütfen tekrar deneyin.',
          actionText: 'Tamam',
        );
      }
    }
  }

  void _showDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String actionText,
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: Text(actionText),
            onPressed: () {
              Navigator.of(context).pop();
              if (onPressed != null) onPressed();
            },
          ),
        ],
      ),
    );
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

    // JSON verisini assets/markers.json'dan oku
    List<Map<String, dynamic>> markers = await PredefinedMarkers.loadMarkers();

    // Markerları ekleyin
    for (var markerData in markers) {
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

    switch (iconPath) {
      case 'assets/markers/church.png':
        customIcon = MarkerIcons.churchIcon!;
        break;
      case 'assets/markers/cave.png':
        customIcon = MarkerIcons.caveIcon!;
        break;
      case 'assets/markers/palace.png':
        customIcon = MarkerIcons.palaceIcon!;
        break;
      case 'assets/markers/castle.png':
        customIcon = MarkerIcons.castleIcon!;
        break;
      case 'assets/markers/mosque.png':
        customIcon = MarkerIcons.mosqueIcon!;
        break;
      case 'assets/markers/museum.png':
        customIcon = MarkerIcons.museumIcon!;
        break;
      case 'assets/markers/tomb.png':
        customIcon = MarkerIcons.tombIcon!;
        break;
      case 'assets/markers/park.png':
        customIcon = MarkerIcons.parkIcon!;
        break;
      case 'assets/markers/theatre.png':
        customIcon = MarkerIcons.theatreIcon!;
        break;
      case 'assets/markers/bridge.png':
        customIcon = MarkerIcons.bridgeIcon!;
        break;
      case 'assets/markers/lake.png':
        customIcon = MarkerIcons.lakeIcon!;
        break;
      case 'assets/markers/mountain.png':
        customIcon = MarkerIcons.mountainIcon!;
        break;
      case 'assets/markers/ruins.png':
        customIcon = MarkerIcons.ruinsIcon!;
        break;
      case 'assets/markers/tower.png':
        customIcon = MarkerIcons.towerIcon!;
        break;
      case 'assets/markers/national_park.png':
        customIcon = MarkerIcons.national_parkIcon!;
        break;
      case 'assets/markers/temple.png':
        customIcon = MarkerIcons.templeIcon!;
        break;
      case 'assets/markers/memorial.png':
        customIcon = MarkerIcons.memorialIcon!;
        break;
      case 'assets/markers/monument.png':
        customIcon = MarkerIcons.monumentIcon!;
        break;
      default:
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
      'isTourActive': state['isTourActive'] ?? false, // <-- EKLE
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

    if (currentLocation == null || markers.isEmpty) return [];

    List<LatLng> path = [currentLocation];
    List<String> addedMarkerIds = [];

    Set<Marker> remainingMarkers = {...markers};
    LatLng currentPoint = currentLocation;

    for (int i = 0; i < locationCount; i++) {
      if (remainingMarkers.isEmpty) break;

      Marker? nearestMarker;
      double minDistance = double.infinity;

      for (var marker in remainingMarkers) {
        if (addedMarkerIds.contains(marker.markerId.value)) continue;

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
        addedMarkerIds.add(nearestMarker.markerId.value);
        currentPoint = nearestMarker.position;
        remainingMarkers.remove(nearestMarker);
      }
    }

    setTourPath(
      path,
      path.map((point) {
        final marker = markers.firstWhere(
          (m) => m.position == point,
          orElse: () => Marker(markerId: MarkerId('')),
        );
        return marker.infoWindow.title ?? 'Başlangıç Noktası';
      }).toList(),
    );

    return path;
  }

  /// Tur rotasını döndüren fonksiyon
  List<String> getTourTitles() => _tourTitles;

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
      'isTourActive': state['isTourActive'] ?? false, // <-- EKLE
    };
  }

// Directions API'den veri çekiyoruz
  Future<List<LatLng>> _getRouteFromApi(
    LatLng origin, LatLng destination, String apiKey, String travelMode) async {
  // İnternet bağlantısı kontrolü
  final hasConnection = await _checkInternetConnection();
  if (!hasConnection) {
    if (navigatorKey.currentContext != null) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text("İnternet bağlantısı yok. Rota oluşturulamadı."),
        ),
      );
    }
    return [];
  }

  final url = "https://maps.googleapis.com/maps/api/directions/json"
      "?origin=${origin.latitude},${origin.longitude}"
      "&destination=${destination.latitude},${destination.longitude}"
      "&mode=$travelMode"
      "&key=$apiKey";

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
        final points = data['routes'][0]['overview_polyline']['points'];
        return _decodePolyline(points);
      } else {
        print("Google API route not found.");
        return [];
      }
    } else {
      print("Google API HTTP error: ${response.statusCode}");
      return [];
    }
  } catch (e) {
    print("Google API exception: $e");
    return [];
  }
}

// İnternet bağlantısını kontrol eden fonksiyon
Future<bool> _checkInternetConnection() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}



// Zoom in ve zoom out fonksiyonları
  double _currentZoom = 15;

  void zoomIn() {
    _currentZoom += 1;
    _googleMapController?.animateCamera(
      CameraUpdate.zoomTo(_currentZoom),
    );
  }

  void zoomOut() {
    _currentZoom -= 1;
    _googleMapController?.animateCamera(
      CameraUpdate.zoomTo(_currentZoom),
    );
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

  List<LatLng> _tourPath = [];
  List<String> _tourTitles = [];

  void startTour() {
    state = {
      ...state,
      'isTourActive': true,
    };
  }

  void endTour() {
    _tourPath.clear();
    _tourTitles.clear();
    state = {
      ...state,
      'isTourActive': false,
      'polyline': null,
    };
  }

  /// Tur rotasını saklamak için çağrılır
  void setTourPath(List<LatLng> path, List<String> titles) {
    _tourPath = path;
    _tourTitles = titles;
  }

  Future<Map<String, String>> loadMarkerImages() async {
    final String jsonStr = await rootBundle.loadString('assets/markers.json');
    final List<dynamic> jsonList = json.decode(jsonStr);

    // title -> image URL eşlemesi
    return {
      for (var item in jsonList)
        if (item['title'] != null && item['image'] != null)
          item['title']: item['image']
    };
  }

  Future<void> saveCurrentRoute({
    String? customTitle,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final imageMap = await loadMarkerImages();

    final places = _tourPath
        .asMap()
        .map((index, e) {
          final title = _tourTitles[index];
          return MapEntry(
            index,
            Place(
              name: title,
              image: imageMap[title] ?? '',
              lat: e.latitude,
              lng: e.longitude,
            ),
          );
        })
        .values
        .toList();

    final route = RouteModel(
      id: '',
      userId: userId,
      title: customTitle ?? 'İsimsiz Rota',
      description: _tourTitles.join(' - '),
      places: places,
      mode:
          _selectedTravelMode, // 👈 burada artık kayıtlı olan travel mode kullanılıyor
      isShared: false,
      createdAt: Timestamp.now(),
    );

    await _routeService.saveRoute(route);
  }

  final RouteService _routeService = RouteService();

  String _selectedTravelMode = 'walking';

  void setTravelMode(String mode) {
    _selectedTravelMode = mode;
  }

  String get selectedTravelMode => _selectedTravelMode;
}
