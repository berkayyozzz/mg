import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'times': times.map((t) => {'hour': t.hour, 'minute': t.minute}).toList(),
      'isActive': isActive,
      'takenStatus': takenStatus,
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      times: (json['times'] as List).map((t) => TimeOfDay(hour: t['hour'], minute: t['minute'])).toList(),
      isActive: json['isActive'] ?? true,
      takenStatus: Map<String, bool>.from(json['takenStatus'] ?? {}),
    );
  }
}

class MedicationProvider with ChangeNotifier {
  List<Medication> _medications = [
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
    _loadMedications();
  }

  List<Medication> get medications => _medications;

  Future<void> _loadMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('medications');
    if (data != null) {
      try {
        final List<dynamic> decoded = json.decode(data);
        _medications = decoded.map((m) => Medication.fromJson(m)).toList();
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading medications: $e');
      }
    }
    _scheduleAllNotifications();
  }

  Future<void> _saveMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(_medications.map((m) => m.toJson()).toList());
    await prefs.setString('medications', data);
  }

  void addMedication(Medication med) {
    _medications.add(med);
    _saveMedications();
    _scheduleAllNotifications();
    notifyListeners();
  }

  void removeMedication(String id) {
    _medications.removeWhere((m) => m.id == id);
    _saveMedications();
    _scheduleAllNotifications();
    notifyListeners();
  }

  void toggleMedicationTaken(String id, DateTime date, TimeOfDay time) {
    final medIndex = _medications.indexWhere((m) => m.id == id);
    if (medIndex != -1) {
      _medications[medIndex].toggleTaken(date, time);
      _saveMedications();
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
