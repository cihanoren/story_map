import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
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
        final title =
            _routeTitleFromFirestore ?? widget.routeTitle ?? "Rota Detayları";

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
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
            actions: [
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                color: Colors.white,
                onSelected: (String value) {
                  switch (value) {
                    case 'edit':
                      // Rotayı düzenleme işlemi
                      _editRouteTitle();
                      break;
                    case 'share_in_explore':
                      // Keşfette paylaş
                      _shareRouteInExplore();
                      break;
                    case 'share':
                      // Paylaşma işlemi
                      break;
                    case 'delete':
                      _showDeleteConfirmationDialog(); // 👈 Yeni fonksiyon
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: SizedBox(
                      width: 180,
                      child: Row(
                        children: const [
                          Icon(Icons.edit, color: Colors.purple),
                          SizedBox(width: 10),
                          Text('Rotayı Düzenle'),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'share_in_explore',
                    child: SizedBox(
                      width: 180, // genişlik artırıldı
                      child: Row(
                        children: const [
                          Icon(Icons.switch_access_shortcut_outlined,
                              color: Colors.blue),
                          SizedBox(width: 10),
                          Text('Keşfette Paylaş'),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'share',
                    child: SizedBox(
                      width: 180,
                      child: Row(
                        children: const [
                          Icon(Icons.share, color: Colors.green),
                          SizedBox(width: 10),
                          Text('Rotayı Paylaş'),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: SizedBox(
                      width: 180,
                      child: Row(
                        children: const [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 10),
                          Text('Rotayı Sil'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
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

  // Rota paylaşma fonksiyonu
  // Keşfette paylaşma işlemi
  Future<void> _shareRouteInExplore() async {
    final docRef =
        FirebaseFirestore.instance.collection('routes').doc(widget.routeId);

    try {
      final doc = await docRef.get();
      if (!doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Rota bulunamadı."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final data = doc.data();

      final exploreRef = FirebaseFirestore.instance
          .collection('explore_routes')
          .doc(widget.routeId);
      final exploreDoc = await exploreRef.get();

      // Eğer explore_routes koleksiyonunda rota yok ama routes'da isShared true ise, isShared false yap
      if (!exploreDoc.exists && data?['isShared'] == true) {
        await docRef.update({'isShared': false});
      }

      final isAlreadyShared = data?['isShared'] == true && exploreDoc.exists;

      if (isAlreadyShared) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bu rota zaten keşfette paylaşılmış."),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Enlem ve boylamı al (ilk mekan)
      String regionCode = 'unknown';
      final places = data?['places'] as List<dynamic>?;

      if (places != null && places.isNotEmpty) {
        final firstPlace = places.first;
        final double? lat = (firstPlace['lat'] is num)
            ? (firstPlace['lat'] as num).toDouble()
            : null;
        final double? lng = (firstPlace['lng'] is num)
            ? (firstPlace['lng'] as num).toDouble()
            : null;

        if (lat != null && lng != null) {
          try {
            List<Placemark> placemarks =
                await placemarkFromCoordinates(lat, lng);
            if (placemarks.isNotEmpty &&
                placemarks.first.isoCountryCode != null) {
              regionCode = placemarks.first.isoCountryCode!.toLowerCase();
            }
          } catch (e) {
            print("Ülke kodu alınırken hata: $e");
          }
        }
      }

      // Firestore'da isShared flag'ini güncelle
      await docRef.update({
        'isShared': true,
        'sharedAt': FieldValue.serverTimestamp(),
      });

      // explore_routes koleksiyonuna ekleme (region eklendi)
      await exploreRef.set({
        'routeId': widget.routeId,
        'title': data?['title'] ?? 'Başlıksız',
        'places': data?['places'] ?? [],
        'mode': data?['mode'] ?? 'unknown',
        'sharedBy': data?['userId'] ?? 'anon',
        'sharedAt': FieldValue.serverTimestamp(),
        'likeCount': 0,
        'viewCount': 0,
        'region': regionCode,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text(
                "Rota keşfet sayfasında paylaşıldı.",
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
          backgroundColor: Colors.white,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hata oluştu: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Başlık düzenleme fonksiyonu
  void _editRouteTitle() async {
    TextEditingController _titleController = TextEditingController(
        text: _routeTitleFromFirestore ?? widget.routeTitle);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Rota Adını Düzenle"),
        content: TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2)),
            labelText: "Yeni Rota Başlığı",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newTitle = _titleController.text.trim();
              if (newTitle.isNotEmpty && newTitle != _routeTitleFromFirestore) {
                // Firestore güncelle
                await FirebaseFirestore.instance
                    .collection('routes') // koleksiyon adı
                    .doc(widget.routeId) // rota ID'si
                    .update({'title': newTitle});

                // UI güncellemesi
                setState(() {
                  _routeTitleFromFirestore = newTitle;
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rotayı Sil'),
        content: const Text(
          'Bu rotayı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('İptal'),
          ),
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop(); // dialogu kapat
              _deleteRoute(); // silme işlemini başlat
            },
            child: Text('Sil',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRoute() async {
    try {
      await FirebaseFirestore.instance
          .collection('routes')
          .doc(widget.routeId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rota başarıyla silindi'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop(); // Önceki sayfaya dön
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              Text('Silme işlemi başarısız: $e'),
            ],
          ),
        ),
      );
    }
  }
}
