import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'energy_provider.dart';
import 'theme.dart';
import 'app_localizations.dart';

class EnergyEntryScreen extends StatefulWidget {
  const EnergyEntryScreen({super.key});

  @override
  State<EnergyEntryScreen> createState() => _EnergyEntryScreenState();
}

class _EnergyEntryScreenState extends State<EnergyEntryScreen> {
  double _currentScore = 5;
  double _sleepQuality = 5;
  String _selectedPeriod = 'Sabah';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.t('energy_entry'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22, letterSpacing: 0.5))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLocalizations.t('select_period'),
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'Sabah', label: Text(AppLocalizations.t('morning'))),
                  ButtonSegment(value: 'Öğle', label: Text(AppLocalizations.t('noon'))),
                  ButtonSegment(value: 'Akşam', label: Text(AppLocalizations.t('evening'))),
                ],
                selected: {_selectedPeriod},
                onSelectionChanged: (set) {
                  setState(() => _selectedPeriod = set.first);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return AppTheme.primaryTeal.withOpacity(0.2);
                      }
                      return Colors.transparent;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      Text(
                        '${AppLocalizations.t('energy_score')}: ${_currentScore.toInt()}',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Slider(
                        value: _currentScore,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        activeColor: AppTheme.primaryTeal,
                        inactiveColor: AppTheme.primaryTeal.withOpacity(0.2),
                        label: _currentScore.toInt().toString(),
                        onChanged: (val) => setState(() => _currentScore = val),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLocalizations.t('very_tired'), style: const TextStyle(color: AppTheme.textLight)),
                            Text(AppLocalizations.t('very_energetic'), style: const TextStyle(color: AppTheme.textLight)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_selectedPeriod == 'Sabah') ...[
                const SizedBox(height: 32),
                Text(
                  AppLocalizations.t('sleep_quality_q'),
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                    child: Column(
                      children: [
                        Text(
                          '${AppLocalizations.t('sleep_score')}: ${_sleepQuality.toInt()}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentCoral,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: _sleepQuality,
                          min: 1,
                          max: 10,
                          divisions: 9,
                          activeColor: AppTheme.accentCoral,
                          inactiveColor: AppTheme.accentCoral.withOpacity(0.2),
                          label: _sleepQuality.toInt().toString(),
                          onChanged: (val) => setState(() => _sleepQuality = val),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppLocalizations.t('poor'), style: const TextStyle(color: AppTheme.textLight)),
                              Text(AppLocalizations.t('great'), style: const TextStyle(color: AppTheme.textLight)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  final provider = context.read<EnergyProvider>();
                  final score = _currentScore.toInt();
                  final sleep = _sleepQuality.toInt();
                  
                  if (_selectedPeriod == 'Sabah') {
                    provider.updateLog(DateTime.now(), morning: score, sleep: sleep);
                  } else if (_selectedPeriod == 'Öğle') {
                    provider.updateLog(DateTime.now(), noon: score);
                  } else {
                    provider.updateLog(DateTime.now(), evening: score);
                  }
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.t('energy_saved')),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text(AppLocalizations.t('save').toUpperCase()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
