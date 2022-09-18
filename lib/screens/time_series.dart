import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:shelly_controller/models/time_series.dart';

class TimeSeries extends StatelessWidget {
  const TimeSeries({super.key});

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 10,
      color: Colors.purple,
      fontWeight: FontWeight.bold,
    );
    DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    DateFormat dateFormat = DateFormat("dd/MM HH:mm");
    String text = dateFormat.format(date);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Appbar
      appBar: AppBar(
        title: const Text("Power Data"),
      ),
      body: Center(
        child: Consumer<TimeSeriesModel>(builder: (context, timeSeries, child) {
          return LineChart(
            LineChartData(
              minX: timeSeries.getData()['consSerieSum'].first[0],
              maxX: timeSeries.getData()['consSerieSum'].last[0],
              minY: 4500,
              borderData: FlBorderData(show: false),
              lineBarsData: [
                // The red line
                LineChartBarData(
                  spots: timeSeries.toFlSpots(
                      timeSeries.getData()['consSerieSum'], 5),
                  isCurved: true,
                  dotData: FlDotData(
                    show: false,
                  ),
                  barWidth: 3,
                  color: Colors.red,
                ),
                // The orange line
                LineChartBarData(
                    spots: timeSeries.toFlSpots(
                        timeSeries.getData()['prodSerieSum'], 5),
                    isCurved: true,
                    dotData: FlDotData(
                      show: false,
                    ),
                    barWidth: 3,
                    color: Colors.blue,
                    belowBarData: BarAreaData(
                      show: true,
                    )),
              ],
              titlesData: FlTitlesData(
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 100000000,
                    getTitlesWidget: bottomTitleWidgets,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
