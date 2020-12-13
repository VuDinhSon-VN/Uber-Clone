import 'package:UberClone/dataprovider/appdata.dart';
import 'package:UberClone/screen/loginpage.dart';
import 'package:UberClone/screen/mainpage.dart';
import 'package:UberClone/screen/registractionpage.dart';
import 'package:UberClone/widget/globalvariable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // final FirebaseApp app = await Firebase.initializeApp(
  //   name: 'db2',
  //   options: Platform.isIOS || Platform.isMacOS
  //       ? FirebaseOptions(
  //     appId: '1:297855924061:ios:c6de2b69b03a5be8',
  //     apiKey: 'AIzaSyD_shO5mfO9lhy2TVWhfo1VUmARKlG4suk',
  //     projectId: 'flutter-firebase-plugins',
  //     messagingSenderId: '297855924061',
  //     databaseURL: 'https://flutterfire-cd2f7.firebaseio.com',
  //   )
  //       : FirebaseOptions(
  //     appId: '1:411398645140:android:f3a07951d7f28cc5a1db81',
  //     apiKey: 'AIzaSyC_p2dZG0aJqt_khm-WwHyLobid8qmUzLk',
  //     messagingSenderId: '411398645140',
  //     projectId: 'uberclone-c7b2e',
  //     databaseURL: 'https://uberclone-c7b2e.firebaseio.com',
  //   ),
  // );
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'db2',
    options: Platform.isIOS
        ? const FirebaseOptions(
      googleAppID: '1:297855924061:ios:c6de2b69b03a5be8',
      gcmSenderID: '297855924061',
      databaseURL: 'https://flutterfire-cd2f7.firebaseio.com',
    )
        : const FirebaseOptions(
      googleAppID: '1:411398645140:android:f3a07951d7f28cc5a1db81',
      apiKey: 'AIzaSyC_p2dZG0aJqt_khm-WwHyLobid8qmUzLk',
      databaseURL: 'https://uberclone-c7b2e.firebaseio.com',
    ),
  );

  currentFirebaseUser = await FirebaseAuth.instance.currentUser();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        theme: ThemeData(
          fontFamily: 'Brand-Regular',
          primarySwatch: Colors.blue,
        ),
        initialRoute: (currentFirebaseUser == null) ? LoginPage.id : MainPage.id,
        routes: {
          RegistrationPage.id: (context) => RegistrationPage(),
          LoginPage.id: (context) => LoginPage(),
          MainPage.id : (context) => MainPage(),
        },
      ),



    );

  }
}

