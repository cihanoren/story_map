import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:story_map/core/config.dart';
import 'package:story_map/features/home/controller.dart/maps_controller.dart';
import 'package:story_map/l10n/app_localizations.dart';
import 'package:story_map/utils/marker_icons.dart';

class MapView extends ConsumerStatefulWidget {
  const MapView({super.key});

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Map<String, dynamic>> _searchResults = [];

  /// 🔎 Arama fonksiyonu
  List<Map<String, dynamic>> searchPlaces(
      String query, List<Map<String, dynamic>> allPlaces) {
    if (query.length < 2) return [];

    final lowerQuery = query.toLowerCase();

    return allPlaces.where((place) {
      final title = (place['title'] ?? '').toString().toLowerCase();

      // Başlık içindeki her kelimeye bakıyoruz
      final words = title.split(RegExp(r'\s+'));
      return words.any((w) => w.startsWith(lowerQuery));
    }).toList();
  }

  void _onSearch(String query, MapController mapController) {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    final allPlaces = mapController.getAllMarkersData();
    setState(() {
      _searchResults = searchPlaces(query, allPlaces);
    });
  }

  /// 📍 Seçilen mekana git
  void _goToPlace(Map<String, dynamic> place, MapController mapController) {
    final position = place['position'] as LatLng?;
    if (position == null) return;

    mapController.animateToLocation(position);

    setState(() {
      _searchResults = [];
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchFocusNode.dispose(); // FocusNode’u dispose et
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapControllerProvider);
    final mapController = ref.read(mapControllerProvider.notifier);
    final isTourActive = mapState['isTourActive'] as bool? ?? false;

    // Marker ikonlarını yükle
    MarkerIcons.loadIcons();

    return Scaffold(
      body: mapState['location'] == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal, // Harita tipi
                  compassEnabled: false, // Pusula butonu
                  onCameraMove: (pos) => ref
                      .read(mapControllerProvider.notifier)
                      .onCameraMove(pos),
                  onCameraIdle: () =>
                      ref.read(mapControllerProvider.notifier).onCameraIdle(),
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
                  zoomControlsEnabled: false,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  markers: mapState['markers'],
                  onTap: (LatLng position) {},
                ),

                /// 🔎 Arama Barı
                Positioned(
                  top: 40,
                  left: 15,
                  right: 70,
                  child: Column(
                    children: [
                      Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(25),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: (val) => _onSearch(val, mapController),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.searchPlace,
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController
                                          .clear(); // yazıyı temizle
                                      _onSearch('',
                                          mapController); // sonuçları sıfırla
                                      _searchFocusNode
                                          .unfocus(); // klavyeyi kapat

                                      setState(() {}); // UI’yi güncelle
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                          ),
                        ),
                      ),
                      if (_searchResults.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final place = _searchResults[index];

                              // 📌 Burada her mekana ait ikon belirleniyor
                              final iconPath = place['iconPath'] as String?;
                              final categoryIcon = iconPath != null
                                  ? Image.asset(iconPath, width: 28, height: 28)
                                  : const Icon(Icons.location_on,
                                      color: Colors.deepPurple);

                              return ListTile(
                                leading: categoryIcon,
                                title: Text(place['title']),
                                onTap: () => _goToPlace(place, mapController),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),

                // Harita üzerindeki konum butonu
                Positioned(
                  top: 40,
                  right: 10,
                  child: FloatingActionButton.small(
                    backgroundColor: Colors.white,
                    onPressed: () {
                      mapController.moveToCurrentLocation();
                    },
                    child: const Icon(Icons.my_location, color: Colors.black),
                  ),
                ),

                // Yakınlaştırma butonları
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'zoom_in',
                        backgroundColor: Colors.white,
                        elevation: 2,
                        onPressed: () {
                          mapController.zoomIn();
                        },
                        child: const Icon(Icons.add,
                            size: 20, color: Colors.black),
                      ),
                      const SizedBox(height: 5),
                      FloatingActionButton.small(
                        heroTag: 'zoom_out',
                        backgroundColor: Colors.white,
                        elevation: 2,
                        onPressed: () {
                          mapController.zoomOut();
                        },
                        child: const Icon(Icons.remove,
                            size: 20, color: Colors.black),
                      ),
                    ],
                  ),
                ),

                // Eğer tur aktif değilse, "Geziye Başla" butonunu göster
                if (!isTourActive)
                  Positioned(
                    bottom: 10,
                    left: 85,
                    right: 85,
                    child: ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          isScrollControlled: true,
                          builder: (context) {
                            int locationCount = 1;
                            String selectedTravelMode = 'driving';

                            return Padding(
                              padding: MediaQuery.of(context).viewInsets,
                              child: StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .howManyLocationTripQuestion, // "Kaç konumlu gezi yapmak istersiniz?"
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 20),
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
                                        Text(
                                          AppLocalizations.of(context)!
                                              .selectTransportMode, // "Seyahat modu seçin:"
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        RadioListTile(
                                          title: Text(AppLocalizations.of(
                                                  context)!
                                              .driving), // "Araba (Driving)"
                                          value: 'driving',
                                          groupValue: selectedTravelMode,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedTravelMode = value!;
                                            });
                                          },
                                        ),
                                        RadioListTile(
                                          title: Text(AppLocalizations.of(
                                                  context)!
                                              .walking), // "Yürüyüş (Walking)"
                                          value: 'walking',
                                          groupValue: selectedTravelMode,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedTravelMode = value!;
                                            });
                                          },
                                        ),
                                        RadioListTile(
                                          title: Text(AppLocalizations.of(
                                                  context)!
                                              .bicycling), // "Bisiklet (Bicycling)"
                                          value: 'bicycling',
                                          groupValue: selectedTravelMode,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedTravelMode = value!;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop();

                                            mapController.setTravelMode(
                                                selectedTravelMode); // 👈 travel mode'u sakla

                                            mapController.startTour();

                                            await mapController.createRealPath(
                                              locationCount,
                                              Config.googleMapsPlacesApiKey,
                                              travelMode: selectedTravelMode,
                                            );

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
                                                  BorderRadius.circular(30),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 32, vertical: 10),
                                          ),
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .start, // "Geziye Başla"
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    Colors.yellowAccent[700]),
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
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: Colors.grey[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!
                            .startTrip, // "Geziye Başla"
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellowAccent[700]),
                      ),
                    ),
                  ),

                // Eğer tur aktifse, harita üzerinde bir bilgi penceresi göster
                if (isTourActive)
                  Positioned(
                    bottom: 20,
                    left: 70,
                    right: 70,
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
                            final titles = mapController.getTourTitles();

                            return DraggableScrollableSheet(
                              expand: false,
                              initialChildSize: 0.4,
                              minChildSize: 0.3,
                              maxChildSize: 0.90,
                              builder: (context, scrollController) {
                                return Padding(
                                  padding: MediaQuery.of(context).viewInsets,
                                  child: SingleChildScrollView(
                                    controller: scrollController,
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 20),
                                        Text(
                                            AppLocalizations.of(context)!
                                                .tripRoute, // "Gezi Rotası mesajı"
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 10),
                                        ...titles.asMap().entries.map((entry) {
                                          return ListTile(
                                            leading: CircleAvatar(
                                                child: Text((entry.key + 1)
                                                    .toString())),
                                            title: Text(entry.value),
                                          );
                                        }).toList(),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            // Rota Kaydet Butonu
                                            ElevatedButton(
                                              onPressed: () async {
                                                final TextEditingController
                                                    titleController =
                                                    TextEditingController();

                                                await showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Text(AppLocalizations
                                                              .of(context)!
                                                          .routeTitle), // "Rota Başlığı"
                                                      content: TextField(
                                                        controller:
                                                            titleController,
                                                        decoration:
                                                            InputDecoration(
                                                          hintText: AppLocalizations
                                                                  .of(context)!
                                                              .tripHintText, // "Gezi başlığı girin örnek metni"
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                          child: Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .cancel, // "İptal"
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () async {
                                                            final customTitle =
                                                                titleController
                                                                    .text
                                                                    .trim();
                                                            Navigator.of(
                                                                    context)
                                                                .pop(); // dialog kapat

                                                            await ref
                                                                .read(mapControllerProvider
                                                                    .notifier)
                                                                .saveCurrentRoute(
                                                                  customTitle: customTitle
                                                                          .isNotEmpty
                                                                      ? customTitle
                                                                      : null,
                                                                );

                                                            if (context
                                                                .mounted) {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(); // sheet kapat
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .green,
                                                                  content: Text(
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .tourSavedSuccessfuly, // "Rota kaydedildi"
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          child: Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .save), // "Kaydet"
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.deepPurple,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 40,
                                                        vertical: 12),
                                              ),
                                              child: Text(AppLocalizations.of(
                                                      context)!
                                                  .saveTour), // "Rota Kaydet"
                                            ),

                                            // Tur Bitir Butonu
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                mapController
                                                    .endTour(); // Turu bitir
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 40,
                                                        vertical: 12),
                                              ),
                                              child: Text(
                                                  AppLocalizations.of(context)!
                                                      .endTour), // "Turu Bitir"
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                          "${AppLocalizations.of(context)!.seeTours} / ${AppLocalizations.of(context)!.endTour}", // "Turları Görüntüle / Turu Bitir"
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
              ],
            ),
    );
  }
}
