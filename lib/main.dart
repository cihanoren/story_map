import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:story_map/core/locale/locale_provider.dart';
import 'package:story_map/core/theme/theme_provider.dart';
import 'package:story_map/core/theme/app_theme.dart';
import 'package:story_map/features/auth/views/sign_in.dart';
import 'package:story_map/features/home/services.dart/connectivity_service.dart';
import 'package:story_map/features/home/views/home.dart';
import 'package:story_map/l10n/app_localizations.dart';
import 'package:story_map/utils/marker_icons.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await MarkerIcons.loadIcons();
  await MobileAds.instance.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tema ve internet provider’ı
    final themeMode = ref.watch(themeProvider);
    ref.watch(connectivityServiceProvider);

    // ✅ Locale provider’dan değer al
    final currentLocale = ref.watch(localeProvider);

// Eğer locale null ise loading ekranı gösterebilirsin
    if (currentLocale == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeMode,
      home: const SplashPage(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: currentLocale,
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    final isPrefsLogin = prefs.getBool("is_logged_in") ?? false;
    final isLoggedIn = user != null && isPrefsLogin;

    if (user != null && !isPrefsLogin) {
      await prefs.setBool("is_logged_in", true);
    }

    await Future.delayed(const Duration(seconds: 2));

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Home()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => const SignIn(showVerificationMessage: false)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child:
          Image.asset("assets/images/StoryMap_splash.png", fit: BoxFit.cover),
    ));
  }
}
