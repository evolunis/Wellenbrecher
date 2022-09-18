//flutter run -d chrome --web-renderer html

import 'package:flutter/foundation.dart';
import 'package:shelly_controller/utils/helpers.dart';
import 'package:shelly_controller/utils/api_calls.dart';
import 'dart:convert';

class TimeSeriesModel extends ChangeNotifier {
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
    return timestamps[0];
  }

//Retrive the whole time series and trim the end null values
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
    index.sort();

    var timeSeriesClean = [];
    for (var timeSerie in timeSeries) {
      timeSeriesClean.add(timeSerie.sublist(0, index[0]));
    }
    return timeSeriesClean;
    //print(index);
    //print(index[0]);
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
    int timeStamp = await getTimestamp(items);
    var timeSeries = await getTimeSeries(items, timeStamp);

    //Get last data point
    var lastData = [];
    for (var timeSerie in timeSeries) {
      lastData.add(timeSerie.last[1] ?? 0);
    }
    var prod = sum(lastData.sublist(0, 11));
    var cons = lastData[12];

    //print(lastData);
    return {
      "prodSeries": timeSeries.sublist(0, 11),
      "consSeries": timeSeries.last,
      "prod": prod,
      "cons": cons,
    };
  }
}
