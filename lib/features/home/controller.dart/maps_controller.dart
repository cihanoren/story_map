import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:story_map/features/home/controller.dart/predefined_markers.dart';
import 'package:story_map/features/home/views/bottom_sheet.dart';
import 'package:story_map/main.dart';

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

  void _initializeMarkers() {
  // PredefinedMarkers içindeki tüm işaretçileri ekle
  for (var markerData in PredefinedMarkers.markers) {
    addMarker(
      markerData['position'], // Konum
      markerData['title'],    // Başlık
      markerData['image'],    // Görsel URL
    );
  }
}


  void addMarker(LatLng position, String title, String imageUrl) {
    final markers = Set<Marker>.from(state['markers']);

    markers.add(
      Marker(
        markerId: MarkerId(position.toString()),
        position: position,
        icon: BitmapDescriptor.defaultMarker,
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

  // 🌟 **EKLENEN YENİ METOT**
  void loadMarkers() {
    _initializeMarkers();
  }
}
