import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod/riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:story_map/features/auth/repository/auth_repository.dart';

// Kullanıcı oturum durumunu takip eden provider
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).auth.authStateChanges();
});

// Auth Controller Provider
final authControllerProvider = StateNotifierProvider<AuthController, User?>(
  (ref) => AuthController(authRepository: ref.watch(authRepositoryProvider)),
);

class AuthController extends StateNotifier<User?> {
  final AuthRepository authRepository;

  AuthController({required this.authRepository}) : super(null) {
    _loadCurrentUser();
  }

  // Mevcut kullanıcıyı yükle
  void _loadCurrentUser() {
    state = authRepository.getCurrentUser();
  }

  // Kullanıcı giriş yapıyor
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      User? user = await authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        if (!user.emailVerified) {
          throw Exception("Lütfen e-posta adresinizi doğrulayın.");
        }
        state = user;
      }
    } catch (e) {
      throw Exception("Giriş başarısız: ${e.toString()}");
    }
  }

  // Kullanıcı kayıt oluyor
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      User? user = await authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        // Firestore'a kullanıcıyı kaydet
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        await userDoc.set({
          'uid': user.uid,
          'email': user.email,
          'username': null, // kullanıcı sonradan ekler
          'fullName': null,
          'createdAt': FieldValue.serverTimestamp(),
          'photoUrl': null,
          'location': null,
        });

        state = user;
      }
    } catch (e) {
      throw Exception("Kayıt başarısız: ${e.toString()}");
    }
  }

  // Kullanıcı çıkış yapıyor
  Future<void> signOut() async {
    try {
      await authRepository.signOut();
      state = null;
    } catch (e) {
      throw Exception("Çıkış işlemi başarısız: ${e.toString()}");
    }
  }

  // Şifre sıfırlama
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await authRepository.sendPasswordResetEmail(email);
    } catch (e) {
      throw Exception("Şifre sıfırlama hatası: ${e.toString()}");
    }
  }

  // ✅ Anonim Giriş Yapma
  Future<void> signInAnonymously() async {
  try {
    UserCredential? userCredential = await authRepository.signInAnonymously();

    final user = userCredential?.user;
    if (user != null) {
      state = user;

      // Firestore'a kullanıcıyı kaydet
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        await userDoc.set({
          'uid': user.uid,
          'email': user.email,
          'createdAt': DateTime.now(),
          'isAnonymous': user.isAnonymous,
        });
      }
    }
  } catch (e) {
    print("❌ Anonim giriş hatası: $e");
    throw Exception("Anonim giriş başarısız: ${e.toString()}");
  }
}

}
