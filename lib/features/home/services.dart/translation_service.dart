import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:story_map/core/config.dart';
import 'package:story_map/features/home/services.dart/story_api_services.dart';

class TranslationService {
  static const String _apiUrl = "https://api.openai.com/v1/chat/completions";
  static const String _model = "gpt-3.5-turbo"; 
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Kısa dil kodunu modelin anlayacağı dil adına çevir
  static String getLanguageName(String code) {
    switch (code) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'İngilizce';
      case 'de':
        return 'Almanca';
      case 'fr':
        return 'Fransızca';
      case 'es':
        return 'İspanyolca';
      case 'ru':
        return 'Rusça';
      case 'ar':
        return 'Arapça';
      case 'it':
        return 'İtalyanca';
      default:
        return 'İngilizce';
    }
  }

  /// Hikayeyi hedef dile çevir
  static Future<String> translateStory({
    required String placeId,
    required String targetLocale,
  }) async {
    try {
      final placeDoc = _firestore.collection("places").doc(placeId);

      // 1️⃣ Daha önce çeviri var mı?
      final translationDoc =
          await placeDoc.collection("story").doc(targetLocale).get();

      if (translationDoc.exists && translationDoc.data()?["text"] != null) {
        return translationDoc.data()!["text"];
      }

      // 2️⃣ Orijinal hikayeyi getir (yoksa oluştur)
      final originalDoc =
          await placeDoc.collection("story").doc("content").get();

      String originalStory;
      if (!originalDoc.exists || originalDoc.data()?["text"] == null) {
        // Yoksa önce hikaye oluştur
        originalStory = await StoryService.fetchStory(placeId);
      } else {
        originalStory = originalDoc.data()!["text"] as String;
      }

      // 3️⃣ Çeviri yap
      final languageName = getLanguageName(targetLocale);

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer ${Config.openAiApiKey}",
          HttpHeaders.contentTypeHeader: "application/json",
        },
        body: jsonEncode({
          "model": _model,
          "messages": [
            {
              "role": "system",
              "content":
                  "Sen profesyonel bir çeviri uzmanısın. Kullanıcı için hikayeyi sadece $languageName diline çevir. "
                      "Ekstra açıklama, yorum veya başka dilde içerik ekleme."
            },
            {"role": "user", "content": originalStory}
          ],
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final translatedStory =
            jsonResponse["choices"]?.first["message"]["content"]?.trim();

        if (translatedStory != null) {
          // 4️⃣ Çeviriyi Firestore'a kaydet
          await placeDoc.collection("story").doc(targetLocale).set({
            "text": translatedStory,
            "createdAt": FieldValue.serverTimestamp(),
          });

          return translatedStory;
        }
      }

      return "Çeviri yapılamadı: ${response.statusCode} ${response.reasonPhrase}";
    } catch (e) {
      return "Çeviri sırasında hata oluştu: $e";
    }
  }
}
