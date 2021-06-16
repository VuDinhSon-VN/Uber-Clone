import 'dart:convert';
import 'dart:math';

import 'package:UberClone/datamodels/address.dart';
import 'package:UberClone/datamodels/directiondetails.dart';
import 'package:UberClone/datamodels/user.dart';
import 'package:UberClone/dataprovider/appdata.dart';
import 'package:UberClone/helpers/requestHelper.dart';
import 'package:UberClone/widget/globalvariable.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class HelperMethods {

  static void getCurrentUserInfo() async{
    currentFirebaseUser = await FirebaseAuth.instance.currentUser();
    String userid = currentFirebaseUser.uid;
    print("User ID: $userid");
    DatabaseReference reference = FirebaseDatabase.instance.reference().child('users/$userid');
    reference.once().then((DataSnapshot snapshot){
      if(snapshot != null){
        currentUserInfo = User.fromSnapshot(snapshot);
        print('User Login: ${currentUserInfo.fullName}');
             }
    });
  }

  static Future<String> findCordinateAddress(Position position, context) async {
    String plateAddress = '';
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      return plateAddress;
    }
    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey';
    var response = await RequestHelper.getRequest(url);

    if (response != false) {
      plateAddress = response['results'][0]['formatted_address'];

      Address pickupAddress = new Address();
      pickupAddress.longitude = position.longitude;
      pickupAddress.latitude = position.latitude;
      pickupAddress.placeName = plateAddress;
      print('GET pickupAddress');
      print(pickupAddress.longitude);
      print(pickupAddress.latitude);
      print(pickupAddress.placeName);

      Provider.of<AppData>(context, listen: false)
          .updatePickupAddress(pickupAddress);
    }
    return plateAddress;
  }

 static Future<DirectionDetails> getDirectionDetails(LatLng pickLatLng,LatLng destinationLatLng) async{
   // String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${pickLatLng.latitude},${pickLatLng.longitude}&destination=${destinationLatLng.latitude},${destinationLatLng.longitude}&key=$mapKey';
    String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${pickLatLng.latitude},${pickLatLng.longitude}&destination=${destinationLatLng.latitude},${destinationLatLng.longitude}&mode=driving&key=$mapKey';
    var response = await RequestHelper.getRequest(url);

    if(response == "failed") return null;

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.durationText = response['routes'][0]['legs'][0]['duration']['text'];
    directionDetails.durationValue = response['routes'][0]['legs'][0]['duration']['value'];

    directionDetails.distanceText = response['routes'][0]['legs'][0]['distance']['text'];
    directionDetails.distanceValue = response['routes'][0]['legs'][0]['distance']['value'];

    directionDetails.encodedPoints = response['routes'][0]['overview_polyline']['points'];

    return directionDetails;

 }

 static int estimateFares(DirectionDetails details){
   // per km = $0.3,
   // per minute = $0.2,
   // base fare = $3,

   double baseFare = 3;
   double distanceFare = (details.distanceValue/1000)*0.3;
   double timeFare = (details.durationValue/60)*0.2;

   double totalFate = baseFare+distanceFare+timeFare;

   return totalFate.truncate();
 }

static double generateRandomNumber(int randum){
  var randomGenarate = Random();
  int ranInt = randomGenarate.nextInt(randum);
return ranInt.toDouble();
}

static sendNotification(String token, context, String ride_ID) async {

    var destination = Provider.of<AppData>(context).destinationAddress;

    Map<String, String> headerMap = {
      'Content-Type': 'application/json',
      'Authorization': serverKey,
    };
    Map notificationMap = {
      'title': 'NEW TRIP REQUEST',
      'body': 'Destination, ${destination.placeName}'
    };
    Map dataMap = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'ride_id' : ride_ID,
    };
    Map bodyMap = {
      'notification': notificationMap,
      'data': dataMap,
      'priority': 'high',
      'to': token,
    };

    var response = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: headerMap,
      body: jsonEncode(bodyMap),
    );
    print(response.body);
}
}


