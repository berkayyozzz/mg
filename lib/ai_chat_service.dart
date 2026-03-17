import 'package:google_generative_ai/google_generative_ai.dart';
import 'api_config.dart';

class AIChatService {
  static const String _apiKey = geminiApiKey; 
  
  static Future<String> getResponse(String prompt) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY') {
      return "Lütfen geçerli bir Gemini API anahtarı sağlayın. Bu bot şu an demo modundadır.\n\nNOT: Bu bilgiler genel bilgilendirme amaçlıdır, doktorunuza danışın.";
    }

    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
      final content = [Content.text("Sen bir Myastenia Gravis (MG) destek asistanısın. Kullanıcılara nazikçe yardımcı ol ama asla tıbbi teşhis koyma. Her zaman doktorlarına danışmalarını hatırlat. Soru: $prompt")];
      final response = await model.generateContent(content);
      
      return "${response.text}\n\n⚠️ NOT: Bu bilgiler genel bilgilendirme amaçlıdır, kesinlikle doktor tavsiyesi yerine geçmez.";
    } catch (e) {
      return "Bir hata oluştu: $e\n\nLütfen daha sonra tekrar deneyin.";
    }
  }
}
