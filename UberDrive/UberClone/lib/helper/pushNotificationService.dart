import 'dart:io';

import 'package:UberClone/datamodels/tripDetails.dart';
import 'package:UberClone/widget/ProgressDialog.dart';
import 'package:UberClone/widget/globalvariable.dart';
import 'package:UberClone/widget/notificationDialog.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationService{

final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

Future initiallize(context) async {
  print("PushNotificationService context: $context");
  if(Platform.isIOS){
    firebaseMessaging.requestNotificationPermissions(IosNotificationSettings());
  }

  firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async{
      print("PushNotificationService message: $message");
     ferchRideInfo(getRideID(message), context);
    },
    onLaunch: (Map<String, dynamic> message) async{
      print("PushNotificationService message: $message");
      ferchRideInfo(getRideID(message), context);
    },
    onResume: (Map<String, dynamic> message) async{
      print("PushNotificationService message: $message");
      ferchRideInfo(getRideID(message), context);
    },
  );
}
Future<String> getToken() async{ 

  String token = await firebaseMessaging.getToken();
  print("token: $token");

  DatabaseReference tokenRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/token');
  tokenRef.set(token);
  firebaseMessaging.subscribeToTopic('alldrivers');
  firebaseMessaging.subscribeToTopic('allusers'); 
}
//get rideID from fireBase
String getRideID(Map<String, dynamic> message){
   String rideID = '';
      if(Platform.isAndroid){
        rideID = message['data']['ride_id'];
        print("rideID: $rideID");
      }else{
        rideID = message['ride_id'];
        print("rideID: $rideID");
      }
    return rideID;
    
}
void ferchRideInfo(String rideID, context){
  print('ferchRideInfo');

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) => ProgressDialog(status: 'logging you in',),
  );

  DatabaseReference dataRef = FirebaseDatabase.instance.reference().child('rideRequest/$rideID');
  dataRef.once().then((DataSnapshot snapshot){
   
    Navigator.pop(context);

    if(snapshot.value != null){
      assetsAudioPlayer.open(
        Audio('sounds/alert.mp3'),
      );
      assetsAudioPlayer.play();
      TripDetails tripDetails = TripDetails();
    
      tripDetails.destinationAddress = snapshot.value['destination_address'].toString();
      tripDetails.riderName = snapshot.value['rideName'].toString();
      tripDetails.riderPhone = snapshot.value['phone'].toString();
      tripDetails.paymentMethod = snapshot.value['payment_mehtod'].toString();
      tripDetails.pickup = LatLng(double.parse(snapshot.value['location']['latitude'].toString()),
                                  double.parse(snapshot.value['location']['longitude'].toString()));
      tripDetails.pickupAddress = snapshot.value['pickup_address'].toString();
      tripDetails.destination = LatLng(double.parse(snapshot.value['destination']['latitude'].toString()),
                                       double.parse(snapshot.value['destination']['longitude'].toString()));

      print("TripDetail: ${tripDetails.pickupAddress}");
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => NotificationDialog(tripDetails: tripDetails,),);
      }
  });
}

}