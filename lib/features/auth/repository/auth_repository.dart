import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod/riverpod.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(auth: FirebaseAuth.instance));

class AuthRepository {
  final FirebaseAuth auth;

  AuthRepository({required this.auth});

  // Kullanıcı giriş yapıyor
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      await user?.reload(); // Kullanıcı bilgilerini güncelle

      if (user != null && user.emailVerified) {
        return user;
      } else {
        await signOut(); // Eğer e-posta doğrulanmamışsa çıkış yap
        throw Exception("Lütfen e-posta adresinizi doğrulayın.");
      }
    } catch (e) {
      throw Exception("Giriş başarısız: ${e.toString()}");
    }
  }

  // Kullanıcı kayıt oluyor ve e-posta doğrulama gönderiliyor
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      await user?.sendEmailVerification(); // Kullanıcıya doğrulama e-postası gönder

      return user;
    } catch (e) {
      throw Exception("Kayıt başarısız: ${e.toString()}");
    }
  }

  // Kullanıcı çıkış yapıyor
  Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      throw Exception("Çıkış işlemi başarısız: ${e.toString()}");
    }
  }

  // Mevcut kullanıcıyı al
  User? getCurrentUser() {
    return auth.currentUser;
  }

  // Şifremi unuttum işlemi
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception("Şifre sıfırlama hatası: ${e.toString()}");
    }
  }

    // Anonim Giriş Yapma
  Future<UserCredential?> signInAnonymously() async {
    try {
      UserCredential userCredential = await auth.signInAnonymously();
      print("Anonim Giriş Başarılı: ${userCredential.user?.uid}");
      return userCredential;
    } catch (e) {
      print("Anonim Giriş Hatası: $e");
      return null;
    }
  }

  
}
