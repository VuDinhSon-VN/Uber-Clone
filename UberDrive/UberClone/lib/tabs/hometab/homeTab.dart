import 'dart:async';

import 'package:UberClone/datamodels/driver.dart';
import 'package:UberClone/helper/helperMethod.dart';
import 'package:UberClone/helper/pushNotificationService.dart';
import 'package:UberClone/widget/AvailabilityBotton.dart';
import 'package:UberClone/widget/ConfirmSheet.dart';
import 'package:UberClone/widget/brand_color.dart';
import 'package:UberClone/widget/globalvariable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTab extends StatefulWidget {
  HomeTab({Key key}) : super(key: key);
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin<HomeTab>{
  GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();
  DatabaseReference tripRequestRef;

  var geoLocatior = Geolocator();
  var locationOptions = LocationOptions(
      accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 4);

  String availabilityTitle = "Go Online";
  Color availabilityColor = BrandColors.colorOrange;
  bool isAvailable = false;

  @override
  void initState() {
    super.initState();  
     getCurrentDriverInfo();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
      children: <Widget>[
        GoogleMap(
          padding: EdgeInsets.only(top: 30),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          mapToolbarEnabled: true,
          mapType: MapType.normal,
          initialCameraPosition: googlePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            mapController = controller;
            getCurrentPosition();
          },
        ),
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AvailabilityButton(
                title: availabilityTitle,
                color: availabilityColor,
                onPressed: () {
                  showModalBottomSheet(
                    isDismissible: false,
                    context: context,
                    builder: (BuildContext context) => ConfirmSheet(

                      title: (!isAvailable) ? 'GO ONLINE' : 'GO OFFLINE',
                      subtitle: (!isAvailable) ? 'You are about to become available to receive trip requests'
                                               : 'you will stop receiving new trip requests',
                      onPressed: (){
                        if(!isAvailable){
                          goOnline();
                          getLocationUpdates();
                          Navigator.pop(context);
                          setState(() {
                            availabilityColor = BrandColors.colorGreen;
                            availabilityTitle = 'GO OFFLINE';
                            isAvailable = true;
                          });
                        }
                        else{
                          goOffline();
                          Navigator.pop(context);
                          setState(() {
                            availabilityColor = BrandColors.colorOrange;
                            availabilityTitle = 'GO ONLINE';
                            isAvailable = false;
                            tripRequestRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/newTrip');
                            tripRequestRef.set('stop');
                          });
                        }
                      },
                    ),
                  );
                },
               ),
            ],
          ),
        ),
      ],
    ),);
    
  }

  void getCurrentPosition() async {
    print('setupPositionLocator');
    Position position = await geoLocatior.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;

    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom: 15);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));
  }

  void getCurrentDriverInfo () async {
    currentFirebaseUser = await FirebaseAuth.instance.currentUser();
    DatabaseReference driverRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}');
    driverRef.once().then((DataSnapshot snapshot){
      if(snapshot.value != null){
        currentDriverInfo = Driver.fromSnapshot(snapshot);
        print("currentDriverInfo: ${currentDriverInfo.fullName}");
      }
    });
    HelperMethod.getHistoryInfo(context);
  }
  void goOnline() {
    print("GO ONLINE");
    PushNotificationService pushNotificationService = PushNotificationService();
    pushNotificationService.initiallize(context);
    pushNotificationService.getToken();
    Geofire.initialize('driversAvailable');
    Geofire.setLocation(currentFirebaseUser.uid, currentPosition.latitude, currentPosition.longitude);
    tripRequestRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/newTrip');
    tripRequestRef.set('waiting');
    tripRequestRef.onValue.listen((event) {
      print('Child added: ${event.snapshot.value}');
    });
  }

  void goOffline() {
    Geofire.removeLocation(currentFirebaseUser.uid);
    tripRequestRef.onDisconnect();
    tripRequestRef.remove();
    tripRequestRef = null;
  }

  void getLocationUpdates() {
    homeTabPositionStream = geoLocatior.getPositionStream(locationOptions).listen((Position position) {
      currentPosition = position;
    if(isAvailable)
      Geofire.setLocation(currentFirebaseUser.uid, position.latitude , position.longitude);
      LatLng pos = LatLng(position.latitude, position.longitude);
      mapController.animateCamera(CameraUpdate.newLatLng(pos));
    });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
