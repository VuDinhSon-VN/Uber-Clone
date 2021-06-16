import 'package:UberClone/datamodels//directionDetails.dart';
import 'package:UberClone/datamodels/history.dart';
import 'package:UberClone/dataprovider.dart';
import 'package:UberClone/helper/requestHelper.dart';
import 'package:UberClone/widget/ProgressDialog.dart';
import 'package:UberClone/widget/globalvariable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';



class HelperMethod{
  static void disableHomeTabLocationUpdate(){
    homeTabPositionStream.pause();
    Geofire.removeLocation(currentFirebaseUser.uid);
  }

  static Future<DirectionDetails> getDirectionDetails(LatLng startPosition, LatLng endPosition) async{
    String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=$mapKey';

    var response = await RequestHelper.getRequest(url);

    if(response == null) return null;

    DirectionDetails directionDetails = DirectionDetails();
    directionDetails.durationText = response['routes'][0]['legs'][0]['duration']['text'];
    directionDetails.durationValue = response['routes'][0]['legs'][0]['duration']['value'];

    directionDetails.distanceText = response['routes'][0]['legs'][0]['distance']['text'];
    directionDetails.distanceValue = response['routes'][0]['legs'][0]['distance']['value'];

    directionDetails.encodedPoints = response['routes'][0]['overview_polyline']['points'];

    return directionDetails;
  }

  static void showProgressDialog(context){
    //show please wait dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: 'Please wait',),
    );
  }

  static int estimateFares (DirectionDetails details, int durationValue){
    // per km = $0.3,
    // per minute = $0.2,
    // base fare = $3,

    double baseFare = 3;
    double distanceFare = (details.distanceValue/1000) * 0.3;
    double timeFare = (durationValue / 60) * 0.2;

    double totalFare = baseFare + distanceFare + timeFare;

    return totalFare.truncate();
  }

  static void enableHomTabLocationUpdates(){
    homeTabPositionStream.resume();
    Geofire.setLocation(currentFirebaseUser.uid, currentPosition.latitude, currentPosition.longitude);
  }

  static void disableHomTabLocationUpdates(){
    homeTabPositionStream.pause();
    Geofire.removeLocation(currentFirebaseUser.uid);
  }

  static void getHistoryInfo (context){
    print("GET HISTORY INFO");
    DatabaseReference earningRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/earnings');

    earningRef.once().then((DataSnapshot snapshot){
      if(snapshot.value != null){
        String earnings = snapshot.value.toString();
        print("earnings: $earnings");
        Provider.of<AppData>(context, listen: false).updateEarnings(earnings);
      }
    });
    DatabaseReference historyRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/history');
    historyRef.once().then((DataSnapshot snapshot) {

      if(snapshot.value != null){

        Map<dynamic, dynamic> values = snapshot.value;
        int tripCount = values.length;

        // update trip count to data provider
        Provider.of<AppData>(context, listen: false).updateTripCount(tripCount);

        List<String> tripHistoryKeys = [];
        values.forEach((key, value) {tripHistoryKeys.add(key);});

        // update trip keys to data provider
        Provider.of<AppData>(context, listen: false).updateTripKeys(tripHistoryKeys);

        getHistoryData(context);
      }
    });
  }
  static void getHistoryData(context){

    var keys = Provider.of<AppData>(context, listen: false).tripHistoryKeys;

    for(String key in keys){
      DatabaseReference historyRef = FirebaseDatabase.instance.reference().child('rideRequest/$key');

      historyRef.once().then((DataSnapshot snapshot) {
        if(snapshot.value != null){

          var history = History.fromSnapshot(snapshot);
          Provider.of<AppData>(context, listen: false).updateTripHistory(history);

          print(history.destination);
        }
      });
    }
  }

  static String formatMyDate(String value){

    DateTime thisDate = DateTime.parse(value);
    String formattedDate = '${DateFormat.MMMd().format(thisDate)}, ${DateFormat.y().format(thisDate)} - ${DateFormat.jm().format(thisDate)}';

    return formattedDate;
  }
}