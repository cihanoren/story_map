import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_map/core/theme/theme_provider.dart';
import 'package:story_map/features/auth/views/sign_in.dart';
// import 'package:story_map/features/home/services.dart/delete_user.dart';
import 'package:story_map/features/home/views/profile/account__info.dart';
import 'package:story_map/features/home/views/profile/change_password.dart';
import 'package:story_map/features/home/views/profile/help_center.dart';
import 'package:story_map/features/home/views/profile/language_options_page.dart';
import 'package:story_map/features/home/views/profile/privacy_policy.dart';
import 'package:story_map/l10n/app_localizations.dart';
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.settings, // "Ayarlar"
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
            title: Text(
                AppLocalizations.of(context)!.accountInfo), // "Hesap Bilgileri"
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
            title: Text(AppLocalizations.of(context)!
                .changePassword), // "Şifre Değiştir"
            onTap: () {
              // Şifre değiştir ekranına yönlendirme yapar
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const ChangePassword();
              }));
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(AppLocalizations.of(context)!
                .notificationSettings), // "Bildirim Ayarları"
            onTap: () {
              // Bildirim ayarları ekranına yönlendirme yapılabilir
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(AppLocalizations.of(context)!
                .languageOptions), // "Dil Seçenekleri"
            onTap: () {
              // Dil seçimi ekranına yönlendirme yapılabilir
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LanguageOptionsPage(),
                ),
              );
            },
          ),

          // 🔁 Tema Değiştir Butonu
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: Text(currentTheme == ThemeMode.dark
                ? AppLocalizations.of(context)!.lightMode // "Açık Temaya Geç"
                : AppLocalizations.of(context)!.darkMode), // "Koyu Temaya Geç"
            onTap: () {
              final newTheme = currentTheme == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
              ref.read(themeProvider.notifier).state = newTheme;
            },
          ),
          ListTile(
            leading: const Icon(Icons.policy_rounded),
            title: Text(AppLocalizations.of(context)!
                .privacyPolicy), // "Gizlilik Politikası"
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
            title: Text(AppLocalizations.of(context)!
                .helpAndSupport), // "Yardım Merkezi"
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
            title: Text(
              AppLocalizations.of(context)!.logOut, // "Çıkış Yap"
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.logOut),
                  content: Text(AppLocalizations.of(context)!
                      .logOutConfirmation), // "Çıkış yapmak istediğinize emin misiniz?"

                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child:
                          Text(AppLocalizations.of(context)!.cancel), // "İptal"
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(AppLocalizations.of(context)!.logOut),
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
          ), /*
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(
              AppLocalizations.of(context)!.deleteAccount, // "Hesabı Sil"
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
