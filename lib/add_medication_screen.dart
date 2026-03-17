import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'medication_provider.dart';
import 'theme.dart';
import 'app_localizations.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final List<TimeOfDay> _times = [];

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  String _formatTime24h(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _addTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppTheme.primaryTeal,
                onPrimary: Colors.white,
                onSurface: AppTheme.textDark,
              ),
            ),
            child: child!,
          ),
        );
      },
    );
    if (time != null) {
      setState(() {
        _times.add(time);
        _times.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      });
    }
  }

  void _saveMedication() {
    if (_formKey.currentState!.validate()) {
      if (_times.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.t('add_min_time'))),
        );
        return;
      }

      final newMedication = Medication(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        times: _times,
      );

      context.read<MedicationProvider>().addMedication(newMedication);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.t('add_medication'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22, letterSpacing: 0.5))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.t('medication_name'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.medication),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? AppLocalizations.t('name_required') : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.t('dosage'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.vaccines),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? AppLocalizations.t('dosage_required') : null,
              ),
              const SizedBox(height: 24),
              Text(AppLocalizations.t('reminder_times'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_times.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(AppLocalizations.t('no_reminder')),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _times.asMap().entries.map((entry) {
                    final int idx = entry.key;
                    final TimeOfDay time = entry.value;
                    return Chip(
                      label: Text(_formatTime24h(time), style: const TextStyle(fontSize: 16)),
                      backgroundColor: Colors.blue.shade50,
                      deleteIcon: const Icon(Icons.cancel, color: Colors.red),
                      onDeleted: () {
                        setState(() {
                          _times.removeAt(idx);
                        });
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _addTime,
                icon: const Icon(Icons.access_time),
                label: Text(AppLocalizations.t('add_time')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCoral,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveMedication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: Text(AppLocalizations.t('save')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
