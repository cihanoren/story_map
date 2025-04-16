import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:story_map/features/home/views/profile/profile_settings.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final picker = ImagePicker();
  File? _imageFile;
  String? _email;
  String? _username;
  Position? _position;
  String? _locationDescription;
  bool _isUsingStaticLocation = false;
  LatLng? _staticLocation;

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
    _fetchCurrentLocation();
  }

  Future<void> _fetchUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _email = user?.email;
      _username = user?.email?.split("@").first;
    });
  }

  Future<void> _fetchCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _updateLocation(position);
  }

  Future<void> _updateLocation(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    final place = placemarks.first;

    setState(() {
      _position = position;
      _locationDescription = "${place.locality}, ${place.administrativeArea}";
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
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
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _staticLocation = LatLng(position.latitude, position.longitude);
      _isUsingStaticLocation = true;
    });
    _updateLocation(position);
  }

  @override
Widget build(BuildContext context) {
  final displayLocation = _locationDescription ?? "Konum alınıyor...";

  return Scaffold(
    body: SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showImagePickerOptions,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : const AssetImage("assets/images/avatar.jpg") as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _username ?? "Kullanıcı Adı",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _email ?? "E-posta yükleniyor...",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
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
                          _isUsingStaticLocation = false;
                          _fetchCurrentLocation();
                        },
                        child: const Text("Anlık konuma geri dön"),
                      ),
                  ],
                ),
              ),
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
                  MaterialPageRoute(builder: (_) => const ProfileSettingPage()),
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
