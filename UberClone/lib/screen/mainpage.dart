import 'package:UberClone/screen/loginpage.dart';
import 'package:UberClone/widget/globalvariable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  static const String id = 'mainpage';
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin{

  GlobalKey<ScaffoldState> scaffoldKey = new Global<ScaffoldState>();

  @override
  Widget build(BuildContext context) {

    createMarker();

    return Scaffold(
      key: scaffoldKey,
      drawer: container
    );
  }
}
