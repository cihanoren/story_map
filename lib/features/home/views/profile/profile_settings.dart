import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_map/core/theme/theme_provider.dart';
import 'package:story_map/features/auth/views/sing_in.dart';
import 'package:story_map/features/home/services.dart/delete_user.dart';
import 'package:story_map/features/home/views/profile/account__info.dart';
import 'package:story_map/features/home/views/profile/change_password.dart';
import 'package:story_map/features/home/views/profile/help_center.dart';
import 'package:story_map/features/home/views/profile/privacy_policy.dart';
import 'package:story_map/main.dart';

class ProfileSettingPage extends ConsumerStatefulWidget {
  const ProfileSettingPage({super.key});

  @override
  ConsumerState<ProfileSettingPage> createState() => _ProfileSettingPageState();
}

class _ProfileSettingPageState extends ConsumerState<ProfileSettingPage> {
  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Ayarlar",
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.manage_accounts_rounded),
            title: const Text("Hesap Bilgileri"),
            onTap: () {
              // Hesap bilgileri ekranına yönlendirme yapar
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountInfo(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Şifreyi Değiştir"),
            onTap: () {
              // Şifre değiştir ekranına yönlendirme yapar
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const ChangePassword();
              }));
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
          ListTile(
            leading: const Icon(Icons.policy_rounded),
            title: const Text("Gizlilik Politikası"),
            onTap: () {
              // Gizlilik Politikası ekranına yönlendirme yapar
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_rounded),
            title: const Text("Yardım ve Destek"),
            onTap: () {
              // Hesap bilgileri ekranına yönlendirme yapar
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpCenter(),
                ),
              );
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
          ),/*
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              "Hesabı Sil",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
            onTap: () async {
              await deleteUserAccount(context);
            },
          ),*/
        ],
      ),
    );
  }
}
