import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? "";
      _usernameController.text = user.email?.split("@").first ?? "Kullanıcı";
      // İsteğe göre bu alanlara da Firebase'den veri çekilebilir
      _nameController.text = "Adınız";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "Hesap Bilgileri",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(height: 1, color: Colors.grey.shade300),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/avatar.jpg'),
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
          onPressed: onEdit,
        ),
      ],
    );
  }
}
