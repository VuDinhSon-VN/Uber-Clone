import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ProfileTab extends StatelessWidget {


   logout() {
     final FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.signOut();
     }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      width: 50.0,
      child: Center(
        child: IconButton(icon: Icon(Icons.person), onPressed: logout(),
        ),

      ),
    );


  }
}
