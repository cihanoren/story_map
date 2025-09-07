import 'dart:convert';
import 'dart:isolate';
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
import 'package:story_map/features/home/services.dart/InterstitialAdManager.dart';
import 'package:story_map/features/home/services.dart/route_service.dart';
import 'package:story_map/features/home/views/bottom_sheet.dart';
import 'package:story_map/l10n/app_localizations.dart';
import 'package:story_map/main.dart';
import 'package:story_map/utils/marker_icons.dart';

final mapControllerProvider =
    StateNotifierProvider<MapController, Map<String, dynamic>>((ref) {
  return MapController();
});

class MapController extends StateNotifier<Map<String, dynamic>> {
  GoogleMapController? _googleMapController;
  int _markerClickCounter = 0;

  /// JSON’dan gelen tüm marker verileri (ham)
  List<Map<String, dynamic>> _allMarkersData = [];
  List<Marker> clusteredMarkers = []; // Görünür ve cluster yapılmış markerlar

  /// Mevcut zoom
  double _currentZoom = 5;

  /// Tur rotası
  List<LatLng> _tourPath = [];
  List<String> _tourTitles = [];

  final RouteService _routeService = RouteService();
  String _selectedTravelMode = 'walking';

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

  /// JSON’dan markerları oku
  Future<void> _initializeMarkers() async {
    await MarkerIcons.loadIcons();
    _allMarkersData = await PredefinedMarkers.loadMarkers();

    // Başlangıç için boş marker seti
    state = {
      ...state,
      'markers': <Marker>{},
    };
  }

  /// Kamera hareketi bittiğinde çağırılacak
  Future<void> onCameraIdle() async {
    if (_googleMapController == null) return;

    final bounds = await _googleMapController!.getVisibleRegion();
    final zoom = _currentZoom;

    final clusters = await computeClusters(
      _allMarkersData,
      bounds,
      zoom,
    );

    final newMarkers = <Marker>{};

    for (var c in clusters) {
      if (c['isCluster'] == true) {
        final count = c['count']; // cluster içindeki mekan sayısı

        // ikon dosya adını dinamik üret
        String iconPath;
        if (count >= 2 && count <= 30) {
          iconPath = "assets/cluster_icons/cluster_$count.png";
        } else {
          iconPath = "assets/cluster_icons/default_cluster.png";
        }

        final clusterIcon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(64, 64)),
          iconPath,
        );

        newMarkers.add(
          Marker(
            markerId: MarkerId("cluster_${c['lat']}_${c['lng']}"),
            position: LatLng(c['lat'], c['lng']),
            icon: clusterIcon,
            infoWindow: InfoWindow(title: "$count mekan"),
          ),
        );
      } else {
        // Tekil marker
        final iconPath = c['iconPath'];
        BitmapDescriptor customIcon =
            await MarkerIcons.getBitmapDescriptor(iconPath);

        newMarkers.add(
          Marker(
            markerId: MarkerId("marker_${c['lat']}_${c['lng']}"),
            position: LatLng(c['lat'], c['lng']),
            icon: customIcon,
            infoWindow: InfoWindow(title: c['title']),
            onTap: () => _showBottomSheet(c['title'], c['image']),
          ),
        );
      }
    }

    state = {
      ...state,
      'markers': newMarkers,
    };
  }

  /// Kamera zoom’u güncelle
  void onCameraMove(CameraPosition position) {
    _currentZoom = position.zoom;
  }

  // Konumun doğruluğunu kontrol et ve kullanıcıya izin iste
  Future<void> _determinePosition() async {
    final context = navigatorKey.currentContext;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context != null) {
        _showDialog(
          context: context,
          title: AppLocalizations.of(context)!.locationServiceDisable,
          content: AppLocalizations.of(context)!.openLocationServiceMessage,
          actionText: AppLocalizations.of(context)!.settings,
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
            title: AppLocalizations.of(context)!.requiredPermission,
            content: AppLocalizations.of(context)!
                .requiredAppLocationPermissionMessage,
            actionText: AppLocalizations.of(context)!.actionOK,
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context != null) {
        _showDialog(
          context: context,
          title: AppLocalizations.of(context)!.noLocationPermission,
          content:
              AppLocalizations.of(context)!.rejectedLocationPermissionMessage,
          actionText: AppLocalizations.of(context)!.settings,
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
          title: AppLocalizations.of(context)!.locationError,
          content: AppLocalizations.of(context)!.getLocationError,
          actionText: AppLocalizations.of(context)!.actionOK,
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
      'isTourActive': state['isTourActive'] ?? false,
    };
  }

  void _showBottomSheet(String title, String imageUrl) {
  final context = navigatorKey.currentContext;
  if (context == null || _googleMapController == null) return;

  final adManager = InterstitialAdManager();
  adManager.loadAndShowAd(
    adUnitId: 'ca-app-pub-9479192831415354/5701357503', // 👈 keşfet için ayrı ID
    showEveryTwo: true, // 2’de 1 reklam göster
    onAdClosed: () {
      _openStoryBottomSheet(context, title, imageUrl);
    },
  );
}


// JSON’daki tüm marker verilerini döndüren fonksiyon
  List<Map<String, dynamic>> getAllMarkersData() {
    return _allMarkersData; // 👈 senin JSON’dan yüklediğin marker listesi
  }

//  Hedef konuma animasyonla git
  Future<void> animateToLocation(LatLng target) async {
    if (_googleMapController == null) return;

    await _googleMapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: 16, // yakınlaştırma seviyesini sen ayarlayabilirsin
        ),
      ),
    );
  }

  void _openStoryBottomSheet(
      BuildContext context, String title, String imageUrl) {
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
    if (currentLocation == null || _allMarkersData.isEmpty) return [];

    List<LatLng> path = [currentLocation];
    List<String> addedTitles = [];

    // JSON’daki tüm markerlar üzerinden rota oluştur
    List<Map<String, dynamic>> remainingMarkers = [..._allMarkersData];
    LatLng currentPoint = currentLocation;

    for (int i = 0; i < locationCount; i++) {
      if (remainingMarkers.isEmpty) break;

      Map<String, dynamic>? nearest;
      double minDistance = double.infinity;

      for (var marker in remainingMarkers) {
        final markerLat = marker['position'].latitude;
        final markerLng = marker['position'].longitude;

        double distance = _calculateDistance(
          currentPoint.latitude,
          currentPoint.longitude,
          markerLat,
          markerLng,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearest = marker;
        }
      }

      if (nearest != null) {
        final pos = nearest['position'] as LatLng;
        path.add(pos);
        addedTitles.add(nearest['title']);
        currentPoint = pos;
        remainingMarkers.remove(nearest);
      }
    }

    setTourPath(path, addedTitles);
    return path;
  }

  /// Tur rotasını döndüren fonksiyon

  Future<void> saveCurrentRoute({
    String? customTitle,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final places = _tourPath
        .asMap()
        .map((index, e) {
          final title = _tourTitles[index];
          // JSON’daki marker verilerinden image’ı çekelim
          final image = _allMarkersData.firstWhere(
            (m) => m['title'] == title,
            orElse: () => {'image': ''},
          )['image'];

          return MapEntry(
            index,
            Place(
              name: title,
              image: image ?? '',
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
      title: customTitle ??
          AppLocalizations.of(navigatorKey.currentContext!)!.unnamedRoute,
      description: _tourTitles.join(' - '),
      places: places,
      mode: _selectedTravelMode,
      isShared: false,
      createdAt: Timestamp.now(),
    );

    await _routeService.saveRoute(route);
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
    if (currentLocation == null || _allMarkersData.isEmpty) return;

    List<LatLng> path = [];
    List<Map<String, dynamic>> remainingMarkers = [..._allMarkersData];
    LatLng currentPoint = currentLocation;

    for (int i = 0; i < locationCount; i++) {
      if (remainingMarkers.isEmpty) break;

      Map<String, dynamic>? nearest;
      double minDistance = double.infinity;

      for (var marker in remainingMarkers) {
        final markerLat = marker['position'].latitude;
        final markerLng = marker['position'].longitude;

        double distance = _calculateDistance(
          currentPoint.latitude,
          currentPoint.longitude,
          markerLat,
          markerLng,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearest = marker;
        }
      }

      if (nearest != null) {
        final pos = nearest['position'] as LatLng;
        path.add(pos);
        currentPoint = pos;
        remainingMarkers.remove(nearest);
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
  Future<List<LatLng>> _getRouteFromApi(LatLng origin, LatLng destination,
      String apiKey, String travelMode) async {
    // İnternet bağlantısı kontrolü
    final hasConnection = await _checkInternetConnection();
    if (!hasConnection) {
      if (navigatorKey.currentContext != null) {
        final context = navigatorKey.currentContext!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.connectionErrorRoute,
            ),
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

  List<String> getTourTitles() => _tourTitles;

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

  void setTourPath(List<LatLng> path, List<String> titles) {
    _tourPath = path;
    _tourTitles = titles;
  }

  String get selectedTravelMode => _selectedTravelMode;
  void setTravelMode(String mode) => _selectedTravelMode = mode;
}

/// Isolate fonksiyonu
Future<List<Map<String, dynamic>>> computeClusters(
    List<Map<String, dynamic>> allMarkers,
    LatLngBounds bounds,
    double zoom) async {
  return await Isolate.run(() {
    final minLat = bounds.southwest.latitude;
    final maxLat = bounds.northeast.latitude;
    final minLng = bounds.southwest.longitude;
    final maxLng = bounds.northeast.longitude;

    // Görünen bölgedeki markerları filtrele
    final visible = allMarkers.where((m) {
      final lat = m['position'].latitude;
      final lng = m['position'].longitude;
      return lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;
    }).toList();

    if (visible.isEmpty) return [];

    // 🔑 Zoom’a göre grid boyutu
    double _getGridSize(double zoom) {
      if (zoom < 5) return 1.0;
      if (zoom < 10) return 0.5;
      if (zoom < 13) return 0.2;
      if (zoom < 16) return 0.05;
      return 0.02;
    }

    final gridSize = _getGridSize(zoom);

    // Çok az marker varsa clusterlama yapma
    if (visible.length < 30) {
      return visible
          .map((m) => {
                'isCluster': false,
                'lat': m['position'].latitude,
                'lng': m['position'].longitude,
                'title': m['title'],
                'image': m['image'],
                'iconPath': m['iconPath'],
              })
          .toList();
    }

    // Cluster grupları
    final clusters = <String, List<Map<String, dynamic>>>{};

    for (var m in visible) {
      final lat = m['position'].latitude;
      final lng = m['position'].longitude;
      final key = "${(lat / gridSize).floor()}_${(lng / gridSize).floor()}";
      clusters.putIfAbsent(key, () => []).add(m);
    }

    final results = <Map<String, dynamic>>[];
    clusters.forEach((key, group) {
      if (group.length == 1) {
        final m = group.first;
        results.add({
          'isCluster': false,
          'lat': m['position'].latitude,
          'lng': m['position'].longitude,
          'title': m['title'],
          'image': m['image'],
          'iconPath': m['iconPath'],
        });
      } else {
        final avgLat =
            group.map((m) => m['position'].latitude).reduce((a, b) => a + b) /
                group.length;
        final avgLng =
            group.map((m) => m['position'].longitude).reduce((a, b) => a + b) /
                group.length;
        results.add({
          'isCluster': true,
          'lat': avgLat,
          'lng': avgLng,
          'count': group.length,
        });
      }
    });

    return results;
  });
}
