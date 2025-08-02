import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_map/features/auth/views/sing_in.dart';
import 'package:story_map/main.dart';

Future<void> deleteUserAccount(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userId = user.uid;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Hesabı Sil"),
      content: const Text(
        "Hesabınızı ve tüm verilerinizi kalıcı olarak silmek istediğinize emin misiniz?",
      ),
      actions: [
        TextButton(
          child: const Text("İptal"),
          onPressed: () => Navigator.pop(ctx, false),
        ),
        TextButton(
          child: const Text("Sil"),
          onPressed: () => Navigator.pop(ctx, true),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  try {
    // ✅ Firestore'daki kullanıcı verileri silinir
    final firestore = FirebaseFirestore.instance;

    // 1. Kullanıcı profil dokümanı (örneğin "users" koleksiyonu)
    await firestore.collection('users').doc(userId).delete();

    // 2. Kullanıcıya ait diğer koleksiyonlar (örnek: routes, favorites, comments)
    final subCollections = ['routes', 'favorites', 'comments'];
    for (final col in subCollections) {
      final snapshot = await firestore
          .collection(col)
          .where('userId', isEqualTo: userId)
          .get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }

    // ✅ Firebase Auth kullanıcı hesabı silinir
    await user.delete();

    // ✅ Oturum verisi temizlenir
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("is_logged_in", false);

    // ✅ Ana sayfaya yönlendirme
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignIn(showVerificationMessage: false)),
      (route) => false,
    );
  } on FirebaseAuthException catch (e) {
    if (e.code == 'requires-recent-login') {
      // Kullanıcının hesabını silmek için kısa süre önce yeniden oturum açması gerekir
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen hesabınızı silmeden önce tekrar oturum açın."),
        ),
      );

      // Giriş ekranına yönlendir (yeniden doğrulama için)
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (_) => const SignIn(showVerificationMessage: true),
      ));
    } else {
      debugPrint("FirebaseAuthException: ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hesap silinemedi: ${e.message}")),
      );
    }
  } catch (e) {
    debugPrint("Hesap silme hatası: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Hesap silinirken bir hata oluştu.")),
    );
  }
}
