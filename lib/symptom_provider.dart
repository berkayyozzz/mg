import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'speech': speech,
      'swallowing': swallowing,
      'breathing': breathing,
      'eyelid': eyelid,
      'grooming': grooming,
      'notes': notes,
    };
  }

  factory SymptomADL.fromJson(Map<String, dynamic> json) {
    return SymptomADL(
      id: json['id'],
      date: DateTime.parse(json['date']),
      speech: json['speech'],
      swallowing: json['swallowing'],
      breathing: json['breathing'],
      eyelid: json['eyelid'],
      grooming: json['grooming'],
      notes: json['notes'] ?? '',
    );
  }
}

class SymptomProvider with ChangeNotifier {
  List<SymptomADL> _history = [];

  SymptomProvider() {
    _loadHistory();
  }

  List<SymptomADL> get history => _history;

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('symptom_history');
    if (data != null) {
      try {
        final List<dynamic> decoded = json.decode(data);
        _history = decoded.map((item) => SymptomADL.fromJson(item)).toList();
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading symptom history: $e');
      }
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(_history.map((item) => item.toJson()).toList());
    await prefs.setString('symptom_history', data);
  }

  void addLog(SymptomADL log) {
    _history.insert(0, log);
    _saveHistory();
    notifyListeners();
  }

  void removeLog(String id) {
    _history.removeWhere((log) => log.id == id);
    _saveHistory();
    notifyListeners();
  }
}
