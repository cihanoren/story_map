import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_map/core/theme/theme_provider.dart';
import 'package:story_map/features/auth/views/sign_in.dart';
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
          AppLocalizations.of(context)!.settings,
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
            title: Text(AppLocalizations.of(context)!.accountInfo),
            onTap: () {
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
            title: Text(AppLocalizations.of(context)!.changePassword),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const ChangePassword();
              }));
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(AppLocalizations.of(context)!.notificationSettings),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(AppLocalizations.of(context)!.languageOptions),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LanguageOptionsPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: Text(currentTheme == ThemeMode.dark
                ? AppLocalizations.of(context)!.lightMode
                : AppLocalizations.of(context)!.darkMode),
            onTap: () {
              final newTheme = currentTheme == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
              ref.read(themeProvider.notifier).state = newTheme;
            },
          ),
          ListTile(
            leading: const Icon(Icons.policy_rounded),
            title: Text(AppLocalizations.of(context)!.privacyPolicy),
            onTap: () {
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
            title: Text(AppLocalizations.of(context)!.helpAndSupport),
            onTap: () {
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
            leading: const Icon(Icons.logout_outlined, color: Colors.red),
            title: Text(
              AppLocalizations.of(context)!.logOut,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.logOut),
                  content: Text(AppLocalizations.of(context)!.logOutConfirmation),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(AppLocalizations.of(context)!.cancel),
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
                    builder: (_) => const SignIn(showVerificationMessage: false),
                  ),
                  (route) => false,
                );
              }
            },
          ),

          // 🗑️ Hesap Sil Butonu
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(
              AppLocalizations.of(context)!.deleteAccount,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Hesabı Sil"),
                  content: const Text(
                      "Hesabınızı kalıcı olarak silmek istediğinize emin misiniz? Bu işlem geri alınamaz."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("İptal"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Evet, Sil"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await deleteUserAccount(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

// Hesap silme fonksiyonu
Future<void> deleteUserAccount(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final firestore = FirebaseFirestore.instance;
  final messenger = ScaffoldMessenger.of(context);

  try {
    final uid = user.uid;

    // 🔹 1. USERS koleksiyonundaki kullanıcıyı sil
    await firestore.collection('users').doc(uid).delete();

    // 🔹 2. ROUTES koleksiyonundaki kullanıcı rotalarını sil
    final routesSnap = await firestore
        .collection('routes')
        .where('userId', isEqualTo: uid)
        .get();
    for (var doc in routesSnap.docs) {
      await doc.reference.delete();
    }

    // 🔹 3. EXPLORE_ROUTES koleksiyonundaki kullanıcının paylaşımlarını sil
    final exploreSnap = await firestore
        .collection('explore_routes')
        .where('sharedBy', isEqualTo: uid)
        .get();
    for (var doc in exploreSnap.docs) {
      await doc.reference.delete();
    }

    // 🔹 4. COMMENTS alt koleksiyonlarındaki kullanıcı yorumlarını sil
    // 🔹 Kullanıcının tüm yorumlarını sil (varsa)
final commentsRoot = await firestore.collection('comments').get();
for (var placeDoc in commentsRoot.docs) {
  final entriesSnap = await placeDoc.reference
      .collection('entries')
      .where('userId', isEqualTo: user.uid)
      .get();

  if (entriesSnap.docs.isNotEmpty) {
    for (var entryDoc in entriesSnap.docs) {
      await entryDoc.reference.delete();
    }
  }
  // Eğer kullanıcı bu mekan altında hiç yorum yapmamışsa, döngü atlanır
}

    // 🔹 5. Authentication’dan kullanıcıyı sil
    await user.delete();

    // 🔹 6. SharedPreferences temizle
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // 🔹 7. Başarılı mesaj + yönlendirme
    messenger.showSnackBar(
      const SnackBar(content: Text("Hesabınız ve tüm verileriniz silindi.")),
    );

    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const SignIn(showVerificationMessage: false),
      ),
      (route) => false,
    );
  } on FirebaseAuthException catch (e) {
    if (e.code == 'requires-recent-login') {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            "Bu işlemi gerçekleştirmek için lütfen yeniden giriş yapın ve tekrar deneyin.",
          ),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text("Bir hata oluştu: ${e.message}")),
      );
    }
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text("Hesap silme hatası: $e")),
    );
  }
}