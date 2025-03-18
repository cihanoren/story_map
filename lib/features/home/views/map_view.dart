import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:story_map/features/home/controller.dart/maps_controller.dart';

class MapView extends ConsumerWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapControllerProvider);
    final mapController = ref.read(mapControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text("Harita")),
      body: mapState['location'] == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: mapState['location'],
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                mapController.setMapController(controller);
                mapController.moveToCurrentLocation();
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: mapState['markers'],
              onTap: (LatLng position) {
                // Kullanıcı tıklayınca yeni hikaye ekleyebiliriz
              },
            ),
    );
  }
}
