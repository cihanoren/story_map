import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:story_map/core/config.dart'; // API anahtarını buradan alıyoruz

class StoryService {
  static const String apiUrl = "https://api.openai.com/v1/chat/completions";

  static Future<String> fetchStory(String placeName) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer ${Config.openAiApiKey}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "gpt-4",
          "messages": [
            {"role": "system", "content": "Sen bir tarih uzmanısın."},
            {
              "role": "user",
              "content": "$placeName hakkında kısa bir hikaye anlat."
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse["choices"]?.first["message"]["content"] ??
            "Hikaye bulunamadı.";
      } else {
        throw Exception("API çağrısı başarısız oldu: ${response.statusCode}");
      }
    } catch (e) {
      return "Hikaye getirilemedi: $e";
    }
  }
}
