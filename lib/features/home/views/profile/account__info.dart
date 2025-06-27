import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

String? _userProfileImageUrl; // class'ın en üstüne ekle

class AccountInfo extends StatefulWidget {
  const AccountInfo({super.key});

  @override
  State<AccountInfo> createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isEditingUsername = false;
  bool _isEditingEmail = false;
  bool _isEditingName = false;
  final picker = ImagePicker();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? "";

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final userData = doc.data();
        _nameController.text = userData?['displayName'] ?? "Adınız";
        _usernameController.text = userData?['username'] ??
            user.email?.split("@").first ??
            "Kullanıcı";

        // Profil fotoğrafı
        final imageUrl = userData?['profileImageUrl'];
        _userProfileImageUrl = userData?['profileImageUrl'];

        if (imageUrl != null) {
          setState(() {
            _imageFile = null; // Firebase'deki fotoğrafı göstereceğiz
          });
        }
      }
    }
  }

  Future<void> _updateUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newUsername = _usernameController.text.trim();

    try {
      // Kullanıcı adını başkası kullanıyor mu kontrol et
      final existingUsers = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: newUsername)
          .get();

      // Eğer bu kullanıcı dışında biri bu kullanıcı adını kullanıyorsa
      final isUsernameTaken =
          existingUsers.docs.any((doc) => doc.id != user.uid);

      if (isUsernameTaken) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.yellow[700],
          content: Text(
              "Bu kullanıcı adı zaten kullanımda. Lütfen başka bir ad seçin."),
        ));
        return;
      }

      // Güncelleme işlemi
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'displayName': _nameController.text.trim(),
        'username': newUsername,
        'email': _emailController.text.trim(),
        'updatedAt': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Bilgiler başarıyla güncellendi")),
      );
    } catch (e) {
      print("Profil güncelleme hatası: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bilgiler güncellenirken hata oluştu")),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      setState(() {
        _imageFile = imageFile;
      });

      await _uploadImageToFirebase(imageFile);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Hesap Bilgileri",
          style:
              TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchUserData();
          setState(() {});
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (_userProfileImageUrl != null
                            ? NetworkImage(_userProfileImageUrl!)
                            : const AssetImage('assets/images/avatar.jpg')
                                as ImageProvider),
                  ),
                ),
                const SizedBox(height: 20),
                _buildEditableField(
                  label: "Adı",
                  controller: _nameController,
                  isEditing: _isEditingName,
                  onEdit: () {
                    setState(() => _isEditingName = !_isEditingName);
                  },
                ),
                const SizedBox(height: 16),
                _buildEditableField(
                  label: "Kullanıcı Adı",
                  controller: _usernameController,
                  isEditing: _isEditingUsername,
                  onEdit: () {
                    setState(() => _isEditingUsername = !_isEditingUsername);
                  },
                ),
                const SizedBox(height: 16),
                _buildEditableField(
                  label: "E-posta",
                  controller: _emailController,
                  isEditing: _isEditingEmail,
                  onEdit: () {
                    setState(() => _isEditingEmail = !_isEditingEmail);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onEdit,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            readOnly: !isEditing,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(isEditing ? Icons.check : Icons.edit),
          onPressed: () {
            if (isEditing) {
              _updateUserProfile(); // Kaydetme işlemi
            }
            onEdit(); // Edit modu aç/kapat
          },
        ),
      ],
    );
  }

  Future<String?> _uploadImageToFirebase(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');

      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      setState(() {
        _userProfileImageUrl = downloadUrl;
      });

      // Firestore'a profil resmi URL'sini kaydet
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'profileImageUrl': downloadUrl,
      });

      return downloadUrl;
    } catch (e) {
      print('Fotoğraf yüklenemedi: $e');
      return null;
    }
  }
}
