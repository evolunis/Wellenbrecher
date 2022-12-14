import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:wellenbrecher/models/time_series.dart';
import 'package:wellenbrecher/utils/helpers.dart';

class TimeSeries extends StatelessWidget {
  const TimeSeries({super.key});

  //Chooses which vertical grid lines should be shown
  bool verticalLineShow(double value) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());

    if (date.hour % 6 == 0 && date.minute == 0 && date.second == 0) {
      return true;
    }
    return false;
  }

  //Returns the bottom axis values
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

  //Returns the vertical axis values
  Widget sideTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 12,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );

    String text = "";

    if (true) {
      text = (value / 1000).toStringAsFixed(0);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 15, bottom: 2),
          child: SizedBox(
              height: 30,
              child: Consumer<TimeSeriesModel>(
                  builder: (context, timeSeries, child) {
                return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Power market",
                          style: Theme.of(context).textTheme.headlineSmall),
                      Padding(
                          padding: const EdgeInsets.only(top: 2, right: 15),
                          child: Row(children: [
                            RichText(
                              text: TextSpan(children: [
                                const TextSpan(
                                    text: "Prod: ",
                                    style: TextStyle(color: Colors.black)),
                                TextSpan(
                                    text:
                                        "${(timeSeries.getData()['prodSerieSum'].last[1] / 1000).toStringAsFixed(1)}",
                                    style: const TextStyle(color: Colors.blue))
                              ]),
                            ),
                            RichText(
                              text: TextSpan(children: [
                                const TextSpan(
                                    text: " Cons: ",
                                    style: TextStyle(color: Colors.black)),
                                TextSpan(
                                    text:
                                        "${(timeSeries.getData()['consSerieSum'].last[1] / 1000).toStringAsFixed(1)}",
                                    style: const TextStyle(color: Colors.red))
                              ]),
                            ),
                            const Text(" (GWh)")
                          ]))
                    ]);
              }))),
      Expanded(
        child: Center(
          child:
              Consumer<TimeSeriesModel>(builder: (context, timeSeries, child) {
            if (!timeSeries.isLoaded()) {
              return const CircularProgressIndicator(
                value: null,
                semanticsLabel: 'Circular progress indicator',
              );
            } else {
              return Padding(
                  padding: const EdgeInsets.fromLTRB(5, 30, 5, 1),
                  child: LineChart(LineChartData(
                      lineTouchData: LineTouchData(
                          getTouchedSpotIndicator: (LineChartBarData barData,
                              List<int> spotIndexes) {
                            return spotIndexes.map((spotIndex) {
                              final spot = barData.spots[spotIndex];
                              if (spot.x == 0 || spot.x == 6) {
                                return null;
                              }
                              return TouchedSpotIndicatorData(
                                FlLine(color: Colors.blue, strokeWidth: 0),
                                FlDotData(
                                  getDotPainter:
                                      (spot, percent, barData, index) {
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
                              tooltipBgColor: Colors.green,
                              fitInsideHorizontally: true,
                              maxContentWidth: 100,
                              getTooltipItems: (touchedSpots) {
                                bool first = true;
                                return touchedSpots
                                    .map((LineBarSpot touchedSpot) {
                                  final textStyle = TextStyle(
                                    color:
                                        touchedSpot.bar.gradient?.colors[0] ??
                                            touchedSpot.bar.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  );
                                  if (first) {
                                    first = false;
                                    return LineTooltipItem(
                                        '${timestampToString(touchedSpot.x.toInt(), "HH:mm:ss")}\n',
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
                                        (touchedSpot.y / 1000)
                                            .toStringAsFixed(1),
                                        textStyle);
                                  }
                                }).toList();
                              }),
                          handleBuiltInTouches: true,
                          getTouchLineStart: (data, index) => 0),
                      minX: timeSeries
                              .getData()['consSerieSum']
                              .first[0]
                              .toDouble() +
                          1000 * 60 * 60 * 24 * 2,
                      maxX: timeSeries
                          .getData()['consSerieSum']
                          .last[0]
                          .toDouble(),
                      minY: 5000.0,
                      maxY: 20000.0,
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
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
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
      ),
      Consumer<TimeSeriesModel>(builder: (context, timeSeries, child) {
        if (timeSeries.isLoaded()) {
          return Center(
              child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                      'Last update at ${timestampToString(timeSeries.lastUpdate(), "HH:mm")}.')));
        } else {
          return const SizedBox.shrink();
        }
      })
    ]);
  }
}
