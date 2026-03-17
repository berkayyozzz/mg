import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnergyLog {
  final DateTime date;
  final int? morningScore;
  final int? noonScore;
  final int? eveningScore;
  final int? sleepQuality; // 1-10

  EnergyLog({
    required this.date,
    this.morningScore,
    this.noonScore,
    this.eveningScore,
    this.sleepQuality,
  });

  EnergyLog copyWith({
    int? morningScore,
    int? noonScore,
    int? eveningScore,
    int? sleepQuality,
  }) {
    return EnergyLog(
      date: date,
      morningScore: morningScore ?? this.morningScore,
      noonScore: noonScore ?? this.noonScore,
      eveningScore: eveningScore ?? this.eveningScore,
      sleepQuality: sleepQuality ?? this.sleepQuality,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'morningScore': morningScore,
      'noonScore': noonScore,
      'eveningScore': eveningScore,
      'sleepQuality': sleepQuality,
    };
  }

  factory EnergyLog.fromJson(Map<String, dynamic> json) {
    return EnergyLog(
      date: DateTime.parse(json['date']),
      morningScore: json['morningScore'],
      noonScore: json['noonScore'],
      eveningScore: json['eveningScore'],
      sleepQuality: json['sleepQuality'],
    );
  }
}

class EnergyProvider with ChangeNotifier {
  Map<String, EnergyLog> _logs = {};

  EnergyProvider() {
    _loadLogs();
  }

  List<EnergyLog> get logs => _logs.values.toList();

  Future<void> _loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('energy_logs');
    if (data != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(data);
        _logs = decoded.map((key, value) => MapEntry(key, EnergyLog.fromJson(value)));
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading energy logs: $e');
      }
    }
  }

  Future<void> _saveLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(_logs.map((key, value) => MapEntry(key, value.toJson())));
    await prefs.setString('energy_logs', data);
  }

  EnergyLog getLogForDate(DateTime date) {
    final key = _dateKey(date);
    return _logs[key] ?? EnergyLog(date: date);
  }

  void updateLog(DateTime date, {int? morning, int? noon, int? evening, int? sleep}) {
    final key = _dateKey(date);
    final current = getLogForDate(date);
    _logs[key] = current.copyWith(
      morningScore: morning,
      noonScore: noon,
      eveningScore: evening,
      sleepQuality: sleep,
    );
    _saveLogs();
    notifyListeners();
  }

  String _dateKey(DateTime date) => "${date.year}-${date.month}-${date.day}";
}
