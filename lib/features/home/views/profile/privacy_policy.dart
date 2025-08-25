import 'package:flutter/material.dart';
import 'package:story_map/l10n/app_localizations.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
    final sectionTitleStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
    final bodyStyle = TextStyle(fontSize: 16, height: 1.4); // daha okunabilir
    final greyStyle = TextStyle(fontSize: 14, color: Colors.grey);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.privacyPolicyTitle,
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.privacyPolicyTextTitle,
              style: titleStyle,
            ),
            SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.privacyPolicyLastUpdate,
              style: greyStyle,
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.privacyPolicyIntroTitle,
              style: sectionTitleStyle,
            ),
            Text(AppLocalizations.of(context)!.privacyPolicyIntroText, style: bodyStyle),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.privacyPolicyCollectedDataTitle,
              style: sectionTitleStyle,
            ),
            Text(AppLocalizations.of(context)!.privacyPolicyLocationData, style: bodyStyle),
            Text(
              "${AppLocalizations.of(context)!.privacyPolicyLocationDataText}\n"
              "${AppLocalizations.of(context)!.privacyPolicyLocationDataText2}",
              style: bodyStyle,
            ),
            SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.privacyPolicyUserDataTitle, style: bodyStyle.copyWith(fontWeight: FontWeight.w600)),
            Text(
              "${AppLocalizations.of(context)!.privacyPolicyUserDataText}\n"
              "${AppLocalizations.of(context)!.privacyPolicyUserDataText2}",
              style: bodyStyle,
            ),
            SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.privacyPolicyUsingAppTitle, style: bodyStyle.copyWith(fontWeight: FontWeight.w600)),
            Text(AppLocalizations.of(context)!.privacyPolicyUsingAppText, style: bodyStyle),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.privacyPolicyUsingDataTitle,
              style: sectionTitleStyle,
            ),
            Text(
              "${AppLocalizations.of(context)!.privacyPolicyUsingDataText}\n"
              "${AppLocalizations.of(context)!.privacyPolicyUsingDataText2}\n"
              "${AppLocalizations.of(context)!.privacyPolicyUsingDataText3}\n"
              "${AppLocalizations.of(context)!.privacyPolicyUsingDataText4}",
              style: bodyStyle,
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.privacyPolicyThirdPartyServicesTitle,
              style: sectionTitleStyle,
            ),
            Text(AppLocalizations.of(context)!.privacyPolicyThirdPartyServicesText, style: bodyStyle),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.privacyPolicyDataStorageTitle,
              style: sectionTitleStyle,
            ),
            Text(AppLocalizations.of(context)!.privacyPolicyDataStorageText, style: bodyStyle),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.privacyPolicyCookiesTitle,
              style: sectionTitleStyle,
            ),
            Text(AppLocalizations.of(context)!.privacyPolicyCookiesText, style: bodyStyle),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.privacyPolicyDataSharingTitle,
              style: sectionTitleStyle,
            ),
            Text(AppLocalizations.of(context)!.privacyPolicyDataSharingText, style: bodyStyle),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.privacyPolicyUserRightsTitle,
              style: sectionTitleStyle,
            ),
            Text(AppLocalizations.of(context)!.privacyPolicyUserRightsText, style: bodyStyle),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.privacyPolicyChangesTitle,
              style: sectionTitleStyle,
            ),
            Text(AppLocalizations.of(context)!.privacyPolicyChangesText, style: bodyStyle),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
