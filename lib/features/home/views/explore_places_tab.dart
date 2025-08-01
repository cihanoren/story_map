import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ExplorePlacesTab extends StatefulWidget {
  const ExplorePlacesTab({Key? key}) : super(key: key);

  @override
  State<ExplorePlacesTab> createState() => _ExplorePlacesTabState();
}

class _ExplorePlacesTabState extends State<ExplorePlacesTab> {
  final RefreshController _refreshController = RefreshController();
  List<Map<String, dynamic>> _topRatedPlaces = [];
  Map<String, String> _titleToImageMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialLoad();
  }

  Future<void> _initialLoad() async {
    await _loadMarkerImages();
    await _updateMissingImagesInFirestore();
    await _loadTopRatedPlaces();

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _loadMarkerImages() async {
    final jsonStr = await rootBundle.loadString('assets/markers.json');
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    _titleToImageMap = {
      for (var item in jsonList)
        if (item['title'] != null && item['image'] != null)
          item['title']: item['image']
    };
  }

  Future<void> _updateMissingImagesInFirestore() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('ratings').limit(100).get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final title = data['placeTitle'];
      final hasImage = data.containsKey('placeImage') &&
          (data['placeImage'] as String).isNotEmpty;

      if (title != null && !hasImage) {
        final imageUrl = _titleToImageMap[title];
        if (imageUrl != null) {
          try {
            await doc.reference.update({'placeImage': imageUrl});
          } catch (e) {
            print('Firestore güncelleme hatası: $e');
          }
        }
      }
    }
  }

  Future<void> _loadTopRatedPlaces() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('ratings')
        .orderBy('rating', descending: true)
        .limit(100)
        .get();

    final Map<String, List<double>> ratingMap = {};
    final Map<String, String> imageMap = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final title = data['placeTitle'];
      final rating = (data['rating'] as num?)?.toDouble();
      final imageUrl = data['placeImage'];

      if (title != null && rating != null) {
        ratingMap.putIfAbsent(title, () => []).add(rating);
        if (imageUrl != null && imageUrl is String && imageUrl.isNotEmpty) {
          imageMap[title] = imageUrl;
        }
      }
    }

    final List<Map<String, dynamic>> results = ratingMap.entries.map((e) {
      final avg = e.value.reduce((a, b) => a + b) / e.value.length;
      return {
        'placeTitle': e.key,
        'averageRating': avg,
        'count': e.value.length,
        'placeImage': imageMap[e.key],
      };
    }).toList()
      ..sort((a, b) => (b['averageRating'] as double)
          .compareTo(a['averageRating'] as double));

    if (!mounted) return;
    setState(() => _topRatedPlaces = results.take(15).toList());
  }

  Future<void> _onRefresh() async {
    await _loadTopRatedPlaces();
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      onRefresh: _onRefresh,
      header: const WaterDropMaterialHeader(
        backgroundColor: Colors.deepPurple,
        color: Colors.white,
      ),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        itemCount: _topRatedPlaces.length,
        itemBuilder: (context, index) {
          final item = _topRatedPlaces[index];
          final title = item['placeTitle'];
          final rating = (item['averageRating'] as double).toStringAsFixed(1);
          final count = item['count'];
          final imageUrl = item['placeImage'] ?? _titleToImageMap[title];

          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              onTap: () async {
                final storyText = await _fetchStory(title);

                if (context.mounted) {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    builder: (context) {
                      return DraggableScrollableSheet(
                        initialChildSize: 0.7, // Başlangıçta %70
                        minChildSize: 0.3, // En az %30
                        maxChildSize: 0.95, // En fazla %95
                        expand: false,
                        builder: (context, scrollController) {
                          return SingleChildScrollView(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: imageUrl != null
                                      ? Image.network(imageUrl)
                                      : Image.asset("assets/images/avatar.jpg"),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  storyText ??
                                      "Bu mekan için bir hikaye bulunamadı.",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null
                    ? Image.network(imageUrl,
                        width: 60, height: 60, fit: BoxFit.cover)
                    : Image.asset('assets/images/avatar.jpg',
                        width: 60, height: 60, fit: BoxFit.cover),
              ),
              title: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Ortalama Puan: $rating ($count oy)"),
              trailing: const Icon(Icons.star, color: Colors.amber),
            ),
          );
        },
      ),
    );
  }

  // Hikaye çekme fonksiyonu
  // Bu fonksiyon, Firestore'dan belirli bir mekanın hikayesini çeker.
  Future<String?> _fetchStory(String placeTitle) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('places')
          .doc(placeTitle)
          .collection('story')
          .doc('content') // 🔁 burası düzeltildi
          .get();

      if (doc.exists) {
        return doc.data()?['text'] as String?;
      }
    } catch (e) {
      print("Hikaye çekme hatası: $e");
    }
    return null;
  }
}
