import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_map/core/locale/locale_provider.dart';
import 'package:story_map/l10n/app_localizations.dart';

class LanguageOptionsPage extends ConsumerWidget {
  const LanguageOptionsPage({super.key});

  Future<void> _changeLanguage(
    BuildContext context, WidgetRef ref, String code) async {
  // localeProvider kullanarak hem state hem prefs güncelleniyor
  ref.read(localeProvider.notifier).setLocale(Locale(code));

  Navigator.pop(context);
}


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    final languages = {
      "en": "English",
      "tr": "Türkçe",
      "de": "Deutsch",
      "fr": "Français",
      "es": "Español",
      "it": "Italiano",
      "ru": "Русский",
      "ar": "العربية",
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.languageOptions,
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: languages.entries.map((entry) {
          return RadioListTile<String>(
            title: Text(entry.value),
            value: entry.key,
            groupValue: currentLocale?.languageCode,
            onChanged: (val) {
              if (val != null) {
                _changeLanguage(context, ref, val);
              }
            },
          );
        }).toList(),
      ),
    );
  }
}
