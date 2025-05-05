import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CardDetails extends StatefulWidget {
  final String routeId;
  final String? routeTitle;
  final List<String> placeNames;
  final List<String> imagesUrls;

  const CardDetails({
    super.key,
    required this.routeId,
    required this.routeTitle,
    required this.placeNames,
    required this.imagesUrls,
  });

  @override
  State<CardDetails> createState() => _CardDetailsState();
}

class _CardDetailsState extends State<CardDetails> {
  late Future<List<Map<String, dynamic>>> _placesFuture;
  String? _routeTitleFromFirestore;

  @override
  void initState() {
    super.initState();
    _placesFuture = fetchPlacesForRoute(widget.routeId);
  }

  Future<List<Map<String, dynamic>>> fetchPlacesForRoute(String routeId) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('routes')
        .doc(routeId)
        .get();

    if (!docSnapshot.exists) return [];

    final data = docSnapshot.data();
    if (data == null || data['places'] == null) return [];

    _routeTitleFromFirestore = data['title'];

    final List<dynamic> places = data['places'];
    final List<Map<String, dynamic>> processedPlaces = [];

    for (var place in places) {
      final Map<String, dynamic> placeMap = Map<String, dynamic>.from(place);
      placeMap['mode'] = data['mode'];
      placeMap['createdAt'] = data['createdAt'];
      processedPlaces.add(placeMap);
    }

    return processedPlaces;
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '-';
    final date = timestamp.toDate();
    return DateFormat('dd.MM.yyyy – HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _placesFuture,
      builder: (context, snapshot) {
        final title = _routeTitleFromFirestore ?? widget.routeTitle ?? "Rota Detayları";

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            elevation: 1,
            title: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).textTheme.bodyLarge?.color),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: () {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Hiç mekan bulunamadı."));
            }

            final places = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];
                final imageUrl = place['image'] as String?;
                final name = place['name'] ?? 'İsim yok';
                final mode = place['mode'] ?? 'Bilinmiyor';
                final lat = place['lat']?.toStringAsFixed(5) ?? '-';
                final lng = place['lng']?.toStringAsFixed(5) ?? '-';
                final createdAt = formatTimestamp(place['createdAt']);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: imageUrl != null && imageUrl.isNotEmpty
                                ? Image.network(imageUrl, fit: BoxFit.cover)
                                : Image.asset("assets/images/Story_Map.png",
                                    fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Text("Ulaşım: ",
                                      style: TextStyle(color: Colors.black87)),
                                  if (mode == "driving")
                                    const Icon(Icons.directions_car,
                                        color: Colors.black87, size: 20)
                                  else if (mode == "walking")
                                    const Icon(Icons.directions_walk,
                                        color: Colors.black87, size: 20)
                                  else if (mode == "bicycling")
                                    const Icon(Icons.directions_bike,
                                        color: Colors.black87, size: 20)
                                  else
                                    const Icon(Icons.help_outline,
                                        color: Colors.black87, size: 20),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text("Konum: $lat, $lng",
                                  style:
                                      const TextStyle(color: Colors.black54)),
                              Text("Tarih: $createdAt",
                                  style:
                                      const TextStyle(color: Colors.black54)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }(),
        );
      },
    );
  }
}
