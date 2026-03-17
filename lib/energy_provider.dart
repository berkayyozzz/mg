import 'package:flutter/material.dart';

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
}

class EnergyProvider with ChangeNotifier {
  final Map<String, EnergyLog> _logs = {};

  List<EnergyLog> get logs => _logs.values.toList();

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
    notifyListeners();
  }

  String _dateKey(DateTime date) => "${date.year}-${date.month}-${date.day}";
}
