import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/expense_controller.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ExpenseController>();
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: Obx(() {
        final data = c.monthlyByCategory(now);
        final keys = data.keys.toList();
        if (keys.isEmpty) return const Center(child: Text('No data'));
        final bars = <BarChartGroupData>[];
        for (int i = 0; i < keys.length; i++) {
          final v = data[keys[i]] ?? 0;
          bars.add(BarChartGroupData(x: i, barRods: [BarChartRodData(toY: v)]));
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('This Month: ₹${c.monthTotal.value.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Expanded(
                child: BarChart(
                  BarChartData(
                    titlesData: FlTitlesData(
                      leftTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: true)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= keys.length)
                              return const SizedBox.shrink();
                            return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(keys[i]));
                          },
                        ),
                      ),
                    ),
                    barGroups: bars,
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
