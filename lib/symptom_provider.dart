import 'package:flutter/material.dart';

class SymptomADL {
  final String id;
  final DateTime date;
  final int speech; // 0-3
  final int swallowing; // 0-3
  final int breathing; // 0-3
  final int eyelid; // 0-3
  final int grooming; // 0-3
  final String notes;

  SymptomADL({
    required this.id,
    required this.date,
    this.speech = 0,
    this.swallowing = 0,
    this.breathing = 0,
    this.eyelid = 0,
    this.grooming = 0,
    this.notes = '',
  });

  int get totalScore => speech + swallowing + breathing + eyelid + grooming;
}

class SymptomProvider with ChangeNotifier {
  final List<SymptomADL> _history = [];

  List<SymptomADL> get history => _history;

  void addLog(SymptomADL log) {
    _history.insert(0, log);
    notifyListeners();
  }

  void removeLog(String id) {
    _history.removeWhere((log) => log.id == id);
    notifyListeners();
  }
}
