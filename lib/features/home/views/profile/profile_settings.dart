import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_map/core/theme/theme_provider.dart';
import 'package:story_map/features/auth/views/sing_in.dart';
import 'package:story_map/main.dart';

class ProfileSettingPage extends ConsumerStatefulWidget {
  const ProfileSettingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileSettingPage> createState() => _ProfileSettingPageState();
}

class _ProfileSettingPageState extends ConsumerState<ProfileSettingPage> {
  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Ayarlar")),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Şifreyi Değiştir"),
            onTap: () {
              // Şifre değiştir ekranına yönlendirme yapılabilir
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Bildirim Ayarları"),
            onTap: () {
              // Bildirim ayarları ekranına yönlendirme yapılabilir
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Dil Seçenekleri"),
            onTap: () {
              // Dil seçimi ekranına yönlendirme yapılabilir
            },
          ),

          // 🔁 Tema Değiştir Butonu
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: Text(currentTheme == ThemeMode.dark
                ? "Açık Temaya Geç"
                : "Koyu Temaya Geç"),
            onTap: () {
              final newTheme = currentTheme == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
              ref.read(themeProvider.notifier).state = newTheme;
            },
          ),

          const Divider(),

          // 🚪 Çıkış Yap Butonu
          ListTile(
            leading: const Icon(
              Icons.logout_outlined,
              color: Colors.red,
            ),
            title: const Text(
              "Çıkış Yap",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Çıkış Yap"),
                  content: const Text(
                      "Oturumunuzu kapatmak istediğinizden emin misiniz?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("İptal"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Çıkış Yap"),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                await FirebaseAuth.instance.signOut();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool("is_logged_in", false);

                navigatorKey.currentState?.pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) =>
                        const SignIn(showVerificationMessage: false),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
