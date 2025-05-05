import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
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
  static int guestCounter = 1; // Misafir sayaç
  String? userId;

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
    _fetchCurrentLocation();
  }

  Future<void> _fetchUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;

      if (user.isAnonymous) {
        setState(() {
          _isGuest = true;
          _username = "guest$userId"; // userId kullanıldı
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

          // Eğer username yoksa Firestore'a ekle
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

    // Firestore'dan kaydedilen konumu al
    await _loadSavedLocation();

    if (_locationDescription == null) {
      // Kaydedilmiş bir konum yoksa anlık konumu al
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

        // Firestore’a profil fotoğrafı URL’sini kaydet
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
                _saveLocation(); // Konumu kaydet
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
                await _fetchUserEmail(); // Kullanıcı bilgilerini güncelle
                await _fetchCurrentLocation(); // Konum bilgisini güncelle
                setState(() {
                  _refreshController.refreshCompleted(); // Bunu ekle
                }); // Yeniden çizim
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
