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
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'db2',
    options: Platform.isIOS
        ? const FirebaseOptions(
      googleAppID: '1:297855924061:ios:c6de2b69b03a5be8',
      gcmSenderID: '297855924061',
      databaseURL: 'https://flutterfire-.firebaseio.com',
    )
        : const FirebaseOptions(
      googleAppID: '1:411398645140:android:f3a07951d7f28cc5a1db81',
      apiKey: 'AIzaSyDAMGWtwQBxdv0VVG1RtrXctNKaz-t8MOY',
      databaseURL: 'https://uberclone-.firebaseio.com',
    ),
  );

  currentFirebaseUser = await FirebaseAuth.instance.currentUser();
  print('Platform ' + Platform.operatingSystem);
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
          MainPage.id : (context) => MainPage(),
          RegistrationPage.id: (context) => RegistrationPage(),
          LoginPage.id: (context) => LoginPage(),
        },
      ),



    );

  }
}

