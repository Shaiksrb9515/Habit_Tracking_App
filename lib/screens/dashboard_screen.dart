import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'habit_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Column(
        children: [
          const Text('Overall Progress', style: TextStyle(fontSize: 20)),
          Expanded(
            child: _buildChart(context),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    return StreamBuilder(
      stream: Provider.of<HabitProvider>(context).habits,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final habits = snapshot.data!.docs;
        List<BarChartGroupData> barGroups = [];

        for (var habit in habits) {
          List<DateTime> completedDates = List.from(
              habit['completedDates'].map((date) => (date as Timestamp).toDate()));
          barGroups.add(_generateBarGroupData(habit['name'], completedDates));
        }

        return BarChart(BarChartData(
          barGroups: barGroups,
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(value.toInt().toString());
                },
              ),
            ),
          ),
        ));
      },
    );
  }

  BarChartGroupData _generateBarGroupData(String habitName, List<DateTime> completedDates) {
    // Example of generating chart data from completed dates
    Map<String, int> dateCount = {};
    for (var date in completedDates) {
      String formattedDate = "${date.year}-${date.month}-${date.day}";
      dateCount[formattedDate] = (dateCount[formattedDate] ?? 0) + 1;
    }

    List<BarChartRodData> barRods = [];
    dateCount.forEach((key, value) {
      barRods.add(BarChartRodData(toY: value.toDouble(), color: Colors.blue));
    });

    return BarChartGroupData(
      x: dateCount.keys.length,
      barRods: barRods,
    );
  }
}
