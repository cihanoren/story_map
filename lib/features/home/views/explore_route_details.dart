import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:story_map/l10n/app_localizations.dart';

class ExploreRouteDetails extends StatefulWidget {
  final String routeId;
  final String routeTitle;

  const ExploreRouteDetails({
    super.key,
    required this.routeId,
    required this.routeTitle,
  });

  @override
  State<ExploreRouteDetails> createState() => _ExploreRouteDetailsState();
}

class _ExploreRouteDetailsState extends State<ExploreRouteDetails> {
  late Future<List<Map<String, dynamic>>> _placesFuture;

  bool _isLiked = false;
  int _likeCount = 0;
  int _viewCount = 0;

  @override
  void initState() {
    super.initState();
    _incrementViewCount(); // Rota görüntülendiğinde sayacı artır
    _loadLikeAndViewCounts(); // Beğeni ve görüntülenme sayısını yükle
    _placesFuture = fetchPlacesFromExploreRoute(widget.routeId);
  }

  // Rota görüntülendiğinde sayacı artır
  Future<void> _incrementViewCount() async {
    final docRef = FirebaseFirestore.instance
        .collection('explore_routes')
        .doc(widget.routeId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final currentViews = snapshot.get('viewCount') ?? 0;
      transaction.update(docRef, {'viewCount': currentViews + 1});
    });
  }

  // Kullanıcı rotayı beğendiğinde veya beğenmekten vazgeçtiğinde çağrılır
  Future<void> _toggleLike() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('explore_routes')
        .doc(widget.routeId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      List likedBy = [];
      if (snapshot.data() != null && snapshot.data()!.containsKey('likedBy')) {
        likedBy = List<String>.from(snapshot.get('likedBy'));
      }
      int likeCount = snapshot.data()?.containsKey('likeCount') == true
          ? snapshot.get('likeCount')
          : 0;

      if (likedBy.contains(uid)) {
        likedBy.remove(uid);
        likeCount = likeCount - 1;
      } else {
        likedBy.add(uid);
        likeCount = likeCount + 1;
      }

      transaction.update(docRef, {
        'likedBy': likedBy,
        'likeCount': likeCount,
      });

      setState(() {
        _isLiked = likedBy.contains(uid);
        _likeCount = likeCount;
      });
    });
  }

  Future<void> _loadLikeAndViewCounts() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('explore_routes')
        .doc(widget.routeId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final likedBy =
        data.containsKey('likedBy') ? List<String>.from(data['likedBy']) : [];
    final likeCount = data.containsKey('likeCount') ? data['likeCount'] : 0;
    final viewCount = data.containsKey('viewCount') ? data['viewCount'] : 0;

    setState(() {
      _isLiked = likedBy.contains(uid);
      _likeCount = likeCount;
      _viewCount = viewCount;
    });
  }

  // Mekanları FireStore Keşfet Koleksiyonundan çek
  Future<List<Map<String, dynamic>>> fetchPlacesFromExploreRoute(
      String routeId) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('explore_routes')
        .doc(routeId)
        .get();

    if (!docSnapshot.exists) return [];

    final data = docSnapshot.data();
    if (data == null || data['places'] == null) return [];

    final List<dynamic> places = data['places'];
    final List<Map<String, dynamic>> processedPlaces = [];

    for (var place in places) {
      final Map<String, dynamic> placeMap = Map<String, dynamic>.from(place);
      placeMap['mode'] = data['mode'];
      placeMap['sharedAt'] = data['sharedAt'];
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
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              widget.routeTitle,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).textTheme.bodyLarge?.color),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: () {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text(
                            AppLocalizations.of(context)!.notFoundAnyPlace));
                  }

                  final places = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      final place = places[index];
                      final imageUrl = place['image'] as String?;
                      final name =
                          place['name'] ?? AppLocalizations.of(context)!.noName;
                      final mode = place['mode'] ??
                          AppLocalizations.of(context)!.unKnown;
                      final lat = place['lat']?.toStringAsFixed(5) ?? '-';
                      final lng = place['lng']?.toStringAsFixed(5) ?? '-';
                      final sharedAt = formatTimestamp(place['sharedAt']);

                      return Card(
                        color: Colors.grey[100],
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                                      ? Image.network(imageUrl,
                                          fit: BoxFit.cover)
                                      : Image.asset(
                                          "assets/images/Story_Map.png",
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
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(
                                            AppLocalizations.of(context)!
                                                    .transport +
                                                ": ",
                                            style: TextStyle(
                                                color: Colors.black87)),
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
                                    Text(
                                        AppLocalizations.of(context)!.location +
                                            ": $lat, $lng",
                                        style: const TextStyle(
                                            color: Colors.black54)),
                                    Text(
                                        AppLocalizations.of(context)!.sharing +
                                            ": $sharedAt",
                                        style: const TextStyle(
                                            color: Colors.black54)),
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
              ),

              // BEĞENİ VE GÖRÜNTÜLENME SAYILARI BURADA
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Beğeni ikonu ve sayısı
                    IconButton(
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : Colors.grey,
                      ),
                      iconSize: 30,
                      onPressed: _toggleLike,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$_likeCount',
                      style: const TextStyle(fontSize: 16),
                    ),

                    const SizedBox(width: 40),

                    // Görüntülenme ikonu ve sayısı
                    const Icon(Icons.visibility, color: Colors.grey, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      '$_viewCount',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
