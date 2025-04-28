import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:story_map/core/config.dart';
import 'package:story_map/features/home/controller.dart/maps_controller.dart';
import 'package:story_map/utils/marker_icons.dart';

class MapView extends ConsumerWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapControllerProvider);
    final mapController = ref.read(mapControllerProvider.notifier);

    // Marker ikonlarını yükle
    MarkerIcons.loadIcons();

    return Scaffold(
      appBar: AppBar(title: const Text("Harita")),
      body: mapState['location'] == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  polylines: mapState['polyline'] != null
                      ? {mapState['polyline']}
                      : {},
                  initialCameraPosition: CameraPosition(
                    target: mapState['location'],
                    zoom: 15,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    mapController.setMapController(controller);
                    mapController.moveToCurrentLocation();
                    Future.delayed(const Duration(milliseconds: 300), () {
                      mapController.loadMarkers();
                    });
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: mapState['markers'],
                  onTap: (LatLng position) {
                    // İstersen buraya tıklayınca hikaye ekleme vs. yazarsın
                  },
                ),
                // Gezintiye Başla Butonu
                Positioned(
                  bottom: 20,
                  left: 85,
                  right: 85,
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        isScrollControlled: true,
                        builder: (context) {
                          int locationCount = 1; // Lokasyon sayısı
                          String selectedTravelMode =
                              'driving'; // 🚗 Varsayılan araç modu

                          return Padding(
                            padding: MediaQuery.of(context).viewInsets,
                            child: StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "Kaç lokasyon gezmek istiyorsunuz?",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 20),

                                      // Lokasyon Seçimi
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              if (locationCount > 1) {
                                                setState(() {
                                                  locationCount--;
                                                });
                                              }
                                            },
                                            icon: const Icon(Icons.remove),
                                          ),
                                          Text(
                                            locationCount.toString(),
                                            style:
                                                const TextStyle(fontSize: 24),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                locationCount++;
                                              });
                                            },
                                            icon: const Icon(Icons.add),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),

                                      // 🌟 Rota Modu Seçimi (Araç, Yürüyüş, Bisiklet)
                                      const Text(
                                        "Ulaşım Modu Seçin",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      RadioListTile(
                                        title: const Text('Araç (Driving)'),
                                        value: 'driving',
                                        groupValue: selectedTravelMode,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedTravelMode = value!;
                                          });
                                        },
                                      ),
                                      RadioListTile(
                                        title: const Text('Yürüyüş (Walking)'),
                                        value: 'walking',
                                        groupValue: selectedTravelMode,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedTravelMode = value!;
                                          });
                                        },
                                      ),
                                      RadioListTile(
                                        title:
                                            const Text('Bisiklet (Bicycling)'),
                                        value: 'bicycling',
                                        groupValue: selectedTravelMode,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedTravelMode = value!;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 20),

                                      // Başla Butonu
                                      ElevatedButton(
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          print(
                                              "Seçilen lokasyon sayısı: $locationCount");
                                          print(
                                              "Seçilen rota modu: $selectedTravelMode");

                                          mapController.createRealPath(
                                            locationCount,
                                            Config.googleMapsPlacesApiKey,
                                            travelMode:
                                                selectedTravelMode, // 🔥 Modu parametre olarak geçiyoruz
                                          );

                                          // Eğer createShortestPath de güncellenecekse ona da mode gönderirsin
                                          final path = await mapController
                                              .createShortestPath(
                                            locationCount,
                                            travelMode: selectedTravelMode,
                                          );

                                          print("Oluşturulan rota:");
                                          for (var point in path) {
                                            print(
                                                "${point.latitude}, ${point.longitude}");
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 32, vertical: 16),
                                        ),
                                        child: Text(
                                          "Başla",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.yellowAccent[700]),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Gezmeye Başla",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellowAccent[700]),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
