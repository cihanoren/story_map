import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_map/core/theme/theme_provider.dart';
import 'package:story_map/features/auth/views/sing_in.dart';
import 'firebase_options.dart';

// 🌍 Uygulama genelinde kullanılacak `navigatorKey`
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const ProviderScope(child: MyApp()));
}

// ✅ `StatelessWidget` yerine `ConsumerWidget` kullanıyoruz
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return MaterialApp(
      navigatorKey: navigatorKey, // ✅ Global navigatorKey eklendi
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const SignIn(showVerificationMessage: false), // Ana ekran

      // 📌 Sayfa yönlendirme desteği
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/signin':
            return MaterialPageRoute(builder: (_) => const SignIn(showVerificationMessage: false));
          // 📌 Buraya yeni sayfalar ekleyebilirsin
          default:
            return null;
        }
      },
    );
  }
}
