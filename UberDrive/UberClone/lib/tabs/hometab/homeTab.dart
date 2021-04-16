import 'dart:async';
import 'package:UberClone/widget/brand_color.dart';
import 'package:UberClone/widget/globalvariable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTab extends StatefulWidget{
  @override
  _HomeTabState createState() => _HomeTabState();
  }

  class _HomeTabState extends State<HomeTab>{

    GoogleMapController mapController;
    Completer<GoogleMapController> _controller = Completer();
    DatabaseReference tripRequestRef;

    var geoLocatior = Geolocator();
    var locationOptions = LocationOptions(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 4);
    String availabilityTitle = "Go Online";
    Color availabilityColor = BrandColors.colorOrange;

    bool isAvailable = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
            padding: EdgeInsets.only(top: 135),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            initialCameraPosition: googlePlcex,
            onMapCreated: (GoogleMapController controller){
              _controller.complete(controller);
              mapController = controller;
              getCurrentPosition();
            },
        ),
      ],
    );

  }

  }
