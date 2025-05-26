import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late Future<List<Map<String, dynamic>>> _topRatedPlaces;

  @override
  void initState() {
    super.initState();
    _topRatedPlaces = fetchTopRatedPlaces();
  }

  Future<List<Map<String, dynamic>>> fetchTopRatedPlaces() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('ratings')
        .orderBy('rating', descending: true)
        .limit(100) // daha fazla veri çekerek daha iyi ortalama çıkar
        .get();

    Map<String, List<double>> ratingsMap = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final placeTitle = data['placeTitle'];
      final rating = (data['rating'] as num?)?.toDouble();

      if (placeTitle != null && rating != null) {
        ratingsMap.putIfAbsent(placeTitle, () => []);
        ratingsMap[placeTitle]!.add(rating);
      }
    }

    // Ortalama puana göre sıralanmış ilk 5 mekan
    List<Map<String, dynamic>> results = ratingsMap.entries.map((entry) {
      final ratings = entry.value;
      final average = ratings.reduce((a, b) => a + b) / ratings.length;
      return {
        'placeTitle': entry.key,
        'averageRating': average,
        'count': ratings.length,
      };
    }).toList()
      ..sort((a, b) => (b['averageRating'] as double)
          .compareTo(a['averageRating'] as double));

    return results.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _topRatedPlaces,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        }

        final data = snapshot.data;

        if (data == null || data.isEmpty) {
          return const Center(child: Text('Henüz puanlanmış mekan yok.'));
        }

        return Padding(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16, bottom: 16),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              final title = item['placeTitle'] ?? 'İsimsiz Mekan';
              final rating =
                  (item['averageRating'] as double).toStringAsFixed(1);
              final count = item['count'];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Ortalama Puan: $rating ($count oy)"),
                  trailing: const Icon(Icons.star, color: Colors.amber),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
