import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'energy_provider.dart';
import 'symptom_provider.dart';
import 'theme.dart';
import 'app_localizations.dart';

class WeeklyChartCard extends StatelessWidget {
  const WeeklyChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<EnergyProvider, SymptomProvider>(
      builder: (context, energyProvider, symptomProvider, child) {
        final energySpots = _getEnergySpots(energyProvider);
        final symptomSpots = _getSymptomSpots(symptomProvider);
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.show_chart, color: AppTheme.primaryTeal),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.t('weekly_summary'),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _legendDot(AppTheme.primaryTeal),
                    const SizedBox(width: 4),
                    Text(AppLocalizations.t('energy'), style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey.shade600)),
                    const SizedBox(width: 16),
                    _legendDot(AppTheme.accentCoral),
                    const SizedBox(width: 4),
                    Text(AppLocalizations.t('symptom'), style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey.shade600)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: (energySpots.isEmpty && symptomSpots.isEmpty)
                      ? Center(
                          child: Text(
                            AppLocalizations.t('no_data_chart'),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                          ),
                        )
                      : LineChart(
                          LineChartData(
                            minY: 0,
                            maxY: 10,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 2,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: isDark ? Colors.white12 : Colors.grey.shade200,
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 28,
                                  interval: 2,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : Colors.grey),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                   getTitlesWidget: (value, meta) {
                                    final isEn = AppLocalizations.isEnglish;
                                    final daysTr = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
                                    final daysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                    final days = isEn ? daysEn : daysTr;
                                    final idx = value.toInt();
                                    if (idx >= 0 && idx < 7) {
                                      return Text(
                                        days[idx],
                                        style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : Colors.grey),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              if (energySpots.isNotEmpty)
                                LineChartBarData(
                                  spots: energySpots,
                                  isCurved: true,
                                  color: AppTheme.primaryTeal,
                                  barWidth: 3,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, barData, index) =>
                                        FlDotCirclePainter(
                                      radius: 4,
                                      color: AppTheme.primaryTeal,
                                      strokeWidth: 2,
                                      strokeColor: Colors.white,
                                    ),
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: AppTheme.primaryTeal.withOpacity(0.1),
                                  ),
                                ),
                              if (symptomSpots.isNotEmpty)
                                LineChartBarData(
                                  spots: symptomSpots,
                                  isCurved: true,
                                  color: AppTheme.accentCoral,
                                  barWidth: 3,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, barData, index) =>
                                        FlDotCirclePainter(
                                      radius: 4,
                                      color: AppTheme.accentCoral,
                                      strokeWidth: 2,
                                      strokeColor: Colors.white,
                                    ),
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: AppTheme.accentCoral.withOpacity(0.1),
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _legendDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  List<FlSpot> _getEnergySpots(EnergyProvider provider) {
    final spots = <FlSpot>[];
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      final log = provider.getLogForDate(date);
      final avg = _averageScore(log.morningScore, log.noonScore, log.eveningScore);
      if (avg != null) {
        spots.add(FlSpot(i.toDouble(), avg));
      }
    }
    return spots;
  }

  List<FlSpot> _getSymptomSpots(SymptomProvider provider) {
    final spots = <FlSpot>[];
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      final logsForDay = provider.history.where((log) =>
          log.date.year == date.year &&
          log.date.month == date.month &&
          log.date.day == date.day);

      if (logsForDay.isNotEmpty) {
        // Scale symptom total (0-15) to 0-10 range
        final avgTotal = logsForDay.map((l) => l.totalScore).reduce((a, b) => a + b) / logsForDay.length;
        spots.add(FlSpot(i.toDouble(), (avgTotal / 15 * 10).clamp(0, 10)));
      }
    }
    return spots;
  }

  double? _averageScore(int? a, int? b, int? c) {
    final scores = [a, b, c].whereType<int>().toList();
    if (scores.isEmpty) return null;
    return scores.reduce((x, y) => x + y) / scores.length;
  }
}
