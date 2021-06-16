import 'package:UberClone/widget/taxiOutlineButton.dart';
import 'package:flutter/material.dart';

import 'brand_color.dart';

class NoDriverDialog extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
   return Dialog(
     shape: RoundedRectangleBorder(
       borderRadius: BorderRadius.circular(10),
     ),
     elevation: 0.0,
    backgroundColor: Colors.transparent,
    child: Container(
      margin: EdgeInsets.all(0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 12,),
              Text('No driver found',style: TextStyle(fontSize: 22, fontFamily: 'Brand-Bold'),),
              SizedBox(height: 12,),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text('No available driver close by, we suggest you try again shortly', textAlign: TextAlign.center,),
              ),
              SizedBox(height: 20,),
              Container(
                width: 200,
                child: TaxiOutlineButton(
                  title: 'CLOSE',
                    color: BrandColors.colorLightGrayFair,
                    onPressed: (){
                      Navigator.pop(context);
                    },
                ),
              ),
            ],
          ),
        ),
      ),
    ),


   ); 
  }



}