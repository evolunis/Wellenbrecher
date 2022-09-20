//flutter run -d chrome --web-renderer html

import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shelly_controller/utils/api_calls.dart';
import 'dart:convert';

import 'package:shelly_controller/utils/helpers.dart';

class TimeSeriesModel extends ChangeNotifier {
  Map? data;

  init() async {
    data = await getPowerData();
    data?['prodSerieSum'] = sumSeries(data?['prodSeries']);
    data?['consSerieSum'] = sumSeries(data?['consSeries']);
    notifyListeners();
  }

  isLoaded() {
    return data != null ? true : false;
  }

  getData() {
    return data;
  }

  lastUpdate() {
    return data?['consSerieSum'].last[0];
  }

  toFlSpots(List list, int interval) {
    List<FlSpot> spots = [];
    for (var i = 0; i < list.length; i += interval) {
      spots.add(FlSpot(list[i][0].toDouble(), list[i][1].toDouble() ?? 0.0));
    }

    return spots;
  }

//Get the whole timestamp list
  getTimestamp(items) async {
    var timestamps = [];

    for (var item in items) {
      String url =
          'https://www.smard.de/app/chart_data/$item/DE/index_quarterhour.json';
      var response = await fetchGet(url);
      timestamps.add(jsonDecode(response.body)['timestamps'].last);
    }

    timestamps.sort();
    return [timestamps[0] - 1000 * 60 * 60 * 24 * 7, timestamps[0]];
  }

//Retrieve the whole time series and trim the end null values
  getTimeSeries(items, timeStamp) async {
    var timeSeries = [];
    var index = [];
    for (var item in items) {
      String url =
          'https://www.smard.de/app/chart_data/$item/DE/${item}_DE_quarterhour_$timeStamp.json';
      var response = await fetchGet(url);
      var timeSerie = jsonDecode(response.body)['series'];
      for (var i = timeSerie.length - 1; i > 0; i--) {
        if (timeSerie[i][1] != null) {
          index.add(i);
          break;
        }
      }
      timeSeries.add(timeSerie);
    }

    //Finds last data index, values after are all null
    var lastIndex = mostPopularValue(index);

    var timeSeriesCut = [];
    for (var timeSerie in timeSeries) {
      timeSeriesCut.add(timeSerie.sublist(0, lastIndex + 1));
    }

    //Interpolate over null data points
    for (var i = 1; i < timeSeriesCut.length; i++) {
      var timeSerie = timeSeriesCut[i];
      for (var j = 0; j < timeSerie.length; j++) {
        //If the value is null, find the next non-null to do an average with preceeding valued
        if (timeSerie[j][1] == null) {
          int k = j + 1;
          int left = 0;
          int right = 0;
          if (j != 0 && j != lastIndex) {
            left = timeSerie[j - 1][1];
            while (timeSerie[k][1] == null) {
              k++;
              if (k == lastIndex) {
                timeSerie[k][1] = left;
                break;
              }
            }
            right = timeSerie[k][1];
            //Last value is null
          } else if (j == lastIndex) {
            k = j - 1;
            left = right = timeSerie[k][1];
          } //First value is null
          else {
            while (timeSerie[k][1] == null) {
              k++;
              if (k == lastIndex) {
                timeSerie[k][1] = 0;
                break;
              }
            }
            left = right = timeSerie[k][1];
          }

          timeSerie[j][1] = (left + right) / 2;
        }
      }
      timeSeriesCut[i] = timeSerie;
    }
    return timeSeriesCut;
  }

  getPowerData() async {
    var itemsGen = [
      1223,
      1224,
      1225,
      1226,
      1227,
      1228,
      4066,
      4067,
      4068,
      4069,
      4070,
      4071
    ];

    var itemsCons = [410];

    var items = [...itemsGen, ...itemsCons];
    var timeStamps = await getTimestamp(items);
    var timeSeriesPast = await getTimeSeries(items, timeStamps[0]);
    var timeSeriesNow = await getTimeSeries(items, timeStamps[1]);

    var timeSeries = timeSeriesPast;
    for (var i = 0; i < timeSeries.length; i++) {
      timeSeries[i] = [...timeSeries[i], ...timeSeriesNow[i]];
      timeSeries[i] = timeSeries[i].sublist(
          timeSeries[i].length - 4 * 24 * 7 - 1, timeSeries[i].length - 1);
    }

    return {
      "prodSeries": timeSeries.sublist(0, 12),
      "consSeries": [timeSeries[12]]
    };
  }
}

//Sum all the series
sumSeries(timeSeries) {
  var timeSerie = timeSeries[0];
  for (var i = 1; i < timeSeries.length; i++) {
    for (var j = 0; j < timeSerie.length; j++) {
      timeSerie[j][1] = (timeSerie[j][1]) + (timeSeries[i][j][1]);
    }
  }

  return timeSerie;
}
