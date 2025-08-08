import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:story_map/features/home/views/explore_route_details.dart';
import 'package:story_map/features/home/views/profile/profile_settings.dart';
import 'package:story_map/l10n/app_localizations.dart';

String? _userProfileImageUrl;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

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
              : CircleAvatar(child: Icon(Icons.map)),
          title: Text(
              route['title'] ?? AppLocalizations.of(context)!.unnamedRoute),
          subtitle:
              route['description'] != null ? Text(route['description']) : null,
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExploreRouteDetails(
                  routeId: route['routeId'],
                  routeTitle: route['title'],
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
              : CircleAvatar(child: Icon(Icons.map)),
          title: Text(
              route['title'] ?? AppLocalizations.of(context)!.unnamedRoute),
          subtitle:
              route['description'] != null ? Text(route['description']) : null,
          trailing: TextButton(
            onPressed: () {
              final exploreRouteId =
                  route['routeId']; // explore_routes koleksiyondaki id
              _removeRouteFromExplore(exploreRouteId);
            },
            child: Text(
              AppLocalizations.of(context)!.removeFromExplore,
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
          SnackBar(
            backgroundColor: Colors.white,
            content: Text(
              AppLocalizations.of(context)!.removeFromExploreSuccess,
              style: TextStyle(color: Colors.black),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Hata: ${e.toString()}",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
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
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context.mounted) {
          _showDialog(
            context: context,
            title: AppLocalizations.of(context)!.locationServiceDisable,
            content: AppLocalizations.of(context)!.openLocationServiceMessage,
            actionText: AppLocalizations.of(context)!.settings,
            onPressed: () {
              Geolocator.openLocationSettings();
            },
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          if (context.mounted) {
            _showDialog(
              context: context,
              title: AppLocalizations.of(context)!
                  .requiredAppLocationPermissionMessage,
              content: AppLocalizations.of(context)!.openLocationServiceMessage,
              actionText: AppLocalizations.of(context)!.actionOK,
            );
          }
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _loadSavedLocation();

      if (_locationDescription == null) {
        _updateLocation(position);
      }
    } catch (e) {
      if (context.mounted) {
        _showDialog(
          context: context,
          title: AppLocalizations.of(context)!.locationError,
          content:
              '${AppLocalizations.of(context)!.getLocationError}:\n${e.toString()}',
          actionText: AppLocalizations.of(context)!.actionOK,
        );
      }
    }
  }

  void _showDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String actionText,
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onPressed != null) onPressed();
            },
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  Future<void> _updateLocation(Position position) async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // İnternet yoksa konum çözümleme yapma
      setState(() {
        _position = position;
        _locationDescription = AppLocalizations.of(context)!.noConnection;
      });
      return;
    }

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      final place = placemarks.first;

      setState(() {
        _position = position;
        _locationDescription = "${place.locality}, ${place.administrativeArea}";
      });
    } catch (e) {
      setState(() {
        _position = position;
        _locationDescription = "Konum çözümlenemedi";
      });
      print("Geocoding hatası: $e");
    }
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
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.isAnonymous) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.profilPhotoChangeRule),
        ));
      }
      return;
    }

    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        _imageFile = file;
      });

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${user.uid}.jpg');
      await storageRef.putFile(file);
      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'profileImageUrl': imageUrl,
      });

      setState(() {
        _userProfileImageUrl = imageUrl;
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
              title: Text(AppLocalizations.of(context)!.chooseFromGallery),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppLocalizations.of(context)!.takePhoto),
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
        title: Text(AppLocalizations.of(context)!.enterLocationInfo),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.locationHintText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
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
            child: Text(
              AppLocalizations.of(context)!.save,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayLocation =
        _locationDescription ?? AppLocalizations.of(context)!.gettingLocation;

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
                        _username ?? AppLocalizations.of(context)!.username,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      if (!_isGuest)
                        Text(
                          _email ?? AppLocalizations.of(context)!.loadingEmail,
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
                      child: Text(
                          AppLocalizations.of(context)!.returnCurrentLocation),
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
                          AppLocalizations.of(context)!.liked,
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
                          AppLocalizations.of(context)!.shared,
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
                            ? Text(
                                AppLocalizations.of(context)!.noLikedRouteYet,
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              )
                            : _buildLikedRouteList(_likedRoutes)
                  else
                    _isLoadingOwnRoutes
                        ? const Center(child: CircularProgressIndicator())
                        : _userOwnRoutes.isEmpty
                            ? Text(
                                AppLocalizations.of(context)!.notSharedRouteYet,
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
