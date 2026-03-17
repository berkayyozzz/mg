import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizations {
  static final Map<String, Map<String, String>> _localizedValues = {
    'tr': {
      // AppBar titles
      'app_name': 'MG Asistanı',
      'medications': 'İlaçlarım',
      'symptom_log': 'Semptom Günlüğü',
      'ai_support': 'AI Destek',
      'emergency': 'ACİL DURUM',
      'add_medication': 'Yeni İlaç Ekle',
      'new_symptom': 'Yeni Semptom Kaydı',
      'energy_entry': 'Enerji Seviyesi Kaydı',

      // Navigation
      'nav_home': 'Ana Sayfa',
      'nav_medications': 'İlaçlar',
      'nav_log': 'Günlük',
      'nav_ai': 'AI Destek',

      // Home screen
      'greeting': 'Merhaba,',
      'how_are_you': 'Bugün nasılsın?',
      'ai_advisor': 'MG Akıllı Destek',
      'daily_analysis': 'Günün Analizi',
      'analyze_button': 'Giriş Yap ve Analiz Et',
      'energy_status': 'Enerji Durumu',
      'morning': 'Sabah',
      'noon': 'Öğle',
      'evening': 'Akşam',
      'enter_status': 'Şu Anki Durumu Gir',
      'daily_tip': 'Günün Tavsiyesi',
      'weekly_summary': 'Haftalık Özet',
      'energy': 'Enerji',
      'symptom': 'Semptom',
      'no_data_chart': 'Henüz yeterli veri yok.\nEnerji ve semptom kayıtları girdikçe\ngrafik burada görünecek.',
      'emergency_info': 'Acil Durum Bilgileri',
      'emergency_desc': 'Kriz anında yapılması gerekenler ve riskli ilaçlar.',
      'change_theme': 'Tema Değiştir',
      'change_language': 'Dil Değiştir',

      // Medications
      'no_medication': 'Henüz ilaç eklenmemiş.',
      'medication_name': 'İlaç Adı',
      'dosage': 'Dozaj (örn. 60 mg, 1 tablet)',
      'name_required': 'İlaç adı boş olamaz',
      'dosage_required': 'Dozaj boş olamaz',
      'reminder_times': 'Hatırlatıcı Zamanları',
      'no_reminder': 'Hiç hatırlatıcı zamanı eklenmedi. Alarm saatleri için artı butonuna basın.',
      'add_time': 'Zaman Ekle',
      'save': 'Kaydet',
      'add_min_time': 'Lütfen en az bir hatırlatıcı zamanı ekleyin.',

      // Symptom log
      'no_records': 'Henüz kayıt bulunmuyor.',
      'add_record': 'Yeni Kayıt Ekle',
      'record_deleted': 'Kayıt silindi.',
      'record_saved': 'Semptom günlüğünüz başarıyla kaydedildi.',
      'symptom_instruction': 'Lütfen aşağıdaki semptomların şu anki şiddetini 0 ile 3 arasında değerlendirin.',
      'speech': 'Konuşma (Bozukluk / Yorulma)',
      'swallowing': 'Yutma (Zorlanma / Boğulma Hissi)',
      'breathing': 'Nefes Alma (Nefes Darlığı)',
      'eyelid': 'Göz Kapağı (Düşüklük / Çift Görme)',
      'grooming': 'Günlük Aktiviteler (Giyinme / Diş Fırçalama vb.)',
      'notes_label': 'Notlar (isteğe bağlı)',
      'notes_hint': 'Bugün nasıl hissettiğinizi, fark ettiğiniz değişiklikleri yazın...',
      'save_log': 'Günlüğü Kaydet',
      'normal': 'Normal (0)',
      'severe': 'Şiddetli (3)',
      'total_score': 'Toplam Puan',
      'speech_short': 'Konuşma',
      'swallowing_short': 'Yutma',
      'breathing_short': 'Nefes Alma',
      'eyelid_short': 'Göz Kapağı',
      'grooming_short': 'Günlük Aktiviteler',

      // AI Chat
      'ai_loading': 'Yapay zeka analizi yükleniyor...',
      'ai_error': 'Öneri yüklenirken bir hata oluştu.',
      'tips_loading': 'Tavsiyeler yükleniyor...',
      'type_message': 'Mesajınızı yazın...',

      'energy_saved': 'Enerji seviyeniz başarıyla kaydedildi.',
      'select_period': 'Hangi vakit için giriş yapıyorsunuz?',
      'very_tired': 'Çok Bitkin',
      'very_energetic': 'Çok Enerjik',
      'energy_score': 'Enerji Skoru',
      'sleep_quality_q': 'Dünkü uyku kaliteniz nasıldı?',
      'sleep_score': 'Uyku Skoru',
      'poor': 'Kötü',
      'great': 'Harika',

      // Emergency
      'crisis_title': 'MG Kriz Belirtileri',
      'risky_drugs': 'Sakıncalı İlaç Grupları',
      'risky_drugs_desc': 'MG hastaları için riskli olabilecek ilaçlar:',
    },
    'en': {
      // AppBar titles
      'app_name': 'MG Assistant',
      'medications': 'My Medications',
      'symptom_log': 'Symptom Log',
      'ai_support': 'AI Support',
      'emergency': 'EMERGENCY',
      'add_medication': 'Add New Medication',
      'new_symptom': 'New Symptom Record',
      'energy_entry': 'Energy Level Record',

      // Navigation
      'nav_home': 'Home',
      'nav_medications': 'Medications',
      'nav_log': 'Log',
      'nav_ai': 'AI Support',

      // Home screen
      'greeting': 'Hello,',
      'how_are_you': 'How are you today?',
      'ai_advisor': 'MG Smart Support',
      'daily_analysis': 'Daily Analysis',
      'analyze_button': 'Enter & Analyze',
      'energy_status': 'Energy Status',
      'morning': 'Morning',
      'noon': 'Noon',
      'evening': 'Evening',
      'enter_status': 'Enter Current Status',
      'daily_tip': 'Daily Tip',
      'weekly_summary': 'Weekly Summary',
      'energy': 'Energy',
      'symptom': 'Symptom',
      'no_data_chart': 'Not enough data yet.\nChart will appear as you\nadd energy and symptom records.',
      'emergency_info': 'Emergency Info',
      'emergency_desc': 'What to do in a crisis and risky medications.',
      'change_theme': 'Change Theme',
      'change_language': 'Change Language',

      // Medications
      'no_medication': 'No medications added yet.',
      'medication_name': 'Medication Name',
      'dosage': 'Dosage (e.g. 60 mg, 1 tablet)',
      'name_required': 'Medication name is required',
      'dosage_required': 'Dosage is required',
      'reminder_times': 'Reminder Times',
      'no_reminder': 'No reminder times added. Tap the plus button to add alarm times.',
      'add_time': 'Add Time',
      'save': 'Save',
      'add_min_time': 'Please add at least one reminder time.',

      // Symptom log
      'no_records': 'No records found.',
      'add_record': 'Add New Record',
      'record_deleted': 'Record deleted.',
      'record_saved': 'Symptom log saved successfully.',
      'symptom_instruction': 'Please rate the severity of the following symptoms from 0 to 3.',
      'speech': 'Speech (Difficulty / Fatigue)',
      'swallowing': 'Swallowing (Difficulty / Choking)',
      'breathing': 'Breathing (Shortness of Breath)',
      'eyelid': 'Eyelid (Drooping / Double Vision)',
      'grooming': 'Daily Activities (Dressing / Brushing etc.)',
      'notes_label': 'Notes (optional)',
      'notes_hint': 'Write how you feel today, any changes you noticed...',
      'save_log': 'Save Log',
      'normal': 'Normal (0)',
      'severe': 'Severe (3)',
      'total_score': 'Total Score',
      'speech_short': 'Speech',
      'swallowing_short': 'Swallowing',
      'breathing_short': 'Breathing',
      'eyelid_short': 'Eyelid',
      'grooming_short': 'Daily Activities',

      // AI Chat
      'ai_loading': 'AI analysis loading...',
      'ai_error': 'An error occurred loading recommendations.',
      'tips_loading': 'Loading tips...',
      'type_message': 'Type your message...',

      'energy_saved': 'Energy level saved successfully.',
      'select_period': 'Which period are you logging for?',
      'very_tired': 'Very Tired',
      'very_energetic': 'Very Energetic',
      'energy_score': 'Energy Score',
      'sleep_quality_q': 'How was your sleep quality yesterday?',
      'sleep_score': 'Sleep Score',
      'poor': 'Poor',
      'great': 'Great',

      // Emergency
      'crisis_title': 'MG Crisis Symptoms',
      'risky_drugs': 'Risky Drug Groups',
      'risky_drugs_desc': 'Medications that may be risky for MG patients:',
    },
  };

  static String _currentLocale = 'tr';

  static String get currentLocale => _currentLocale;
  static bool get isEnglish => _currentLocale == 'en';

  static String t(String key) {
    return _localizedValues[_currentLocale]?[key] ?? _localizedValues['tr']?[key] ?? key;
  }

  static Future<void> loadLocale() async {
    _currentLocale = 'tr';
  }

  static Future<void> setLocale(String locale) async {
    _currentLocale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', locale);
  }
}

class LanguageProvider with ChangeNotifier {
  String _locale = 'tr';

  String get locale => _locale;
  bool get isEnglish => _locale == 'en';

  LanguageProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    _locale = 'tr';
    AppLocalizations._currentLocale = _locale;
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    _locale = _locale == 'tr' ? 'en' : 'tr';
    await AppLocalizations.setLocale(_locale);
    notifyListeners();
  }
}
