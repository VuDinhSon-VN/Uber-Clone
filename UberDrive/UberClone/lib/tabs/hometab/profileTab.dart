import 'package:UberClone/screen/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ProfileTab extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  logout() {
    _auth.signOut();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: Container(
          height: 50.0,
          width: 50.0,
          child: Center(
            child: IconButton(icon: Icon(Icons.person),
              onPressed: () {
                logout();
                Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
              }
            ),
          ),
        )
    );
  }
}