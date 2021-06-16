import 'package:UberClone/datamodels/tripDetails.dart';
import 'package:UberClone/helper/helperMethod.dart';
import 'package:UberClone/screen/newTripPage.dart';
import 'package:UberClone/widget/taxiOutlineButton.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import '../brand_color.dart';
import 'ProgressDialog.dart';
import 'TaxiButton.dart';
import 'globalvariable.dart';
class NotificationDialog extends StatelessWidget{

  final TripDetails tripDetails;

  const NotificationDialog({Key key, this.tripDetails}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(4),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 30,),
            Image.asset('images/taxi.png', width: 100,),

            SizedBox(height: 16.0,),

            Text('NEW TRIP REQUEST', style: TextStyle(fontFamily: 'Brand-Bold', fontSize: 18),),

            SizedBox(height: 30.0,),

            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(width: 20.0,),
                      Image.asset('images/pickicon.png', height: 16, width: 16,),
                       SizedBox(width: 10.0,),
                      Expanded(child: Text(tripDetails.pickupAddress, style: TextStyle(color: Colors.greenAccent[700], fontSize: 18),)),
                    ],
                  ),
                  SizedBox(height: 20.0,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(width: 20.0,),
                      Image.asset('images/desticon.png', height: 20, width: 16,),
                       SizedBox(width: 10.0,),
                      Expanded(child:Text(tripDetails.destinationAddress, style: TextStyle(color: Colors.indigo[700], fontSize: 18),)),
                    ],
                  ),
                ],),
            ),
            SizedBox(height: 20,),
            Divider(height: 1, color: Colors.grey[200],thickness: 1,),
            SizedBox(height: 8,),

            Padding(padding: EdgeInsets.all(20),
              child: Row(

                children: <Widget>[

                  SizedBox(width: 30,),
                  Container(
                      child: TaxiOutlineButton(
                        title: 'DECLINE',
                        color: BrandColors.colorPrimary,
                        onPressed: () async {
                         // assetsAudioPlayer.stop();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                     SizedBox(width: 10,),

                     Container(
                      child: TaxiButton(
                        title: 'ACCEPT',
                        color: BrandColors.colorGreen,
                        onPressed: () async {
                          print('check accept');
                         // assetsAudioPlayer.stop();
                          Navigator.push(context, MaterialPageRoute(builder: (context) => NewTripPage(tripDetails: tripDetails)));
                          checkAvailablity(context);
                        },
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void checkAvailablity(BuildContext context) {
     //show please wait dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: 'Accepting request',),
    );

    DatabaseReference newRideRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/newTrip');
    newRideRef.once().then((DataSnapshot snapshot){
      Navigator.pop(context);
      print("newTrip: ${snapshot.value}");
      String thisRideID = "";
      if(snapshot.value != null){
        thisRideID = snapshot.value.toString();
      }
      else{
        Toast.show("Ride not found", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
      }

      if(thisRideID == tripDetails.riderID){
        newRideRef.set('accepted');
        HelperMethod.disableHomTabLocationUpdates();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewTripPage(tripDetails: tripDetails,),
        ));
      }
      else if(thisRideID == 'cancelled'){
        Toast.show("Ride has been cancelled", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
      }
      else if(thisRideID == 'timeout'){
        Toast.show("Ride has timed out", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
      }
      else{
        Toast.show("Ride not found", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
      }

    });

  }
}