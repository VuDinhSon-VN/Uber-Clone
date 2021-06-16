import 'dart:async';
import 'dart:io';
import 'package:UberClone/datamodels/tripDetails.dart';
import 'package:UberClone/helper/helperMethod.dart';
import 'package:UberClone/helper/mapKitHelper.dart';
import 'package:UberClone/widget/ProgressDialog.dart';
import 'package:UberClone/widget/TaxiButton.dart';
import 'package:UberClone/widget/collectPaymentDialog.dart';
import 'package:UberClone/widget/globalvariable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../brand_color.dart';

class NewTripPage extends StatefulWidget{
  final TripDetails tripDetails;
  NewTripPage({this.tripDetails});
  
  @override
  _NewTripPageState createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage>{
  GoogleMapController rideMapController;

  Completer<GoogleMapController> _controller = Completer();
  double mapPaddingBottom = 0;

  var geoLocator = Geolocator();
  var locationOption = LocationOptions(accuracy: LocationAccuracy.bestForNavigation);
  Set<Marker> _markers = Set<Marker>();
  Set<Circle> _circles = Set<Circle>();
  Set<Polyline> _polyLines = Set<Polyline>();

  BitmapDescriptor movingMarkerIcon;
  String durationString = '';
  bool isRequestingDirection = false;
  Position myPosition;
  Timer timer;
  int durationCounter = 0;

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String status = 'accepted';
  String buttonTitle = 'ARRIVED';
  Color buttonColor = BrandColors.colorGreen;
  @override
  void initState() {
    print('DEBUG INITSTATE');
    super.initState();
    acceptTrip();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(body: Stack(
      children: <Widget>[
        GoogleMap(
          padding: EdgeInsets.only(top: 30),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          compassEnabled: true,
          mapToolbarEnabled: true,
          trafficEnabled: true,
          mapType: MapType.normal,
          circles: _circles,
          markers: _markers,
          polylines: _polyLines,
          initialCameraPosition: googlePlex,
          onMapCreated: (GoogleMapController controller) async {
            _controller.complete(controller);
            rideMapController = controller;
            setState(() {
              mapPaddingBottom = (Platform.isIOS) ? 255 : 260;
            });
            var currentLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);
            var pickupLatLng = widget.tripDetails.pickup;
            await getDirection(currentLatLng, pickupLatLng);
            getLocationUpdates();
        },
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 15.0,
                  spreadRadius: 0.5,
                  offset: Offset(
                    0.7,
                    0.7,
                  ),
                )
              ],
            ),
            height: Platform.isIOS ? 280 : 280,
            child: Padding(
              padding:  EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    durationString,
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Brand-Bold',
                        color: BrandColors.colorAccentPurple
                    ),
                  ),

                  SizedBox(height: 5,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(child: Text(widget.tripDetails.riderName, style: TextStyle(fontSize: 22, fontFamily: 'Brand-Bold'),)),

                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(Icons.call),
                      ),

                    ],
                  ),

                  SizedBox(height:  25,),

                  Row(
                    children: <Widget>[
                      Image.asset('images/pickicon.png', height: 16, width: 16,),
                      SizedBox(width: 18,),

                      Expanded(
                        child: Container(
                          child: Text(
                            widget.tripDetails.pickupAddress,
                            style: TextStyle(fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                    ],
                  ),

                  SizedBox(height: 15,),

                  Row(
                    children: <Widget>[
                      Image.asset('images/desticon.png', height: 16, width: 16,),
                      SizedBox(width: 18,),

                      Expanded(
                        child: Container(
                          child: Text(
                            widget.tripDetails.destinationAddress,
                            style: TextStyle(fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                    ],
                  ),


                  SizedBox(height: 25,),

                  TaxiButton(
                    title: buttonTitle,
                    color: buttonColor,
                    onPressed: () async {

                      if(status == 'accepted'){

                        status = 'arrived';
                        rideRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/status');
                        rideRef.set(status);

                        setState(() {
                          buttonTitle = 'START TRIP';
                          buttonColor = BrandColors.colorAccentPurple;
                        });
                        endTrip();
                        HelperMethod.showProgressDialog(context);

                        await getDirection(widget.tripDetails.pickup, widget.tripDetails.destination);

                        Navigator.pop(context);

                      }
                      else if(status == 'arrived'){
                        status = 'onTrip';
                        rideRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/status');
                        rideRef.set(status);

                        setState(() {
                          buttonTitle = 'END TRIP';
                          buttonColor = Colors.red[900];
                        });

                        startTimer();
                      }
                      else if(status == 'ontrip'){
                        endTrip();
                      }

                    },
                  )

                ],
              ),
            ),
          ),
        )
      ],
    ),
 );
    
  }

  void acceptTrip(){
    print('DEBUG ACCEPTTRIP');
    String rideID = widget.tripDetails.riderID;
    rideRef = FirebaseDatabase.instance.reference().child('rideRequest/$rideID');

    rideRef.child('status').set('accepted');
    rideRef.child('driver_name').set(currentDriverInfo.fullName);
    rideRef.child('car_details').set('${currentDriverInfo.carColor} - ${currentDriverInfo.carModel}');
    rideRef.child('driver_phone').set(currentDriverInfo.phone);
    rideRef.child('driver_id').set(currentDriverInfo.id);

    Map locationMap = {
      'latitude': currentPosition.latitude.toString(),
      'longitude': currentPosition.longitude.toString(),
    };

    rideRef.child('driver_location').set(locationMap);

    DatabaseReference historyRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/history/$rideID');
    historyRef.set(true);

  }

  void getLocationUpdates(){
    print('DEBUG GETLOCATIONUPDATES');
    LatLng oldPosition = LatLng(0, 0);

    ridePositionStream = geoLocator.getPositionStream(locationOption).listen((Position position) {
      myPosition = position;
      currentPosition = position;
      LatLng pos = LatLng(position.latitude, position.longitude);
      var rotation = MapKitHelper.getMarkerRotation(oldPosition.latitude, oldPosition.longitude, pos.latitude, pos.longitude);

      print('my rotation = $rotation');

      Marker movingMaker = Marker(markerId: MarkerId('moving'),
        position: pos,
        icon: movingMarkerIcon,
        rotation: rotation,
        infoWindow: InfoWindow(title: 'Current Location'),
      );
      setState(() {
        CameraPosition cp = new CameraPosition(target: pos, zoom: 17);
        rideMapController.animateCamera(CameraUpdate.newCameraPosition(cp));

        _markers.removeWhere((marker) => marker.markerId.value == 'moving');
        _markers.add(movingMaker);
      });

      oldPosition = pos;
      updateTripDetails();

      Map locationMap = {
        'latitude': myPosition.latitude.toString(),
        'longitude': myPosition.longitude.toString(),
      };
      String rideID = widget.tripDetails.riderID;
      rideRef = FirebaseDatabase.instance.reference().child('rideRequest/$rideID/driver_location');
      rideRef.set(locationMap);
    }) ;
  }

  void getDirection(LatLng pickupLatLng, LatLng destinationLatLng) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(status: 'Please wait...',)
    );

    var thisDetails = await HelperMethod.getDirectionDetails(pickupLatLng,destinationLatLng);

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results = polylinePoints.decodePolyline(thisDetails.encodedPoints);
    polylineCoordinates.clear();

    if(results.isNotEmpty){
      // loop through all PointLatLng points and convert them
      // to a list of LatLng, required by the Polyline
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _polyLines.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),
        color: Color.fromARGB(255, 95, 109, 237),
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      _polyLines.add(polyline);

    });

    // make polyline to fit into the map
    LatLngBounds bounds;
    if(pickupLatLng.latitude > destinationLatLng.latitude && pickupLatLng.longitude > destinationLatLng.longitude){
      bounds = LatLngBounds(southwest: destinationLatLng, northeast: pickupLatLng);
    }
    else if(pickupLatLng.longitude > destinationLatLng.longitude){
      bounds = LatLngBounds(
          southwest: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, pickupLatLng.longitude)
      );
    }
    else if(pickupLatLng.latitude > destinationLatLng.latitude){
      bounds = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, pickupLatLng.longitude),
        northeast: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),
      );
    }
    else{
      bounds = LatLngBounds(southwest: pickupLatLng, northeast: destinationLatLng);
    }

    rideMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickupLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      _markers.add(pickupMarker);
      _markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
      circleId: CircleId('pickup'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 12,
      center: pickupLatLng,
      fillColor: BrandColors.colorGreen,
    );
    Circle destinationCircle = Circle(
      circleId: CircleId('destination'),
      strokeColor: BrandColors.colorAccentPurple,
      strokeWidth: 3,
      radius: 12,
      center: destinationLatLng,
      fillColor: BrandColors.colorAccentPurple,
    );

    setState(() {
      _circles.add(pickupCircle);
      _circles.add(destinationCircle);
    });
  }

  void updateTripDetails() async {
    print('DEBUG UPDATETRIPDETAILS');
    if(!isRequestingDirection){
      isRequestingDirection = true;
      if(myPosition == null) return null;

      var positionLatLng = LatLng(myPosition.latitude, myPosition.longitude);
      LatLng destinationLatLng;

      if(status == 'accepted'){
        destinationLatLng = widget.tripDetails.pickup;
      }else{
        destinationLatLng = widget.tripDetails.destination;
      }

      var directionDetails = await HelperMethod.getDirectionDetails(positionLatLng, destinationLatLng);

      if(directionDetails != null){
        print(directionDetails.durationText);
        setState(() {
          durationString = directionDetails.durationText;
        });
      }
      isRequestingDirection = false;
    }
  }

  void startTimer(){
    print('DEBUG STARTTIMER');
    const interval = Duration(seconds: 1);
    timer = Timer.periodic(interval, (timer) {
      durationCounter++;
    });
  }

  void endTrip() async {
    print('DEBUG ENDTRIP');
   // timer.cancel();

    HelperMethod.showProgressDialog(context);

    var currentLatLng = LatLng(myPosition.latitude, myPosition.longitude);

    var directionDetails = await HelperMethod.getDirectionDetails(widget.tripDetails.pickup, currentLatLng);

    Navigator.pop(context);

    int fares = HelperMethod.estimateFares(directionDetails, durationCounter);
    print("fare: $fares");
    rideRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/fares');
    rideRef.set(fares.toString());

    rideRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/status');
    rideRef.set('ended');

    ridePositionStream.cancel();

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CollectPayment(
          paymentMethod: widget.tripDetails.paymentMethod,
          fares: fares,
        )
    );

    topUpEarnings(fares);
  }

  void topUpEarnings(int fares) {
    print('DEBUG TOPUPEARNINGS');
    DatabaseReference earningsRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/earnings');
    earningsRef.once().then((DataSnapshot snapshot) {

      if(snapshot.value != null){

        double oldEarnings = double.parse(snapshot.value.toString());

        double adjustedEarnings = (fares.toDouble() * 0.85) + oldEarnings;

        earningsRef.set(adjustedEarnings.toStringAsFixed(2));
      }
      else{
        double adjustedEarnings = (fares.toDouble() * 0.85);
        earningsRef.set(adjustedEarnings.toStringAsFixed(2));
      }

    });
  }

  void getCurrentPosition() async {
    var geoLocatior = Geolocator();
    print('newTripPage SETUPCURRENTPOSITION');
    Position position = await geoLocatior.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;

    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom: 15);
    rideMapController.animateCamera(CameraUpdate.newCameraPosition(cp));
  }
}