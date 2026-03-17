import 'energy_provider.dart';
import 'symptom_provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class AIAdvisorService {
  static const String _apiKey = APIConfig.geminiKey;
  static String _cachedResponse = '';
  static String _lastCacheDate = '';

  static Future<String> getDailyRecommendation(EnergyLog? today, SymptomADL? todaySymptom) async {
    if (today == null || today.morningScore == null) {
      return "Bugün henüz enerji veya semptom girişi yapmadınız. Akıllı analiz için durumunuzu 'Günlük' veya 'Ana Sayfa' üzerinden güncelleyin.";
    }

    // Use caching so we don't spam the API on every UI rebuild
    final currentDateStr = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('ai_advice_$currentDateStr');
    
    // Simple logic to invalidate cache if scores change significantly could be added here.
    // For now, if we have a cache for today, return it.
    if (cached != null && cached.isNotEmpty && _lastCacheDate == currentDateStr) {
       return cached; // Return from memory
    } else if (cached != null && cached.isNotEmpty) {
       _cachedResponse = cached;
       _lastCacheDate = currentDateStr;
       return cached;
    }

    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
      final energyStr = "Sabah Enerjisi: ${today.morningScore ?? '-'}, Öğle: ${today.noonScore ?? '-'}, Akşam: ${today.eveningScore ?? '-'} (10 üzerinden)";
      
      String symptomStr = "Semptom girişi yapılmadı.";
      if (todaySymptom != null) {
        symptomStr = "Konuşma: ${todaySymptom.speech}, Yutma: ${todaySymptom.swallowing}, Nefes Darlığı: ${todaySymptom.breathing}, Göz Kapağı Düşüklüğü: ${todaySymptom.eyelid}, Günlük Aktivitelerde Zorlanma: ${todaySymptom.grooming} (0 Normal, 3 Şiddetli)";
      }

      final prompt = """
Sen Myastenia Gravis (MG) hastalarına günlük motive edici ve koruyucu tavsiyeler veren empatik bir yapay zeka asistanısın.
Kullanıcının bugünkü verileri:
- Enerji: $energyStr
- Semptomlar (MG ADL Skoru): $symptomStr

Bu verilere dayanarak, hastaya bugün için 2-3 cümlelik çok kısa, şefkatli, motive edici ve pratik bir günlük tavsiye ver.
Örneğin: enerjisi düşükse dinlenmeyi hatırlat, yutma sorunu varsa yumuşak gıdalar öner, nefes darlığı varsa acil durum için uyarıda bulun (ama korkutmadan).
Eğer her şey yolundaysa moral verici pozitif bir mesaj ilet.
Asla tıbbi teşhis koyma, sadece günlük yaşam tavsiyeleri ver.
Markdown KULLANMA. Sadece düz metin olarak kısa bir paragraf döndür.
""";

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      final result = response.text?.trim() ?? "Verilerinizi inceledim. Lütfen bugün kendinizi çok yormamaya özen gösterin ve ilaçlarınızı zamanında alın.";
      
      // Save to cache
      await prefs.setString('ai_advice_$currentDateStr', result);
      _cachedResponse = result;
      _lastCacheDate = currentDateStr;

      return result;

    } catch (e) {
      if (today.morningScore! <= 4 || (todaySymptom != null && todaySymptom.totalScore > 5)) {
        return "Görünüşe göre bugün biraz zorlanıyorsunuz. Lütfen bolca dinlenin ve gerekirse doktorunuzla iletişime geçin.";
      }
      return "Bugün kendi temponuzda kalmaya özen gösterin. MG'nin değişken doğasını unutmayın ve belirtileri takip edin.";
    }
  }
}

