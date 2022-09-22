const functions = require("firebase-functions");

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });


//Get the whole timestamp list

exports.date = functions.https.onRequest((req, res) => {
  console.log("called");
  res.end();
})

/*
exports.scheduledFunction = functions.pubsub.schedule('every 5 minutes').onRun((context) => {
    console.log('This will be run every 5 minutes!');
    update();
  });

async function update() {
    data = await getPowerData();
    console.log(data)
    data['prodSerieSum'] = sumSeries(data['prodSeries']);
    data['consSerieSum'] = sumSeries(data['consSeries']);
  }


function mostPopularValue(arr){
    return arr.sort((a,b) =>
          arr.filter(v => v===a).length
        - arr.filter(v => v===b).length
    ).pop();
}

async function getTimestamp(items) {
    var timestamps = [];

    for (var item in items) {
       url =
          'https://www.smard.de/app/chart_data/'+str(item)+'/DE/index_quarterhour.json';
      var response = await fetch(url);
      timestamps = JSON.parse(response.body)['timestamps']
      timestamps.add(timestamps[timestamps.length-1]);
    }

    timestamps.sort();
    return [timestamps[0] - 1000 * 60 * 60 * 24 * 7, timestamps[0]];
  }

//Retrieve the whole time series and trim the end null values
  async function getTimeSeries(items, timeStamp)  {
    var timeSeries = [];
    var index = [];
    for (var item in items) {
      url =
          'https://www.smard.de/app/chart_data/'+str(item)+'/DE/'+str(item)+'_DE_quarterhour_'+str(timeStamp)+'.json';
      var response = await fetch(url);
      var timeSerie = JSON.parse(response.body)['series'];
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
      timeSeriesCut.add(timeSerie.slice(0, lastIndex + 1));
    }

    //Interpolate over null data points
    for (var i = 1; i < timeSeriesCut.length; i++) {
      var timeSerie = timeSeriesCut[i];
      for (var j = 0; j < timeSerie.length; j++) {
        //If the value is null, find the next non-null to do an average with preceeding valued
        if (timeSerie[j][1] == null) {
           k = j + 1;
          left = 0;
          right = 0;
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

  async function getPowerData() {
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
      timeSeries[i] = timeSeries[i].slice(
          timeSeries[i].length - 4 * 24 * 7 - 1, timeSeries[i].length - 1);
    }

    return {
      "prodSeries": timeSeries.slice(0, 12),
      "consSeries": [timeSeries[12]]
    };
  }


//Sum all the series
function sumSeries(timeSeries) {
  var timeSerie = timeSeries[0];
  for (var i = 1; i < timeSeries.length; i++) {
    for (var j = 0; j < timeSerie.length; j++) {
      timeSerie[j][1] = (timeSerie[j][1]) + (timeSeries[i][j][1]);
    }
  }

  return timeSerie;
}
*/