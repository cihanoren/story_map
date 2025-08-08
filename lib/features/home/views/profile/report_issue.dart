import 'package:flutter/material.dart';
import 'package:story_map/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ReportIssuePage extends StatelessWidget {
  const ReportIssuePage({super.key});

  Future<void> _sendEmail(BuildContext context, String message) async {
    final email = 'orencihan31@gmail.com';
    final subject = Uri.encodeComponent('Uygulama Hata Bildirimi');
    final body = Uri.encodeComponent(message);

    final url = 'mailto:$email?subject=$subject&body=$body';

    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      debugPrint(AppLocalizations.of(context)!
          .notOpenMailApp); // "Mail uygulaması açılamadı"
      // Burada kullanıcıya mail uygulaması yok uyarısı da verebilirsin.
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.reportIssue, // "Hata Bildir"
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(AppLocalizations.of(context)!
                .issueBoxTitle), // Karşılaştığınız sorunu detaylı bir şekilde yazın mesajı
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!
                    .issueHintText, // "Karşılaştığınız sorunu detaylı bir şekilde yazın"
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Buton rengi kırmızı
              ),
              onPressed: () {
                final message = controller.text.trim();
                if (message.isNotEmpty) {
                  _sendEmail(context, message);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.openingMailApp, // "Mail uygulaması açılıyor..."
                      ), 
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: Text(
                AppLocalizations.of(context)!.send, // "Gönder"
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
