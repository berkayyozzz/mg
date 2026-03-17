import 'package:flutter/material.dart';
import 'notification_service.dart';

class Medication {
  final String id;
  final String name;
  final String dosage;
  final List<TimeOfDay> times;
  final bool isActive;
  final Map<String, bool> takenStatus; // Key: 'YYYY-MM-DD_HH:mm', Value: true if taken

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.times,
    this.isActive = true,
    Map<String, bool>? takenStatus,
  }) : takenStatus = takenStatus ?? {};

  String _getTimeKey(DateTime date, TimeOfDay time) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}_${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  bool isTaken(DateTime date, TimeOfDay time) {
    return takenStatus[_getTimeKey(date, time)] ?? false;
  }

  void toggleTaken(DateTime date, TimeOfDay time) {
    final key = _getTimeKey(date, time);
    final current = takenStatus[key] ?? false;
    takenStatus[key] = !current;
  }
}

class MedicationProvider with ChangeNotifier {
  final List<Medication> _medications = [
    Medication(
      id: '1',
      name: 'Mestinon (Piridostigmin)',
      dosage: '60 mg',
      times: [
        const TimeOfDay(hour: 08, minute: 00),
        const TimeOfDay(hour: 12, minute: 00),
        const TimeOfDay(hour: 16, minute: 00),
        const TimeOfDay(hour: 20, minute: 00),
      ],
    ),
  ];

  MedicationProvider() {
    _scheduleAllNotifications();
  }

  List<Medication> get medications => _medications;

  void addMedication(Medication med) {
    _medications.add(med);
    _scheduleAllNotifications();
    notifyListeners();
  }

  void removeMedication(String id) {
    _medications.removeWhere((m) => m.id == id);
    _scheduleAllNotifications();
    notifyListeners();
  }

  void toggleMedicationTaken(String id, DateTime date, TimeOfDay time) {
    final medIndex = _medications.indexWhere((m) => m.id == id);
    if (medIndex != -1) {
      _medications[medIndex].toggleTaken(date, time);
      notifyListeners();
    }
  }

  void _scheduleAllNotifications() {
    NotificationService.cancelAll();
    int notificationId = 0;
    for (var med in _medications) {
      if (med.isActive) {
        for (var time in med.times) {
          NotificationService.scheduleNotification(
            id: notificationId++,
            title: 'İlaç Vakti: ${med.name}',
            body: 'Doz: ${med.dosage}. Lütfen ilacınızı almayı unutmayın.',
            time: time,
          );
        }
      }
    }
  }
}
