import 'package:flutter/material.dart';
import 'package:story_map/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  Future<void> _sendEmail(BuildContext context, String message) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'orencihan31@gmail.com', // kendi mailini yazabilirsin
      query: Uri.encodeFull('subject=Uygulama Geri Bildirimi&body=$message'),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      debugPrint(AppLocalizations.of(context)!.notOpenMailApp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.feedback,
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
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
            Text(AppLocalizations.of(context)!.feedbackMessageInfo),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.feedbackHintText, // "Geri bildirim mesajınızı buraya yazın..."
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              onPressed: () {
                final message = controller.text.trim();
                if (message.isNotEmpty) {
                  _sendEmail(context, message);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(AppLocalizations.of(context)!.openingMailApp), // "Mail uygulaması açılıyor..."
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
