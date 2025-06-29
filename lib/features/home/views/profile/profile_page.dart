import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:story_map/features/home/views/card_details.dart';
import 'package:story_map/features/home/views/profile/profile_settings.dart';

String? _userProfileImageUrl;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final RefreshController _refreshController = RefreshController();

  final picker = ImagePicker();
  File? _imageFile;
  String? _email;
  String? _username;
  Position? _position;
  String? _locationDescription;
  bool _isUsingStaticLocation = false;
  LatLng? _staticLocation;
  bool _isGuest = false;
  String? userId;

  List<Map<String, dynamic>> _likedRoutes = [];
  bool _isLoadingLikedRoutes = true;

  bool showLikedRoutes = true;
  List<Map<String, dynamic>> _userOwnRoutes = [];
  bool _isLoadingOwnRoutes = true;

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
    _fetchCurrentLocation();
    _fetchLikedRoutes();
    _fetchUserOwnRoutes();
  }

  // Beğendiğin Rotalar için (yönlendirme içerir)
  Widget _buildLikedRouteList(List<Map<String, dynamic>> routes) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: routes.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final route = routes[index];
        return ListTile(
          leading: route['imageUrl'] != null
              ? CircleAvatar(backgroundImage: NetworkImage(route['imageUrl']))
              : const CircleAvatar(child: Icon(Icons.map)),
          title: Text(route['title'] ?? 'Başlıksız Rota'),
          subtitle:
              route['description'] != null ? Text(route['description']) : null,
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CardDetails(
                  routeId: route['routeId'],
                  routeTitle: route['title'],
                  placeNames: [],
                  imagesUrls: [],
                ),
              ),
            );
          },
        );
      },
    );
  }

// Paylaşılan Rotalar için (kaldırma içerir)
  Widget _buildOwnRouteList(List<Map<String, dynamic>> routes) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: routes.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final route = routes[index];
        return ListTile(
          leading: route['imageUrl'] != null
              ? CircleAvatar(backgroundImage: NetworkImage(route['imageUrl']))
              : const CircleAvatar(child: Icon(Icons.map)),
          title: Text(route['title'] ?? 'Başlıksız Rota'),
          subtitle:
              route['description'] != null ? Text(route['description']) : null,
          trailing: TextButton(
            onPressed: () {
              final exploreRouteId =
                  route['routeId']; // explore_routes koleksiyondaki id              
              _removeRouteFromExplore(exploreRouteId);
            },
            child: const Text(
              "Keşfetten Kaldır",
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      },
    );
  }

// Rota keşfetten kaldırma işlemi
  Future<void> _removeRouteFromExplore(String routeId) async {
    try {
      await FirebaseFirestore.instance
          .collection('explore_routes')
          .doc(routeId)
          .delete();

      await _fetchUserOwnRoutes();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Rota keşfetten kaldırıldı.")),
        );
      }
    } catch (e) {
      print("Hata oluştu: $e");
    }
  }

  // Kullanıcı e-postasını ve profil bilgilerini al
  Future<void> _fetchUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;

      if (user.isAnonymous) {
        setState(() {
          _isGuest = true;
          _username = "guest$userId";
          _email = null;
        });
      } else {
        _email = user.email;

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final data = userDoc.data();

        if (data != null) {
          setState(() {
            _username = data['username'] ?? _email!.split("@").first;
            _userProfileImageUrl = data['profileImageUrl'];
          });

          if (data['username'] == null && _email != null) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
              'username': _email!.split("@").first,
            }, SetOptions(merge: true));
          }
        } else if (_email != null) {
          final generatedUsername = _email!.split("@").first;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'username': generatedUsername,
          });
          setState(() {
            _username = generatedUsername;
          });
        }
      }
    }
  }

  // Kullanıcının beğendiği rotaları al
  // Bu fonksiyon, kullanıcı oturum açtığında veya profil sayfası ilk yüklendiğinde çağrılır.
  // Beğenilen rotalar, Firestore'dan alınır ve listeye eklenir.
  Future<void> _fetchLikedRoutes() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('explore_routes')
        .where('likedBy', arrayContains: userId)
        .get();

    final routes = snapshot.docs.map((doc) {
      final data = doc.data();
      data['routeId'] = doc.id;
      return data;
    }).toList();

    setState(() {
      _likedRoutes = routes;
      _isLoadingLikedRoutes = false;
    });
  }

  // Kullanıcının kendi oluşturduğu rotaları al
  // Bu fonksiyon, kullanıcının kendi oluşturduğu rotaları Firestore'dan alır.
  Future<void> _fetchUserOwnRoutes() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('explore_routes')
        .where('sharedBy', isEqualTo: uid)
        .get();

    final routes = snapshot.docs.map((doc) {
      final data = doc.data();
      data['routeId'] = doc.id;
      return data;
    }).toList();

    setState(() {
      _userOwnRoutes = routes;
      _isLoadingOwnRoutes = false;
    });
  }

  // Kullanıcının konumunu al
  // Bu fonksiyon, kullanıcının cihazının konumunu alır ve eğerini günceller.
  // Eğer kullanıcı konum izni vermemişse, izin istenir.
  Future<void> _fetchCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    await _loadSavedLocation();

    if (_locationDescription == null) {
      _updateLocation(position);
    }
  }

  Future<void> _updateLocation(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    final place = placemarks.first;

    setState(() {
      _position = position;
      _locationDescription = "${place.locality}, ${place.administrativeArea}";
    });
  }

  Future<void> _loadSavedLocation() async {
    if (userId != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data['savedLocation'] != null) {
          setState(() {
            _locationDescription = data['savedLocation'];
          });
        }
      }
    }
  }

  Future<void> _saveLocation() async {
    if (userId != null && _locationDescription != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'savedLocation': _locationDescription,
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        _imageFile = file;
      });

      if (userId != null) {
        final storageRef =
            FirebaseStorage.instance.ref().child('profile_images/$userId.jpg');
        await storageRef.putFile(file);
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'profileImageUrl': imageUrl,
        });
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Galeriden Seç"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Kamera ile Çek"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStaticLocation() async {
    final TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konum Bilgisi Gir"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Örn: Artvin, Merkez",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _locationDescription = controller.text.trim();
                  _isUsingStaticLocation = true;
                });
                _saveLocation();
              }
              Navigator.pop(context);
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayLocation = _locationDescription ?? "Konum alınıyor...";

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              header: WaterDropMaterialHeader(
                backgroundColor: Colors.deepPurple,
                color: Colors.white,
              ),
              onRefresh: () async {
                await _fetchUserEmail();
                await _fetchCurrentLocation();
                await _fetchLikedRoutes();
                await _fetchUserOwnRoutes();
                setState(() {
                  _refreshController.refreshCompleted();
                });
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _showImagePickerOptions,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : (_userProfileImageUrl != null
                                  ? NetworkImage(_userProfileImageUrl!)
                                  : const AssetImage('assets/images/avatar.jpg')
                                      as ImageProvider),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _username ?? "Kullanıcı Adı",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      if (!_isGuest)
                        Text(
                          _email ?? "E-posta yükleniyor...",
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        displayLocation,
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: _selectStaticLocation,
                      ),
                    ],
                  ),
                  if (_isUsingStaticLocation)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isUsingStaticLocation = false;
                        });
                        _fetchCurrentLocation();
                      },
                      child: const Text("Anlık konuma geri dön"),
                    ),

                  // -- Beğenilen Rotalar Bölümü --
                  // --- Sekme Butonları ---
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            showLikedRoutes = true;
                          });
                        },
                        child: Text(
                          "Beğendiklerin",
                          style: TextStyle(
                            fontWeight: showLikedRoutes
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: showLikedRoutes
                                ? Colors.deepPurple
                                : Colors.black,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            showLikedRoutes = false;
                          });
                        },
                        child: Text(
                          "Paylaşımların",
                          style: TextStyle(
                            fontWeight: !showLikedRoutes
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: !showLikedRoutes
                                ? Colors.deepPurple
                                : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  if (showLikedRoutes)
                    _isLoadingLikedRoutes
                        ? const Center(child: CircularProgressIndicator())
                        : _likedRoutes.isEmpty
                            ? const Text(
                                "Henüz beğendiğin bir rota yok.",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              )
                            : _buildLikedRouteList(_likedRoutes)
                  else
                    _isLoadingOwnRoutes
                        ? const Center(child: CircularProgressIndicator())
                        : _userOwnRoutes.isEmpty
                            ? const Text(
                                "Henüz rota paylaşmamışsın.",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              )
                            : _buildOwnRouteList(_userOwnRoutes),
                ],
              ),
            ),
            Positioned(
              top: 5,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProfileSettingPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LatLng {
  final double latitude;
  final double longitude;
  LatLng(this.latitude, this.longitude);
}

//! Kullanıcının beğendiği rotalardan detay sayfasına gidildiğinde 
//! keşfette paylaş gibi kısımların olmaması lazım sadece beğeniyi geri alabileceği
//! bir sayfa olmalı. Bu yüzden CardDetails sayfasında keşfette paylaş gibi kısımlar kaldırılacak.