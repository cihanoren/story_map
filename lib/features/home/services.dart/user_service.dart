/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateUserProfile({
    required String displayName,
    required String location,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("Giriş yapmış bir kullanıcı bulunamadı.");
    }

    final userDocRef = _firestore.collection('users').doc(user.uid);

    try {
      await userDocRef.update({
        'displayName': displayName,
        'location': location,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception("Profil güncelleme hatası: ${e.toString()}");
    }
  }

  Future<void> updateUserEmail({
  required String newEmail,
  required String password, // Mevcut şifre gerekli!
}) async {
  final user = _auth.currentUser;

  if (user == null || user.email == null) {
    throw Exception("Giriş yapmış bir kullanıcı bulunamadı.");
  }

  final credential = EmailAuthProvider.credential(
    email: user.email!,
    password: password,
  );

  try {
    // Yeniden kimlik doğrulama (required for sensitive operations)
    await user.reauthenticateWithCredential(credential);

    // E-posta güncelleme
    await user.updateEmail(newEmail);

    // Eğer Firestore'da da email alanı varsa orada da güncelle
    final userDocRef = _firestore.collection('users').doc(user.uid);
    await userDocRef.update({
      'email': newEmail,
      'updatedAt': DateTime.now(),
    });
  } on FirebaseAuthException catch (e) {
    throw Exception("E-posta güncelleme hatası: ${e.message}");
  } catch (e) {
    throw Exception("Bilinmeyen hata: ${e.toString()}");
  }
}

}*/
