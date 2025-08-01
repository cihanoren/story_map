import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:story_map/core/config.dart';

class StoryService {
  static const String _apiUrl = "https://api.openai.com/v1/chat/completions";
  static const String _model = "gpt-3.5-turbo"; // Kullanılan openai modeli, ileride yükseltilebilir
  // OpenAI API anahtarını Config sınıfından alıyoruz

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<String> fetchStory(String placeName) async {
    try {
      // 1. Firestore'dan hikayeyi kontrol et
      final docSnapshot = await _firestore
          .collection('places')
          .doc(placeName)
          .collection('story')
          .doc('content')
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data['text'] != null) {
          return data['text'];
        }
      }

      // 2. Eğer veritabanında yoksa OpenAI ile oluştur
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer ${Config.openAiApiKey}",
          HttpHeaders.contentTypeHeader: "application/json",
        },
        body: jsonEncode({
          "model": _model,
          "messages": [
            {"role": "system", "content": "Sen bir tarih ve coğrafya uzmanısın."},
            {
              "role": "user",
              "content": "$placeName hakkında kısa ve etkileyici bir şekilde yaklaşık 200 kelime ile hikayesini anlat."
            }
          ],
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final story = jsonResponse["choices"]?.first["message"]["content"]?.trim();

        if (story != null) {
          // 3. Oluşturulan hikayeyi Firestore’a kaydet
          await _firestore
              .collection('places')
              .doc(placeName)
              .collection('story')
              .doc('content')
              .set({
            'text': story,
            'createdAt': FieldValue.serverTimestamp(),
          });

          return story;
        } else {
          return "Hikaye bulunamadı.";
        }
      } else if (response.statusCode == 429) {
        return "API kullanım limiti aşıldı. Lütfen daha sonra tekrar deneyin.";
      } else {
        return "API hatası: ${response.statusCode} - ${response.reasonPhrase}";
      }
    } catch (e) {
      return "Hikaye getirilemedi: $e";
    }
  }
}
