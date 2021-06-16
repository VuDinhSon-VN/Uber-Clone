import 'dart:async';
import 'dart:io';
import 'package:UberClone/datamodels/directiondetails.dart';
import 'package:UberClone/datamodels/nearbydriver.dart';
import 'package:UberClone/dataprovider/appdata.dart';
import 'package:UberClone/helpers/fireHelper.dart';
import 'package:UberClone/helpers/helpermethods.dart';
import 'package:UberClone/screen/searchpage.dart';
import 'package:UberClone/styles/styles.dart';
import 'package:UberClone/widget/BrandDivider.dart';
import 'package:UberClone/widget/ProgressDialog.dart';
import 'package:UberClone/widget/TaxiButton.dart';
import 'package:UberClone/widget/brand_color.dart';
import 'package:UberClone/widget/globalvariable.dart';
import 'package:UberClone/widget/noDriverDialog.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

import '../rideVariable.dart';

class MainPage extends StatefulWidget {
  static const String id = 'mainpage';
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {

  @override
  void initState() { 
    super.initState();
    HelperMethods.getCurrentUserInfo();
  }

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  double searchSheetHeight = (Platform.isIOS) ? 300 : 275;
  double rideDetailsSheetHeight = 0; // (Platform.isAndroid) ? 235 : 260
  double requestingSheetHeight = 0; // (Platform.isAndroid) ? 195 : 220
  double tripSheetHeight = 0;     // (Platform.isAndroid) ? 275 : 300

  bool drawerCanOpen = true;


  Position _currentPosition;
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _Markers = {};
  Set<Circle> _Circles = {};

  BitmapDescriptor nearbyIcon;

  String appState = 'NORMAL';
  DatabaseReference rideRef;
  List<NearbyDriver> availableDrivers;
  bool nearbyDriversKeysLoaded = false;

  GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();
  DatabaseReference tripRequestRef;
    DirectionDetails tripDirectionDetails;


  double mapBottomPadding = 0;

  void showDetailSheet() async {
      await getDirection();
      setState(() {
        searchSheetHeight = 0;
        mapBottomPadding = (Platform.isAndroid) ? 280 : 230;
        rideDetailsSheetHeight = (Platform.isAndroid) ? 280 : 260;
        drawerCanOpen = false;
      });

    }
  void showRequestingSheet() {
    setState(() {
      rideDetailsSheetHeight = 0;
      requestingSheetHeight = (Platform.isAndroid) ? 195 : 220;
      mapBottomPadding = (Platform.isAndroid) ? 200 : 190;
      drawerCanOpen = false;
    });

    createRideRequest();
  }

  @override
  Widget build(BuildContext context) {


    return new Scaffold(
      key: scaffoldKey,
      drawer: Container(
        width: 280,
        color: Colors.white,
        child: Drawer(
            child:ListView(
            //padding: EdgeInsets.all(0),
            children: <Widget>[
              Container(
                color: Colors.white,
                height: 160,
                child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Row(
                      children: <Widget>[
                        Image.asset(
                          'images/user_icon.png', height: 60, width: 60,),
                        SizedBox(width: 15),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('Naruto', style: TextStyle(
                                fontSize: 20, fontFamily: 'Brand-Bold'),),
                            SizedBox(height: 5,),
                            Text('View Profile'),
                          ],
                        )
                      ],
                    )
                ),
              ),
              BrandDivider(),

              SizedBox(height: 10,),
              
              ListTile(
                leading: Icon(OMIcons.person),
                title: Text('Profile', style: kDrawerItemStyle,),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(OMIcons.cardGiftcard),
                title: Text('Free Rides', style: kDrawerItemStyle,),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(OMIcons.creditCard),
                title: Text('Payment', style: kDrawerItemStyle,),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(OMIcons.history),
                title: Text('History', style: kDrawerItemStyle,),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(OMIcons.contactSupport),
                title: Text('Support', style: kDrawerItemStyle,),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(OMIcons.settings),
                title: Text('Setting', style: kDrawerItemStyle,),
                onTap: () {},
              ),
              ListTile(
                  leading: Icon(OMIcons.info),
                  title: Text('About', style: kDrawerItemStyle,),
                  onTap: () {},
              ),
              ],
            ),
          ),
        ),

      body: Stack(
          children: <Widget>[
            //google Map
            GoogleMap(
              //padding: EdgeInsets.only(top: mapBottomPadding),
              padding: EdgeInsets.fromLTRB(0,40, 0, mapBottomPadding),
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              initialCameraPosition: googlePlex,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              polylines: _polylines,
              markers: _Markers,
              circles: _Circles,
              onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;
              setState(() {
                mapBottomPadding = (Platform.isAndroid) ? 280 : 270 ;
              });
              setupPositionLocator();
            },
          ),
           
            //MenuButton
            Positioned(
                top: 40,
                left: 20,
                child: GestureDetector(
                  onTap: (){
                    if(drawerCanOpen){
                      scaffoldKey.currentState.openDrawer();
                    }else
                      {
                        print('reset App');
                        resetApp();
                      }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7),
                        )
                      ]
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                      child: Icon((drawerCanOpen) ? Icons.menu : Icons.arrow_back, color: Colors.black87,),
                    ),
                  ),
                ),
            ),
           
            //SearchSheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                vsync: this,
                duration: const Duration(seconds: 1),
                curve: Curves.easeIn,
                child: Container(
                  height: searchSheetHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        spreadRadius: 0.5,
                        offset: Offset(
                          0.7,  0.7,
                        )
                      )]),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 5,),
                        Text('Nice to see you!', style: TextStyle(fontSize: 10),),
                        Text('Where are you going?', style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),),

                        SizedBox(height: 20,),

                        GestureDetector(
                          onTap: () async {
                            var response = await Navigator.push(context, MaterialPageRoute(
                              builder: (context) => SearchPage()
                            ));
                            print(response);
                            if(response == 'getDirection'){
                             showDetailSheet();
                             getDirection();
                            }

                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5.0,
                                      spreadRadius: 0.5,
                                      offset: Offset(
                                        0.7,
                                        0.7,
                                      )
                                  )
                                ]
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.search, color: Colors.blueAccent,),
                                  SizedBox(width: 10,),
                                  Text('Search Destination'),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 22,),

                        Row(
                          children: <Widget>[
                            Icon(OMIcons.home, color: BrandColors.colorDimText,),
                            SizedBox(width: 12,),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text( (Provider.of<AppData>(context).pickupAddress != null) ? Provider.of<AppData>(context).pickupAddress.placeName : 'Add Home', overflow: TextOverflow.ellipsis,),
                                  SizedBox(height: 3,),
                                  Text('Your residential address',
                                    style: TextStyle(fontSize: 11, color: BrandColors.colorDimText,),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),

                        SizedBox(height: 10,),

                        BrandDivider(),

                        SizedBox(height: 10,),

                        Row(
                          children: <Widget>[
                            Icon(OMIcons.workOutline, color: BrandColors.colorDimText,),
                            SizedBox(width: 12,),
                            
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(Provider.of<AppData>(context).destinationAddress != null ? Provider.of<AppData>(context).destinationAddress.placeName : 'Add Work', overflow: TextOverflow.ellipsis,),
                                  SizedBox(height: 3,),
                                  Text('Your office address',
                                    style: TextStyle(fontSize: 11, color: BrandColors.colorDimText,),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),

                      ],
                    ),
                  ),

                ),
              )
            ),
           
            // RideDetails Sheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                vsync: this,
                duration: new Duration(milliseconds: 150),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15.0, // soften the shadow
                        spreadRadius: 0.5, //extend the shadow
                        offset: Offset(
                          0.7, // Move to right 10  horizontally
                          0.7, // Move to bottom 10 Vertically
                        ),
                      )
                    ],

                  ),
                  height: rideDetailsSheetHeight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Column(
                      children: <Widget>[

                        Container(
                          width: double.infinity,
                          color: BrandColors.colorAccent1,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: <Widget>[
                                Image.asset('images/taxi.png', height: 70, width: 70,),
                                SizedBox(width: 16,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('Taxi', style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),),
                                    Text((tripDirectionDetails != null) ? tripDirectionDetails.distanceText : '', style: TextStyle(fontSize: 16, color: BrandColors.colorTextLight),)

                                  ],
                                ),
                                Expanded(child: Container()),
                                Text((tripDirectionDetails != null) ? '\$${HelperMethods.estimateFares(tripDirectionDetails)}' : '', style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),),

                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 22,),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: <Widget>[

                              Icon(FontAwesomeIcons.moneyBillAlt, size: 18, color: BrandColors.colorTextLight,),
                              SizedBox(width: 16,),
                              Text('Cash'),
                              SizedBox(width: 5,),
                              Icon(Icons.keyboard_arrow_down, color: BrandColors.colorTextLight, size: 16,),
                            ],
                          ),
                        ),

                        SizedBox(height: 22,),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: TaxiButton(
                            title: 'REQUEST CAB',
                            color: BrandColors.colorGreen,
                            onPressed: (){

                              setState(() {
                                appState = 'REQUESTING';
                              });
                              showRequestingSheet();

                              availableDrivers = FireHelper.nearbyDriverList;

                             findDriver();
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
           
            //request sheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                vsync: this,
                duration: new Duration(milliseconds: 150),
                curve: Curves.easeIn,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15.0, // soften the shadow
                        spreadRadius: 0.5, //extend the shadow
                        offset: Offset(
                          0.7, // Move to right 10  horizontally
                          0.7, // Move to bottom 10 Vertically
                        ),
                      )
                    ],
                  ),
                  height: requestingSheetHeight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[

                        SizedBox(height: 10,),

                        SizedBox(
                          width: double.infinity,
                          child: TextLiquidFill(
                            text: 'Requesting a Ride...',
                            waveColor: BrandColors.colorTextSemiLight,
                            boxBackgroundColor: Colors.white,
                            textStyle: TextStyle(
                                color: BrandColors.colorText,
                                fontSize: 22.0,
                                fontFamily: 'Brand-Bold'
                            ),
                            boxHeight: 40.0,
                          ),
                        ),

                        SizedBox(height: 20,),

                        GestureDetector(
                          onTap: (){
                            cancelRequest();
                            resetApp();
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(width: 1.0, color: BrandColors.colorLightGrayFair),

                            ),
                            child: Icon(Icons.close, size: 25,),
                          ),
                        ),

                        SizedBox(height: 10,),

                        Container(
                          width: double.infinity,
                          child: Text(
                        'Cancel ride',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                        ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ]),

    );
  }
  var geoLocatior = Geolocator();

  void resetApp() {
    setState(() {
      polylineCoordinates.clear();
      _polylines.clear();
      _Markers.clear();
      _Circles.clear();
      requestingSheetHeight = 0;
      rideDetailsSheetHeight = 0;
      tripSheetHeight = 0;
      searchSheetHeight = (Platform.isAndroid) ? 275 : 300;
      mapBottomPadding = (Platform.isAndroid) ? 280 : 270;
      drawerCanOpen = true;

      // status = '';
      // driverFullName = '';
      // driverPhoneNumber = '';
      // driverCarDetails = '';
      // tripStatusDisplay = 'Driver is Arriving';
    });
    setupPositionLocator();
  }

  void setupPositionLocator() async{
    createMarker();
    print('setupPositionLocator');
    Position position = await geoLocatior.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;

    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom: 15);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));

    //confirm location
    await HelperMethods.findCordinateAddress(position, context);

    startGeofireListener();
  }

  void startGeofireListener() {
    print('START GEOFIRE LISTENER');
    Geofire.initialize('driversAvailable');
    Geofire.queryAtLocation(currentPosition.latitude, currentPosition.longitude, 20).listen((map){
      print("MAP: $map");
      if (map != null) {
        var callBack = map['callBack'];

        switch (callBack) {
          case Geofire.onKeyEntered:
            print('Into onKeyEntered');
            NearbyDriver nearbyDriver = NearbyDriver();
            nearbyDriver.key = map['key'];
            nearbyDriver.latitude = map['latitude'];
            nearbyDriver.longitude = map['longitude'];
            FireHelper.nearbyDriverList.add(nearbyDriver);

            if(nearbyDriversKeysLoaded){
              updateDriversOnMap();
            }
            break;

          case Geofire.onKeyExited:
            print('Into onKeyExited');
            FireHelper.removeFromList(map['key']);
            updateDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            print('Into onKeyMoved');
          // Update your key's location

            NearbyDriver nearbyDriver = NearbyDriver();
            nearbyDriver.key = map['key'];
            nearbyDriver.latitude = map['latitude'];
            nearbyDriver.longitude = map['longitude'];

            FireHelper.updateNearbyLocation(nearbyDriver);
            updateDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:
            print('Into onGeoQueryReady');
            nearbyDriversKeysLoaded = true;
            updateDriversOnMap();
            break;
        }
      }
    });
  }

 void updateDriversOnMap(){
    print('UPDATE DRIVER ON MAP');
   setState(() {
     _Markers.clear();
   });
    Set<Marker> tempMarker = Set<Marker>();

      print(" length of driver: ${FireHelper.nearbyDriverList.length}");
      for(NearbyDriver driver in FireHelper.nearbyDriverList){
        LatLng driverPosition = LatLng(driver.latitude, driver.longitude);
        Marker thisMarker = Marker(
          markerId: MarkerId('driver/${driver.key}'),
          position: driverPosition,
          icon: nearbyIcon,
          rotation: HelperMethods.generateRandomNumber(360),
          );
        print("this Marker: $thisMarker");
        tempMarker.add(thisMarker);
      }
      setState(() {
        _Markers = tempMarker;
      });

  }

  Future<dynamic> getDirection() async {
    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    print('PICKUP');
    print(pickup.latitude);
    print(pickup.longitude);
    var destination = Provider.of<AppData>(context, listen: false).destinationAddress;
    print('destination');
    print(destination.latitude);
    print(destination.longitude);

    var pickLatLng = LatLng(pickup.latitude, pickup.longitude);
    print(pickLatLng);
    var destinationLatLng = LatLng(destination.latitude, destination.longitude);
    print(destinationLatLng);

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(status: 'Please wait...',)
    );

    var thisDetails = await HelperMethods.getDirectionDetails(pickLatLng, destinationLatLng);

    setState(() {
      tripDirectionDetails = thisDetails;
    });
    print(thisDetails.encodedPoints);
    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results = polylinePoints.decodePolyline(thisDetails.encodedPoints);
    print(results);
    polylineCoordinates.clear();
    if(results.isNotEmpty){
      //loop through all PointLatLng points and convert them
      //to a list of LatLng, required by the Polyline.
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      _polylines.clear();
      setState(() {
        Polyline polyline = Polyline(
          polylineId: PolylineId('polyid'),
          color: Color.fromARGB(255, 95, 109, 237),
          points: polylineCoordinates,
          jointType: JointType.round,
          width: 4,
          startCap: Cap.roundCap,
          geodesic: true,
          visible: true,
        );
        _polylines.add(polyline);
      });

      // make polyline to fit into the map
      LatLngBounds bounds;
      if(pickLatLng.latitude > destinationLatLng.latitude && pickLatLng.longitude > destinationLatLng.longitude){
        bounds = LatLngBounds(southwest: destinationLatLng, northeast: pickLatLng);
      }
      else if(pickLatLng.longitude > destinationLatLng.longitude){
        bounds = LatLngBounds(
            southwest: LatLng(pickLatLng.latitude, destinationLatLng.longitude),
            northeast: LatLng(destinationLatLng.latitude, pickLatLng.longitude));
      }
      else if(pickLatLng.latitude > destinationLatLng.latitude){
        bounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, pickLatLng.longitude),
          northeast: LatLng(pickLatLng.latitude, destinationLatLng.longitude),
        );
      }
      else{
        bounds = LatLngBounds(southwest: pickLatLng, northeast: destinationLatLng);
      }

      mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));

      Marker pickupMarker = Marker(
        markerId: MarkerId('pickup'),
        position: pickLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(title: pickup.placeName, snippet: 'My Location'),
      );

      Marker destinationMarker = Marker(
        markerId: MarkerId('destination'),
        position: destinationLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: destination.placeName, snippet: 'Destination'),
      );

      setState(() {
        _Markers.add(pickupMarker);
        _Markers.add(destinationMarker);
      });

      Circle pickupCircle = Circle(
        circleId: CircleId('pickup'),
        strokeColor: Colors.green,
        strokeWidth: 3,
        radius: 2,
        center: pickLatLng,
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
        _Circles.add(pickupCircle);
        _Circles.add(destinationCircle);
      });
    }
  }

  void findDriver(){
    if(availableDrivers.length == 0){
      cancelRequest();
      resetApp();
      noDriverFound();
    }
    var driver = availableDrivers[0];
    notifyDriver(driver);
    availableDrivers.removeAt(0);

    print(driver.key);
  }
  
  void cancelRequest(){
    print('cancelRequest');
    rideRef.remove();
    setState(() {
      appState = 'NORMAL';
    });
  }
  
  void noDriverFound(){
    showDialog(
        context: context,
      barrierDismissible: false,
        builder: (BuildContext context) => NoDriverDialog()
    );
  }

 void createRideRequest(){
   rideRef = FirebaseDatabase.instance.reference().child('rideRequest').push();

   var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
   var destination = Provider.of<AppData>(context, listen: false).destinationAddress;

  Map pickupMap = {
    'latitude': pickup.latitude.toString(),
    'longitude': pickup.longitude.toString()
  };

  Map destinationMap = {
    'latitude': destination.latitude.toString(),
    'longitude': destination.longitude.toString()
  };

  Map rideMap = {
    'created_ad':DateTime.now().toString(),
    'rideName': currentUserInfo.fullName,
    'rider_phone': currentUserInfo.phone,
    'pickup_address' : pickup.placeName,
    'destination_address': destination.placeName,
    'location': pickupMap,
    'destination': destinationMap,
    'payment_method': 'card',
    'driver_id': 'waiting',
  };
  rideRef.set(rideMap);


 }

 void createMarker(){
     if(nearbyIcon == null){
       ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: Size(2,2));
       BitmapDescriptor.fromAssetImage(imageConfiguration, (Platform.isIOS) 
           ? 'images/car_ios.png' 
           : 'images/car_android.png'
       ).then((icon) => nearbyIcon = icon);
     }
 }

  void notifyDriver(NearbyDriver driver) {
    DatabaseReference driverTripRef = FirebaseDatabase.instance.reference().child('drivers/${driver.key}/newTrip');
    driverTripRef.set(rideRef.key);
    // Get and notify driver using token
    DatabaseReference tokenRef = FirebaseDatabase.instance.reference().child('drivers/${driver.key}/token');

    tokenRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        String token = snapshot.value.toString();

        // send notification to selected driver
        HelperMethods.sendNotification(token, context, rideRef.key);
      }
      else {
        return;
      }
    });

    const oneSecTick = Duration(seconds: 1);
  }
}

