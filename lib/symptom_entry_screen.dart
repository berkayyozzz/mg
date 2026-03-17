import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'symptom_provider.dart';
import 'theme.dart';
import 'app_localizations.dart';

class SymptomEntryScreen extends StatefulWidget {
  const SymptomEntryScreen({super.key});

  @override
  State<SymptomEntryScreen> createState() => _SymptomEntryScreenState();
}

class _SymptomEntryScreenState extends State<SymptomEntryScreen> {
  int _speech = 0;
  int _swallowing = 0;
  int _breathing = 0;
  int _eyelid = 0;
  int _grooming = 0;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _saveLog() {
    final log = SymptomADL(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      speech: _speech,
      swallowing: _swallowing,
      breathing: _breathing,
      eyelid: _eyelid,
      grooming: _grooming,
      notes: _notesController.text.trim(),
    );
    context.read<SymptomProvider>().addLog(log);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.t('record_saved'))),
    );
    Navigator.pop(context);
  }

  Widget _buildSliderRow(String label, int value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: $value',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 3,
          divisions: 3,
          label: value.toString(),
          activeColor: AppTheme.primaryTeal,
          inactiveColor: Colors.blue.shade50,
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.t('normal'), style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(AppLocalizations.t('severe'), style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.t('new_symptom'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22, letterSpacing: 0.5))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.t('symptom_instruction'),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            _buildSliderRow(AppLocalizations.t('speech'), _speech, (val) => setState(() => _speech = val.toInt())),
            _buildSliderRow(AppLocalizations.t('swallowing'), _swallowing, (val) => setState(() => _swallowing = val.toInt())),
            _buildSliderRow(AppLocalizations.t('breathing'), _breathing, (val) => setState(() => _breathing = val.toInt())),
            _buildSliderRow(AppLocalizations.t('eyelid'), _eyelid, (val) => setState(() => _eyelid = val.toInt())),
            _buildSliderRow(AppLocalizations.t('grooming'), _grooming, (val) => setState(() => _grooming = val.toInt())),
            
            const SizedBox(height: 24),
            Text(
              AppLocalizations.t('notes_label'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: AppLocalizations.t('notes_hint'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveLog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                minimumSize: const Size(double.infinity, 56),
              ),
              child: Text(AppLocalizations.t('save_log')),
            ),
          ],
        ),
      ),
    );
  }
}
