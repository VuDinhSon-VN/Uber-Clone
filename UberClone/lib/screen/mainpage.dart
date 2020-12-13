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

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page'),
      ),
      body: MaterialButton(
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
        },
        height: 50,
        minWidth: 300,
        color: Colors.blue,

        child: Text('Test Connection'),
      ),
    );
  }
}
