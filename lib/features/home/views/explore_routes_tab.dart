import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:story_map/features/home/services.dart/InterstitialAdManager.dart';
import 'package:story_map/features/home/views/explore_route_details.dart';
import 'package:story_map/l10n/app_localizations.dart';

class ExploreRoutesTab extends StatefulWidget {
  const ExploreRoutesTab({super.key});

  @override
  State<ExploreRoutesTab> createState() => _ExploreRoutesTabState();
}

class _ExploreRoutesTabState extends State<ExploreRoutesTab> {
  Future<List<Map<String, dynamic>>>? _sharedRoutes;
  final RefreshController _refreshController = RefreshController();
  //int _tapRouteCount = 0;

  String? _selectedRegion; // Seçili ülke kodu
  List<String> _availableRegions = [
    'all'
  ]; // Dropdown için ülke kodları, 'all' tümü
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    _initUserRegionAndFetchRoutes();
  }

  Future<void> _initUserRegionAndFetchRoutes() async {
    final userRegion = await _getUserCountryCode();
    setState(() {
      _selectedRegion = userRegion ?? 'all';
      _loadingLocation = false;
    });
    await _fetchAndSetRoutes();
  }

  Future<String?> _getUserCountryCode() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return null;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        return placemarks.first.isoCountryCode?.toLowerCase();
      }
    } catch (e) {
      print("Konum alma hatası: $e");
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> _fetchSharedRoutesFiltered(
      String? region) async {
    Query collectionQuery =
        FirebaseFirestore.instance.collection('explore_routes');

    if (region != null && region != 'all') {
      collectionQuery = collectionQuery.where('region', isEqualTo: region);
    }

    final querySnapshot = await collectionQuery
        .orderBy('likeCount', descending: true)
        .orderBy('viewCount', descending: true)
        .get();

    Set<String> regions = {'all'};
    for (var doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?; // Burada cast eklendi
      if (data == null) continue;
      final regionCode = (data['region'] ?? '').toString().toLowerCase();
      if (regionCode.isNotEmpty) {
        regions.add(regionCode);
      }
    }

    setState(() {
      _availableRegions = regions.toList()
        ..sort((a, b) {
          if (a == 'all') return -1;
          if (b == 'all') return 1;
          return a.compareTo(b);
        });
    });

    return querySnapshot.docs
        .map((doc) {
          final data =
              doc.data() as Map<String, dynamic>?; // Burada da cast var
          if (data == null) return null;

          final regionCode = (data['region'] ?? '').toString().toLowerCase();

          return {
            'routeId': data['routeId'] ?? doc.id,
            'title': data['title'] ?? 'Başlıksız',
            'sharedAt': data['sharedAt'],
            'places': data['places'] ?? [],
            'likeCount': data['likeCount'] ?? 0,
            'viewCount': data['viewCount'] ?? 0,
            'region': regionCode,
          };
        })
        .where((element) => element != null)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  Future<void> _fetchAndSetRoutes() async {
    final routes = await _fetchSharedRoutesFiltered(_selectedRegion);
    setState(() {
      _sharedRoutes = Future.value(routes);
    });
    _refreshController.refreshCompleted();
  }

  // StatefulWidget içinde async fonksiyon
  int _tapRouteCount = 0; // Zaten var

  Future<void> _showRouteDetailsWithAd(Map<String, dynamic> route) async {
    final adManager = InterstitialAdManager();

    // Sayaç burada artmalı, onTap içinde değil!
    _tapRouteCount++;
    final showAd = _tapRouteCount % 2 == 0; // 2 tıklamada bir reklam

    Future<void> navigateToDetails() async {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExploreRouteDetails(
            routeId: route['routeId'],
            routeTitle: route['title'],
          ),
        ),
      );
    }

    if (showAd) {
      adManager.loadAndShowAd(
        adUnitId: 'ca-app-pub-9479192831415354/5701357503',
        showEveryTwo: true,
        onAdClosed: () async {
          await navigateToDetails();
        },
      );
    } else {
      await navigateToDetails();
    }
  }

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '-';
    final date = timestamp.toDate();
    return '${date.day}.${date.month}.${date.year}';
  }

  Future<void> _onRefresh() async {
    await _fetchAndSetRoutes();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingLocation) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Bölge seçimi dropdown
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context)!.region + ":",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: _availableRegions.contains(_selectedRegion)
                      ? _selectedRegion
                      : 'all',
                  items: _availableRegions.map((region) {
                    String displayText = region == 'all'
                        ? AppLocalizations.of(context)!.allCountries
                        : region.toUpperCase(); // Tüm ülkeler için özel metin
                    return DropdownMenuItem<String>(
                      value: region,
                      child: Text(
                        displayText,
                        style: const TextStyle(
                          fontSize: 12, // Küçük yazı boyutu
                          color: Colors.black, // Menü içindeki yazı rengi
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedRegion = value;
                    });
                    _fetchAndSetRoutes();
                  },
                  underline: const SizedBox(),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.black54,
                    size: 20,
                  ),
                  dropdownColor: Colors.white, // Açılır menü beyaz
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ), // seçili öğe yazı stili
                  isDense: true,
                  isExpanded: false,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _sharedRoutes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SmartRefresher(
                  controller: _refreshController,
                  enablePullDown: true,
                  onRefresh: _onRefresh,
                  header: const WaterDropMaterialHeader(
                    backgroundColor: Colors.deepPurple,
                    color: Colors.white,
                  ),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 150),
                      Center(
                          child: Text(
                              AppLocalizations.of(context)!.notSharedRouteYet)),
                    ],
                  ),
                );
              }

              final routes = snapshot.data!;

              return SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                onRefresh: _onRefresh,
                header: const WaterDropMaterialHeader(
                  backgroundColor: Colors.deepPurple,
                  color: Colors.white,
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: routes.length,
                  itemBuilder: (context, index) {
                    final route = routes[index];
                    final title = route['title'];
                    final sharedAt = formatDate(route['sharedAt']);
                    final places = route['places'] as List<dynamic>? ?? [];

                    final List<String> imageUrls = [];
                    if (places.length > 1) {
                      final subPlaces =
                          places.sublist(1, min(7, places.length));
                      for (var place in subPlaces) {
                        if (place['image'] != null &&
                            (place['image'] as String).isNotEmpty) {
                          imageUrls.add(place['image'] as String);
                        }
                      }
                    }

                    return InkWell(
                      onTap: () {
                        _tapRouteCount++;

                        _showRouteDetailsWithAd(route);
                      },
                      child: Card(
                        color: Colors.grey[100],
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                  const SizedBox(height: 4),
                                  Text(
                                      AppLocalizations.of(context)!.shared +
                                          ": $sharedAt", // Paylaşım tarihi mesajı
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 12),
                                  if (imageUrls.isNotEmpty)
                                    SizedBox(
                                      height: 90,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: imageUrls.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(width: 8),
                                        itemBuilder: (context, i) {
                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              imageUrls[i],
                                              width: 120,
                                              height: 90,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Image.asset(
                                                "assets/images/Story_Map.png",
                                                width: 120,
                                                height: 90,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  else
                                    Container(
                                      width: double.infinity,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey.shade300,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .noImage, // Resim yok mesajı
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                ],
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.favorite,
                                          color: Colors.red, size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        route['likeCount'].toString(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.visibility,
                                          color: Colors.white, size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        route['viewCount'].toString(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
