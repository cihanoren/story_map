import 'package:flutter/material.dart';
import 'package:story_map/features/home/views/profile/feedback_page.dart';
import 'package:story_map/features/home/views/profile/report_issue.dart';

class HelpCenter extends StatefulWidget {
  const HelpCenter({super.key});

  @override
  State<HelpCenter> createState() => _HelpCenterState();
}

class _HelpCenterState extends State<HelpCenter> {
  final List<Map<String, String>> helpTopics = [
    {
      "title": "Hesap bilgilerini nasıl düzenlerim?",
      "content":
          "Profil sayfasındaki ayarlar simgesine tıklayarak kullanıcı adı ve e-posta gibi bilgileri düzenleyebilirsin.",
    },
    {
      "title": "Rota nasıl paylaşılır?",
      "content":
          "Bir rota oluşturduktan sonra 'Keşfette Paylaş' seçeneğini kullanarak rotanı keşfet bölümüne gönderebilirsin.",
    },
    {
      "title": "Beğendiğim rotaları nereden görebilirim?",
      "content":
          "Profil sayfasında 'Beğendiklerin' sekmesine tıklayarak daha önce beğendiğin rotaları görebilirsin.",
    },
    {
      "title": "Konum bilgilerimi nasıl değiştirebilirim?",
      "content":
          "Profil sayfasında konum kısmındaki kalem ikonuna tıklayarak manuel konum girişi yapabilirsin.",
    },
    {
      "title": "Sorun bildirimi nasıl yapabilirim?",
      "content":
          "Geliştiriciye ulaşmak için uygulama içindeki iletişim sekmesini kullanabilirsin (ileride e-posta desteği eklenebilir).",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Yardım Merkezi", style: TextStyle(color: Colors.black),),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: helpTopics.length,
              itemBuilder: (context, index) {
                final topic = helpTopics[index];
                return ExpansionTile(
                  title: Text(topic["title"] ?? ""),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text(
                        topic["content"] ?? "",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.feedback_outlined,
                        color: Colors.black),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FeedbackPage()),
                      );
                    },
                    label: const Text("Geri Bildirim Gönder",
                        style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.report_problem_outlined,
                        color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ReportIssuePage()),
                      );
                    },
                    label: const Text("Sorun Bildir",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
