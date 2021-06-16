
import 'dart:async';

import 'package:UberClone/datamodels/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


String serverKey = 'key=AAAAX8lFJZQ:APA91bFl8Cxik6Q7-1LE4x6epe9_vtuj23nVS5v3Qvq0bLKP4uQod6lNa6P6gAvLq1Fc5PZBolPdxBsa1iGDqKOx6Ts1_zB4BHQHqnxsM93ifzclx3wgaR6X06k-p79sWzvz3KhWNy8A';

String mapKey = 'AIzaSyDAMGWtwQBxdv0VVG1RtrXctNKaz-t8MOY';

final CameraPosition googlePlex = CameraPosition(
  target: LatLng(10, 160),
  zoom: 15,
);

StreamSubscription<Position> homeTabPositionStream;
FirebaseUser currentFirebaseUser;
User currentUserInfo;
Position currentPosition;
