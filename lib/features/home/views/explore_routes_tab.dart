import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ExploreRoutesTab extends StatefulWidget {
  const ExploreRoutesTab({super.key});

  @override
  State<ExploreRoutesTab> createState() => _ExploreRoutesTabState();
}

class _ExploreRoutesTabState extends State<ExploreRoutesTab> {
  late Future<List<Map<String, dynamic>>> _sharedRoutes;
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _sharedRoutes = _fetchSharedRoutes();
  }

  Future<List<Map<String, dynamic>>> _fetchSharedRoutes() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('routes')
        .where('isShared', isEqualTo: true)
        .orderBy('sharedAt', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'routeId': doc.id,
        'title': data['title'] ?? 'Başlıksız',
        'sharedAt': data['sharedAt'],
        'places': data['places'],
      };
    }).toList();
  }

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '-';
    final date = timestamp.toDate();
    return '${date.day}.${date.month}.${date.year}';
  }

  Future<void> _refreshRoutes() async {
    final freshRoutes = await _fetchSharedRoutes();
    setState(() {
      _sharedRoutes = Future.value(freshRoutes);
    });
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _sharedRoutes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            onRefresh: _refreshRoutes,
            header: const WaterDropMaterialHeader(
              backgroundColor: Colors.deepPurple,
              color: Colors.white,
            ),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 150),
                Center(child: Text("Henüz paylaşılmış rota yok.")),
              ],
            ),
          );
        }

        final routes = snapshot.data!;

        return SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: _refreshRoutes,
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

              // 0. indeks hariç 1-4 arasındaki yerlerin görsellerini al
              final List<String> imageUrls = [];
              if (places.length > 1) {
                final subPlaces = places.sublist(1, min(7, places.length));
                for (var place in subPlaces) {
                  if (place['image'] != null && (place['image'] as String).isNotEmpty) {
                    imageUrls.add(place['image'] as String);
                  }
                }
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 4),
                      Text("Paylaşıldı: $sharedAt", style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 12),

                      // Resimler varsa yatay liste göster
                      if (imageUrls.isNotEmpty)
                        SizedBox(
                          height: 90,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: imageUrls.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrls[i],
                                  width: 120,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Image.asset(
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
                        // Resim yoksa placeholder gösterebilirsin
                        Container(
                          width: double.infinity,
                          height: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade300,
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "Resim yok",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
