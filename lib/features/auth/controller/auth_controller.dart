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
      await authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
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
      if (userCredential != null) {
        state = userCredential.user; // Kullanıcı oturumu başlatıldı
      }
    } catch (e) {
      print("❌ Anonim giriş hatası: $e");
    }
  }

  
}
