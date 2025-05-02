import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      _showSnackbar("Yeni şifreler uyuşmuyor.");
      return;
    }

    if (newPassword.length < 6) {
      _showSnackbar("Yeni şifre en az 6 karakter olmalı.");
      return;
    }

    if (user != null && email != null) {
      try {
        setState(() => _isLoading = true);

        // Kimlik doğrulama
        final credential =
            EmailAuthProvider.credential(email: email, password: oldPassword);
        await user.reauthenticateWithCredential(credential);

        // Şifre güncelleme
        await user.updatePassword(newPassword);
        _showSnackbar("Şifre başarıyla güncellendi.");
        Navigator.pop(context); // geri dön
      } on FirebaseAuthException catch (e) {
        _showSnackbar(e.message ?? "Bir hata oluştu.");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text(
      message,
      style: TextStyle(color: Colors.white),
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title:
            Text("Şifre Değiştir", style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPasswordField("Eski Şifre", _oldPasswordController),
            const SizedBox(height: 16),
            _buildPasswordField("Yeni Şifre", _newPasswordController),
            const SizedBox(height: 16),
            _buildPasswordField(
                "Yeni Şifre (Tekrar)", _confirmPasswordController),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).splashColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: _isLoading ? null : _changePassword,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Şifreyi Değiştir", style:TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }
}
