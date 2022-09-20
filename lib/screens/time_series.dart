import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:shelly_controller/models/time_series.dart';

class TimeSeries extends StatelessWidget {
  const TimeSeries({super.key});

  bool verticalLineShow(double value) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());

    if (date.hour % 6 == 0 && date.minute == 0 && date.second == 0) {
      return true;
    }
    return false;
  }

  toDate(value) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    DateFormat dateFormat = DateFormat("HH:mm:ss");
    return dateFormat.format(date);
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 12,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );
    DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());

    DateFormat dateFormat = DateFormat("E dd");

    String text = "";

    if (date.hour == 0 && date.minute == 0 && date.second == 0) {
      text = dateFormat.format(date);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }

  Widget sideTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 12,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );

    String text = "";

    if (true) {
      text = (value / 1000).toString();
    }

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
          if (!timeSeries.isLoaded()) {
            return const CircularProgressIndicator(
              value: null,
              semanticsLabel: 'Circular progress indicator',
            );
          } else {
            return Padding(
                padding: const EdgeInsets.fromLTRB(1, 15, 1, 1),
                child: LineChart(LineChartData(
                    lineTouchData: LineTouchData(
                        getTouchedSpotIndicator:
                            (LineChartBarData barData, List<int> spotIndexes) {
                          return spotIndexes.map((spotIndex) {
                            final spot = barData.spots[spotIndex];
                            if (spot.x == 0 || spot.x == 6) {
                              return null;
                            }
                            return TouchedSpotIndicatorData(
                              FlLine(color: Colors.blue, strokeWidth: 0),
                              FlDotData(
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 8,
                                    color: barData.color?.withAlpha(159),
                                    strokeColor:
                                        barData.color?.withOpacity(1.0),
                                    strokeWidth: 5,
                                  );
                                },
                              ),
                            );
                          }).toList();
                        },
                        touchTooltipData: LineTouchTooltipData(
                            fitInsideHorizontally: true,
                            maxContentWidth: 100,
                            getTooltipItems: (touchedSpots) {
                              bool first = true;
                              return touchedSpots
                                  .map((LineBarSpot touchedSpot) {
                                final textStyle = TextStyle(
                                  color: touchedSpot.bar.gradient?.colors[0] ??
                                      touchedSpot.bar.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                );
                                if (first) {
                                  first = false;
                                  return LineTooltipItem(
                                      '${toDate(touchedSpot.x)}\n',
                                      const TextStyle(color: Colors.black),
                                      children: [
                                        TextSpan(
                                          text: (touchedSpot.y / 1000)
                                              .toStringAsFixed(1),
                                          style: textStyle,
                                        )
                                      ]);
                                } else {
                                  return LineTooltipItem(
                                      (touchedSpot.y / 1000).toStringAsFixed(1),
                                      textStyle);
                                }
                              }).toList();
                            }),
                        handleBuiltInTouches: true,
                        getTouchLineStart: (data, index) => 0),
                    minX: timeSeries.getData()['consSerieSum'].first[0],
                    maxX: timeSeries.getData()['consSerieSum'].last[0],
                    minY: 5000,
                    maxY: 20000,
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                        verticalInterval: 1000 * 60 * 15,
                        checkToShowVerticalLine: verticalLineShow),
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
                          interval: 1000 * 60 * 15,
                          getTitlesWidget: bottomTitleWidgets,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        axisNameWidget: const Text("GWh"),
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 5000,
                          getTitlesWidget: sideTitleWidgets,
                        ),
                      ),
                      rightTitles: AxisTitles(
                        axisNameWidget: const Text("GWh"),
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 5000,
                          getTitlesWidget: sideTitleWidgets,
                        ),
                      ),
                    ))));
          }
        }),
      ),
    );
  }
}
