const functions = require("firebase-functions");
const admin = require('firebase-admin');
const fetch = require("node-fetch");
const { topic } = require("firebase-functions/v1/pubsub");
admin.initializeApp(functions.config().firebase);
db = admin.database();




exports.smartGridApiCall = functions.pubsub.schedule('every 15 minutes').onRun((context) => {
    return update().then(()=> {
      return null;});
  });
  
  /* TEST
  exports.smartGridApiCall = functions.https.onRequest((request, res) => {
       functions.logger.info("Hello logs!", {structuredData: true});
       update().then(()=>{res.end()});
     });
*/

async function update() {
    var data = await getPowerData();
    data['prodSerieSum'] = sumSeries(data['prodSeries']);
    data['consSerieSum'] = sumSeries(data['consSeries']);
    delete data['prodSeries'];
    delete data['consSeries'];

    const ref = db.ref('/data');
    return ref.set(data).then(()=>{
      return true;});
    
  }


function mostPopularValue(arr){
    return arr.sort((a,b) =>
          arr.filter(v => v===a).length
        - arr.filter(v => v===b).length
    ).pop();
}

async function getTimestamp(items) { 
     
      timestamps = await fetchTimeStamps(items); 
    timestamps.sort();
    return [timestamps[0] - 1000 * 60 * 60 * 24 * 7, timestamps[0]];
    
  }

async function fetchTimeStamps(items){ 
  var requests = [];
  for (let item of items) {
     url =
        'https://www.smard.de/app/chart_data/'+item+'/DE/index_quarterhour.json';
        
    requests.push(fetch(url))
}
    
    return Promise.all(requests).then(responses=>{
    jsons = [];
    for(response of responses){
        jsons.push(response.json())
        }
    return Promise.all(jsons).then(jsons=>{
        timestamps=[]
        for(json of jsons){
            time = json['timestamps']
        timestamps.push(time[time.length-1]);
        }
        return timestamps;
    })
    })
    
}

async function fetchTimeSeries(items,timeStamp){
    
    responses=[];
    for (item of items) {
      url =
          'https://www.smard.de/app/chart_data/'+item+'/DE/'+item+'_DE_quarterhour_'+timeStamp+'.json';
    responses.push(fetch(url));
    }
    return Promise.all(responses).then(responses=>{
        jsons = [];
        for(response of responses){
            jsons.push(response.json())
        }
        return Promise.all(jsons).then(jsons=>{
            index = []
            timeSeries =[]
            for(json of jsons){
                timeSerie = json['series'];
                
            for (var i = timeSerie.length - 1; i > 0; i--) {
                if (timeSerie[i][1] != null) {
                  index.push(i);
                  break;
                }
              }
              timeSeries.push(timeSerie);
            }
            return [timeSeries,index];
        })
    })
}



//Retrieve the whole time series and trim the end null values
  async function getTimeSeries(items, timeStamp)  {
    
    [timeSeries, index] = await fetchTimeSeries(items,timeStamp);

   
    //Finds last data index, values after are all null
    var lastIndex = mostPopularValue(index);
  
    var timeSeriesCut = [];
    for (var timeSerie of timeSeries) {
      timeSeriesCut.push(timeSerie.slice(0, lastIndex + 1));
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
          timeSeries[i].length - 4 * 24 * 7 - 1, timeSeries[i].length);
    }
  

    return {
      "prodSeries": timeSeries.slice(0, 12),
      "consSeries": [timeSeries[12]]
    }
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



exports.sendHttpPushNotification = functions.https.onRequest((req, res) => {
  
  sendNotification().then((r)=>{
    const ref = db.ref('/testNotif');
  return ref.set((new Date()).toISOString()).then(()=>{
    res.end();});

  })
  
})

exports.sendHttpServerPushed = functions.https.onRequest((req, res) => {
  
  sendServerPush().then((r)=>{
    const ref = db.ref('/testPushed');
  return ref.set((new Date()).toISOString()).then(()=>{
    res.end();});
  
  })
  
})

async function sendNotification() 
{ 
const topic = "All";
  const message = "This is test";
  const payload = {
      "notification": {
          "title": 'cloud function demo',
          "body": message,
      },
      "data": {
          "body": message,
      },
      "content_available": true,
      "android":{
        "priority":"normal"
      },
      "apns":{
        "headers":{
          "apns-priority":"10"
        }
      },
      "token":"c_z7v2VciEC0rFCG-Z9_tZ:APA91bEuZxL5UmQAiqhV-16vDX_mDI64sb2EV0HaeQfGjwj6XvBZIgE8RC7dzW4vL27Ld6NWCejbI98f2Dg4d8ehHFSkvJh84Fa41Pmj3xAO-6BSDCdwgpj1IM2UWJ6IyIPH40KXdckD",
  };

  return admin.messaging().send(payload).then((response) => {
    // Response is a message ID string.
    console.log('Successfully sent message:', response);
    return {success: true};
}).catch((error) => {
    return {error: error.code};
});

}

async function sendServerPush() 
{ 
const topic = "All";
  const message = "This is test";
  const payload = {
          "data": {
          "body": message,
      },
      "content_available": true,
      "android":{
        "priority":"normal"
      },
      "apns":{
        "headers":{
          "apns-priority":"5"
        }
      },
      "token":"c_z7v2VciEC0rFCG-Z9_tZ:APA91bEuZxL5UmQAiqhV-16vDX_mDI64sb2EV0HaeQfGjwj6XvBZIgE8RC7dzW4vL27Ld6NWCejbI98f2Dg4d8ehHFSkvJh84Fa41Pmj3xAO-6BSDCdwgpj1IM2UWJ6IyIPH40KXdckD",
      //"click_action": "FLUTTER_NOTIFICATION_CLICK",
  };
  
  return admin.messaging().send(payload).then((response) => {
      // Response is a message ID string.
      console.log('Successfully sent message:', response);
      return {success: true};
  }).catch((error) => {
      return {error: error.code};
  });

}


exports.testCalled = functions.https.onRequest((req, res) => {
  
  const ref = db.ref('/testReceived');
  return ref.set((new Date()).toISOString()).then(()=>{
    res.end();});
    
})

