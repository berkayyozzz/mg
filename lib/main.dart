import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'energy_provider.dart';
import 'energy_entry_screen.dart';
import 'ai_advisor_service.dart';
import 'medication_provider.dart';
import 'symptom_provider.dart';
import 'ai_chat_service.dart';
import 'notification_service.dart';
import 'add_medication_screen.dart';
import 'symptom_entry_screen.dart';
import 'weekly_chart.dart';
import 'app_localizations.dart';
import 'api_config.dart';
import 'chat_provider.dart';
import 'language_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EnergyProvider()),
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
        ChangeNotifierProvider(create: (_) => SymptomProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MGSupportApp(),
    ),
  );
}

class MGSupportApp extends StatelessWidget {
  const MGSupportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return MaterialApp(
          title: AppLocalizations.t('app_name'),
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          locale: Locale(languageProvider.locale),
          home: languageProvider.isLanguageSet 
              ? const MainNavigationScreen() 
              : const LanguageSelectionScreen(),
        );
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = [
    HomeScreen(),
    MedicationScreen(),
    SymptomLogScreen(),
    AIChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: AppLocalizations.t('nav_home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.medication_outlined),
            selectedIcon: const Icon(Icons.medication),
            label: AppLocalizations.t('nav_medications'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: AppLocalizations.t('nav_log'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.smart_toy_outlined),
            selectedIcon: const Icon(Icons.smart_toy),
            label: AppLocalizations.t('nav_ai'),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.t('app_name'),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: () => context.read<LanguageProvider>().toggleLanguage(),
            tooltip: AppLocalizations.t('change_language'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.t('greeting'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textLight,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.t('how_are_you'),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 24),
              _buildAIAdvisorCard(context),
              const SizedBox(height: 16),
              _buildEnergyScoreCard(context),
              const SizedBox(height: 16),
              _buildDailyTipCard(context),
              const SizedBox(height: 16),
              const WeeklyChartCard(),
              const SizedBox(height: 16),
              _buildCriticalInfoCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIAdvisorCard(BuildContext context) {
    return Consumer2<EnergyProvider, SymptomProvider>(
      builder: (context, energyProvider, symptomProvider, child) {
        final todayEnergy = energyProvider.getLogForDate(DateTime.now());
        final todaySymptom = symptomProvider.history.isNotEmpty && 
                             symptomProvider.history.first.date.day == DateTime.now().day 
                             ? symptomProvider.history.first : null;

        return FutureBuilder<String>(
          future: AIAdvisorService.getDailyRecommendation(todayEnergy, todaySymptom),
          builder: (context, snapshot) {
            String recommendation = AppLocalizations.t('ai_loading');
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              recommendation = snapshot.data!;
            } else if (snapshot.hasError) {
              recommendation = AppLocalizations.t('ai_error');
            }

            return Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.auto_awesome, color: AppTheme.primaryTeal, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            AppLocalizations.t('ai_advisor'),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.t('daily_analysis'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recommendation,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                    if (snapshot.connectionState != ConnectionState.done)
                      const Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (todayEnergy.morningScore == null) ...[
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EnergyEntryScreen()),
                          );
                        },
                        icon: const Icon(Icons.analytics_outlined),
                        label: Text(AppLocalizations.t('analyze_button')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEnergyScoreCard(BuildContext context) {
    return Consumer<EnergyProvider>(
      builder: (context, energyProvider, child) {
        final todayLog = energyProvider.getLogForDate(DateTime.now());
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.battery_charging_full, color: AppTheme.accentCoral),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.t('energy_status'), style: Theme.of(context).textTheme.headlineMedium),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _EnergyCircle(label: AppLocalizations.t('morning'), score: todayLog.morningScore?.toString() ?? '-'),
                    _EnergyCircle(label: AppLocalizations.t('noon'), score: todayLog.noonScore?.toString() ?? '-'),
                    _EnergyCircle(label: AppLocalizations.t('evening'), score: todayLog.eveningScore?.toString() ?? '-'),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCoral),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EnergyEntryScreen()),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: Text(AppLocalizations.t('enter_status')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyTipCard(BuildContext context) {
    return Consumer2<EnergyProvider, SymptomProvider>(
      builder: (context, energyProvider, symptomProvider, child) {
        final todayEnergy = energyProvider.getLogForDate(DateTime.now());
        final todaySymptom = symptomProvider.history.isNotEmpty &&
                             symptomProvider.history.first.date.day == DateTime.now().day
                             ? symptomProvider.history.first : null;

        return FutureBuilder<String>(
          future: _getDailyTip(todayEnergy, todaySymptom),
          builder: (context, snapshot) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final tipText = snapshot.data ?? AppLocalizations.t('tips_loading');

            return Card(
              color: isDark ? null : const Color(0xFFFFFDE7), // warm yellow in light mode
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isDark ? Colors.amber.withOpacity(0.3) : Colors.amber.shade200, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('💡', style: TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppLocalizations.t('daily_tip'),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: isDark ? Colors.amber.shade300 : Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(child: CircularProgressIndicator())
                    else
                        Text(
                          tipText,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: isDark ? Colors.white.withOpacity(0.9) : Colors.brown.shade800,
                          ),
                        ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<String> _getDailyTip(EnergyLog? energy, SymptomADL? symptom) async {
    try {
      final dateStr = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
      final scoresHash = 'e${energy?.morningScore ?? 0}_${energy?.noonScore ?? 0}_${energy?.eveningScore ?? 0}_s${symptom?.totalScore ?? 0}';
      final cacheKey = 'daily_tip_${dateStr}_$scoresHash';
      
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(cacheKey);
      if (cached != null && cached.isNotEmpty) return cached;

      String context = '';
      if (energy != null && energy.morningScore != null) {
        context += 'Enerji: Sabah ${energy.morningScore}/10, Öğle ${energy.noonScore ?? "-"}/10, Akşam ${energy.eveningScore ?? "-"}/10. ';
      }
      if (symptom != null) {
        context += 'Semptomlar: Konuşma ${symptom.speech}/3, Yutma ${symptom.swallowing}/3, Nefes ${symptom.breathing}/3, Göz ${symptom.eyelid}/3. ';
      }
      if (context.isEmpty) {
        context = 'Bugün henüz veri girilmedi.';
      }

      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: geminiApiKey);
      final isEnglish = AppLocalizations.isEnglish;
      final languagePrompt = isEnglish 
          ? "Please write in English." 
          : "Lütfen Türkçe yaz.";

      final prompt = '''
Sen Myastenia Gravis hastalarına pratik günlük yaşam tavsiyeleri veren bir asistansın.
Kullanıcının bugünkü verisi: $context

Lütfen bugün için kısa ve şefkatli bir tavsiye paragrafı yaz (2-3 cümle), ardından başında ✔ işareti olan 2-3 madde halinde yapılacaklar listesi ver.
$languagePrompt

Örnek format:
[tavsiye metni]

✔ Birinci öneri
✔ İkinci öneri

Markdown KULLANMA. Sadece düz metin yaz. Kısa tut.
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final defaultTip = isEnglish 
          ? 'Listen to yourself today and take your medications on time.\n\n✔ Take rest breaks\n✔ Drink plenty of water'
          : 'Bugün kendinizi dinleyin ve ilaçlarınızı zamanında alın.\n\n✔ Dinlenme araları verin\n✔ Bol su için';
      
      final result = response.text?.trim() ?? defaultTip;

      await prefs.setString(cacheKey, result);
      return result;
    } catch (e) {
      final errorTip = AppLocalizations.isEnglish
          ? 'Avoid strenuous activities that can increase your MG symptoms.\n\n✔ Take rest breaks\n✔ Drink plenty of water\n✔ Take your medications on time'
          : 'MG semptomlarınızı artırabilecek yorucu aktivitelerden kaçının.\n\n✔ Dinlenme araları verin\n✔ Bol su için\n✔ İlaçlarınızı zamanında alın';
      return errorTip;
    }
  }

  Widget _buildCriticalInfoCard(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.red.shade200, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
        ),
        title: Text(AppLocalizations.t('emergency_info'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 18)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(AppLocalizations.t('emergency_desc')),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EmergencyScreen()),
          );
        },
      ),
    );
  }
}

class _EnergyCircle extends StatelessWidget {
  final String label;
  final String score;
  const _EnergyCircle({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: score == '-' ? AppTheme.backgroundColor : AppTheme.primaryTeal.withOpacity(0.1),
            border: Border.all(
              color: score == '-' ? Colors.grey.shade300 : AppTheme.primaryTeal, 
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            score,
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold, 
              color: score == '-' ? Colors.grey.shade500 : AppTheme.primaryTeal,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark)),
      ],
    );
  }
}

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.t('emergency'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22, letterSpacing: 0.5))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCrisisCard(),
          const SizedBox(height: 24),
          Text(AppLocalizations.t('risky_drugs'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
          Text(AppLocalizations.t('risky_drugs_desc'), style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          _buildDrugWarningItem(
            AppLocalizations.isEnglish ? 'Some Antibiotics' : 'Bazı Antibiyotikler', 
            AppLocalizations.isEnglish ? 'Aminoglycosides, Quinolones (Cipro etc.), Macrolides.' : 'Aminoglikozidler, Kinolonlar (Cipro vb.), Makrolidler.'
          ),
          _buildDrugWarningItem(
            AppLocalizations.isEnglish ? 'Magnesium' : 'Magnezyum', 
            AppLocalizations.isEnglish ? 'Can increase existing weakness.' : 'Mevcut zayıflığı artırabilir.'
          ),
          _buildDrugWarningItem(
            AppLocalizations.isEnglish ? 'Some Heart Medications' : 'Bazı Kalp İlaçları', 
            AppLocalizations.isEnglish ? 'Beta-blockers, Calcium channel blockers.' : 'Beta-blokerler, Kalsiyum kanal blokerleri.'
          ),
          _buildDrugWarningItem(
            AppLocalizations.isEnglish ? 'Muscle Relaxants' : 'Kas Gevşeticiler', 
            AppLocalizations.isEnglish ? 'Especially those used before surgery.' : 'Özellikle ameliyat öncesi kullanılanlar.'
          ),
        ],
      ),
    );
  }

  Widget _buildCrisisCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medical_services, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Text(AppLocalizations.t('med_alert_title'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.t('med_alert_desc'),
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildDrugWarningItem(String title, String details) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(details, style: const TextStyle(fontSize: 16)),
        leading: const Icon(Icons.cancel, color: Colors.red),
      ),
    );
  }
}

class MedicationScreen extends StatelessWidget {
  const MedicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final medProvider = context.watch<MedicationProvider>();
    
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.t('medications'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22, letterSpacing: 0.5))),
      body: medProvider.medications.isEmpty
          ? Center(child: Text(AppLocalizations.t('no_medication')))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: medProvider.medications.length,
              itemBuilder: (context, index) {
                final med = medProvider.medications[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(med.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => medProvider.removeMedication(med.id),
                            ),
                          ],
                        ),
                        Text('${AppLocalizations.t('dosage_label')}: ${med.dosage}', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 12),
                        Text(AppLocalizations.t('todays_doses'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        Wrap(
                          spacing: 8,
                          children: med.times.map((time) {
                            final isTaken = med.isTaken(DateTime.now(), time);
                            return FilterChip(
                              label: Text(time.format(context), style: TextStyle(
                                fontSize: 16,
                                color: isTaken ? Colors.white : AppTheme.textDark,
                                decoration: isTaken ? TextDecoration.lineThrough : null,
                              )),
                              selected: isTaken,
                              selectedColor: AppTheme.primaryTeal,
                              checkmarkColor: Colors.white,
                              backgroundColor: Colors.blue.shade50,
                              onSelected: (bool selected) {
                                medProvider.toggleMedicationTaken(med.id, DateTime.now(), time);
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMedicationScreen()),
          );
        },
        label: Text(AppLocalizations.t('add_medication')),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class SymptomLogScreen extends StatelessWidget {
  const SymptomLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final symptomProvider = context.watch<SymptomProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.t('symptom_log'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22, letterSpacing: 0.5))),
      body: symptomProvider.history.isEmpty
          ? Center(child: Text(AppLocalizations.t('no_records')))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: symptomProvider.history.length,
              itemBuilder: (context, index) {
                final log = symptomProvider.history[index];
                return Card(
                  child: ExpansionTile(
                    title: Text('${AppLocalizations.t('score')}: ${log.totalScore} / 15', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${log.date.day}/${log.date.month}/${log.date.year} ${log.date.hour.toString().padLeft(2, '0')}:${log.date.minute.toString().padLeft(2, '0')}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                           onPressed: () {
                             context.read<SymptomProvider>().removeLog(log.id);
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content: Text(AppLocalizations.t('record_deleted'))),
                             );
                           },
                        ),
                        const Icon(Icons.expand_more),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                           children: [
                             _buildSymptomRow(AppLocalizations.t('speech_short'), log.speech),
                             _buildSymptomRow(AppLocalizations.t('swallowing_short'), log.swallowing),
                             _buildSymptomRow(AppLocalizations.t('breathing_short'), log.breathing),
                             _buildSymptomRow(AppLocalizations.t('eyelid_short'), log.eyelid),
                             _buildSymptomRow(AppLocalizations.t('grooming_short'), log.grooming),
                            if (log.notes.isNotEmpty) ...[
                              const Divider(),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '📝 ${log.notes}',
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SymptomEntryScreen()),
          );
        },
        label: Text(AppLocalizations.t('add_record')),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSymptomRow(String name, int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 16)),
          Text(
            score.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: score > 1 ? Colors.red : (score == 1 ? Colors.orange : AppTheme.primaryTeal),
            ),
          ),
        ],
      ),
    );
  }
}

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final chatProvider = context.read<ChatProvider>();

    setState(() {
      chatProvider.addMessage('user', text);
      _isLoading = true;
      _controller.clear();
    });

    final response = await AIChatService.getResponse(text);

    setState(() {
      chatProvider.addMessage('bot', response);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final messages = chatProvider.messages;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.t('ai_support'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22, letterSpacing: 0.5)),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.t('sources')),
                  content: Text(AppLocalizations.t('sources_desc')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
          if (messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(AppLocalizations.isEnglish ? 'Clear History' : 'Geçmişi Temizle'),
                    content: Text(AppLocalizations.isEnglish 
                        ? 'Do you want to clear the chat history?' 
                        : 'Sohbet geçmişini temizlemek istiyor musunuz?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppLocalizations.isEnglish ? 'Cancel' : 'İptal'),
                      ),
                      TextButton(
                        onPressed: () {
                          chatProvider.clearHistory();
                          Navigator.pop(context);
                        },
                        child: Text(AppLocalizations.isEnglish ? 'Clear' : 'Temizle', style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.amber.shade100,
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.t('ai_disclaimer'),
                    style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.smart_toy_outlined,
                            size: 64,
                            color: AppTheme.primaryTeal.withOpacity(0.5),
                          ),
                          const SizedBox(height: 24),
                           Text(
                             AppLocalizations.isEnglish ? 'Welcome to Your AI Assistant' : 'Yapay Zeka Asistanınıza Hoş Geldiniz',
                             textAlign: TextAlign.center,
                             style: const TextStyle(
                               fontSize: 22,
                               fontWeight: FontWeight.bold,
                               color: AppTheme.primaryTeal,
                             ),
                           ),
                           const SizedBox(height: 16),
                           Text(
                             AppLocalizations.isEnglish 
                               ? 'You can ask questions about Myasthenia Gravis, request tips for daily life, or simply chat to share your experiences.'
                               : 'Myastenia Gravis ile ilgili sorularınızı sorabilir, günlük yaşantınız için ipuçları isteyebilir veya sadece dertleşmek için kullanabilirsiniz.',
                             textAlign: TextAlign.center,
                             style: TextStyle(
                               fontSize: 16,
                               color: Colors.grey.shade600,
                               height: 1.5,
                             ),
                           ),
                           const SizedBox(height: 32),
                           Align(
                             alignment: Alignment.centerLeft,
                             child: Text(
                               AppLocalizations.isEnglish ? 'Example Questions:' : 'Örnek Sorular:',
                               style: const TextStyle(
                                 fontWeight: FontWeight.bold,
                                 color: AppTheme.textDark,
                               ),
                             ),
                           ),
                           const SizedBox(height: 12),
                           _buildSuggestionChip(AppLocalizations.isEnglish ? 'How can I maintain my energy during the day?' : 'Gün içinde enerjimi nasıl koruyabilirim?'),
                           _buildSuggestionChip(AppLocalizations.isEnglish ? 'What should I eat when having difficulty swallowing?' : 'Yutkunma zorluğu çekerken ne yemeliyim?'),
                           _buildSuggestionChip(AppLocalizations.isEnglish ? 'I feel very tired today.' : 'Kendimi bugün çok yorgun hissediyorum.'),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isUser = msg.role == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isUser ? AppTheme.primaryTeal : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isUser ? 16 : 4),
                              bottomRight: Radius.circular(isUser ? 4 : 16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(
                              color: isUser ? Colors.white : AppTheme.textDark, 
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_isLoading) const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.t('type_message'),
                        hintStyle: const TextStyle(color: AppTheme.textLight),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryTeal,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          _controller.text = text;
          _sendMessage();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal.withOpacity(0.05),
            border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.chat_bubble_outline, size: 16, color: AppTheme.primaryTeal),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(color: AppTheme.primaryTeal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
