import 'energy_provider.dart';
import 'symptom_provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';
import 'app_localizations.dart';

class AIAdvisorService {
  static const String _apiKey = geminiApiKey;

  static Future<String> getDailyRecommendation(EnergyLog? today, SymptomADL? todaySymptom) async {
    final isEn = AppLocalizations.isEnglish;
    
    if (today == null || today.morningScore == null) {
      return isEn 
        ? "You haven't entered energy or symptom data today yet. Update your status via 'Log' or 'Home' for smart analysis."
        : "Bugün henüz enerji veya semptom girişi yapmadınız. Akıllı analiz için durumunuzu 'Günlük' veya 'Ana Sayfa' üzerinden güncelleyin.";
    }

    // Veriye dayalı önbellek anahtarı oluştur (tarih + skorlar + dil)
    final dateStr = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
    final scoresHash = 'e${today.morningScore}_${today.noonScore}_${today.eveningScore}_s${todaySymptom?.totalScore ?? 0}';
    final langSuffix = isEn ? '_en' : '_tr';
    final cacheKey = 'ai_advice_${dateStr}_${scoresHash}$langSuffix';
    
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(cacheKey);
    
    if (cached != null && cached.isNotEmpty) {
       return cached;
    }

    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
      
      String energyStr;
      String symptomStr;
      String prompt;

      if (isEn) {
        energyStr = "Morning Energy: ${today.morningScore ?? '-'}, Noon: ${today.noonScore ?? '-'}, Evening: ${today.eveningScore ?? '-'} (out of 10)";
        symptomStr = todaySymptom != null 
          ? "Speech: ${todaySymptom.speech}, Swallowing: ${todaySymptom.swallowing}, Shortness of Breath: ${todaySymptom.breathing}, Eyelid Drooping: ${todaySymptom.eyelid}, Difficulty in Daily Activities: ${todaySymptom.grooming} (0 Normal, 3 Severe)"
          : "No symptom entry.";
        
        prompt = """
You are an empathetic AI assistant giving daily motivational and protective advice to Myasthenia Gravis (MG) patients.
User's data for today:
- Energy: $energyStr
- Symptoms (MG ADL Score): $symptomStr

Based on this data, give a very short (2-3 sentences), compassionate, motivational, and practical daily advice to the patient.
For example: if energy is low, remind them to rest; if there are swallowing issues, suggest soft foods; if there is shortness of breath, give a gentle warning for emergency.
If everything is well, deliver a positive morale-boosting message.
NEVER make a medical diagnosis, only give daily living advice.
Do NOT use Markdown. Return only a short paragraph as plain text.
Reply in English.
""";
      } else {
        energyStr = "Sabah Enerjisi: ${today.morningScore ?? '-'}, Öğle: ${today.noonScore ?? '-'}, Akşam: ${today.eveningScore ?? '-'} (10 üzerinden)";
        symptomStr = todaySymptom != null 
          ? "Konuşma: ${todaySymptom.speech}, Yutma: ${todaySymptom.swallowing}, Nefes Darlığı: ${todaySymptom.breathing}, Göz Kapağı Düşüklüğü: ${todaySymptom.eyelid}, Günlük Aktivitelerde Zorlanma: ${todaySymptom.grooming} (0 Normal, 3 Şiddetli)"
          : "Semptom girişi yapılmadı.";
        
        prompt = """
Sen Myastenia Gravis (MG) hastalarına günlük motive edici ve koruyucu tavsiyeler veren empatik bir yapay zeka asistanısın.
Kullanıcının bugünkü verileri:
- Enerji: $energyStr
- Semptomlar (MG ADL Skoru): $symptomStr

Bu verilere dayanarak, hastaya bugün için 2-3 cümlelik çok kısa, şefkatli, motive edici ve pratik bir günlük tavsiye ver.
Örneğin: enerjisi düşükse dinlenmeyi hatırlat, yutma sorunu varsa yumuşak gıdalar öner, nefes darlığı varsa acil durum için uyarıda bulun (ama korkutmadan).
Eğer her şey yolundaysa moral verici pozitif bir mesaj ilet.
Asla tıbbi teşhis koyma, sadece günlük yaşam tavsiyeleri ver.
Markdown KULLANMA. Sadece düz metin olarak kısa bir paragraf döndür.
Türkçe cevap ver.
""";
      }

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      final defaultResult = isEn 
        ? "I've reviewed your data. Please take care not to overexert yourself today and take your medications on time."
        : "Verilerinizi inceledim. Lütfen bugün kendinizi çok yormamaya özen gösterin ve ilaçlarınızı zamanında alın.";
      
      final result = response.text?.trim() ?? defaultResult;
      
      await prefs.setString(cacheKey, result);
      return result;

    } catch (e) {
      if (today.morningScore! <= 4 || (todaySymptom != null && todaySymptom.totalScore > 5)) {
        return isEn 
          ? "It seems like you're struggling a bit today. Please rest plenty and contact your doctor if necessary."
          : "Görünüşe göre bugün biraz zorlanıyorsunuz. Lütfen bolca dinlenin ve gerekirse doktorunuzla iletişime geçin.";
      }
      return isEn 
        ? "Try to stay at your own pace today. Remember the variable nature of MG and track your symptoms."
        : "Bugün kendi temponuzda kalmaya özen gösterin. MG'nin değişken doğasını unutmayın ve belirtileri takip edin.";
    }
  }
}

