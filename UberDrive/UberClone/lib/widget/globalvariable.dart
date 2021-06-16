
import 'dart:async';

import 'package:UberClone/datamodels/driver.dart';
import 'package:UberClone/datamodels/user.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


String serverKey = 'key=AAAAJ3QN19w:APA91bH96FLIonxK-jMG-czfyN0Srmj-nJZVDbbJEanxy7sJ28U_OmPefkPGB4dX0UOKKqtWLAM_0dOKuCRPcB6O2bjyYMWT6e80mLbttCxYPzlRRyHUV2l8DFRQQb4WlZPaSLxXTle7';

String mapKey = 'AIzaSyDAMGWtwQBxdv0VVG1RtrXctNKaz-t8MOY';

final CameraPosition googlePlex = CameraPosition(
 target: LatLng(10.8021745, 106.6596272),
  zoom: 2,
);

StreamSubscription<Position> homeTabPositionStream;
StreamSubscription<Position> ridePositionStream;
Position currentPosition;

FirebaseUser currentFirebaseUser;

Driver currentDriverInfo;

User currentUserInfo;

DatabaseReference rideRef;

final assetsAudioPlayer = AssetsAudioPlayer();
