import 'package:UberClone/datamodels/address.dart';
import 'package:UberClone/datamodels/prediction.dart';
import 'package:UberClone/dataprovider/appdata.dart';
import 'package:UberClone/helpers/requestHelper.dart';
import 'package:UberClone/widget/brand_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'ProgressDialog.dart';
import 'globalvariable.dart';

class PredictionTile extends StatelessWidget{

  final Prediction prediction;
  PredictionTile({this.prediction});

  void getPlaceDetails(String placeID, context) async {

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(status: 'Please wait...',)
    );

    String url = 'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeID&key=$mapKey';
    var response = await RequestHelper.getRequest(url);

    Navigator.pop(context);

    if(response == 'failed'){
      return;
    }
    if(response['status'] == 'OK'){
      Address address = Address();
      address.placeName = response['result']['name'];
      address.placeID = placeID;
      address.latitude = response['result']['geometry']['location']['lat'];
      address.longitude = response['result']['geometry']['location']['lng'];
      address.placeFormattedAddress = response['result']['formatted_address'];

      Provider.of<AppData>(context, listen: false).updateDestinationAddress(address);
      print(address.placeName);

      Navigator.pop(context, 'getDirection');
    }

  }


  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: (){
        getPlaceDetails(prediction.placeID, context);
      },
     padding: EdgeInsets.all(0),
     child: Container(
       child: Column(
         children: [
           Row(
             children: <Widget>[
               Icon(OMIcons.locationOn, color: BrandColors.colorDimText,),
               SizedBox(width: 12,),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: <Widget>[
                     Text(prediction.mainText, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16),),
                     SizedBox(height: 2,),
                     Text(prediction.secondaryText, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: BrandColors.colorDimText),),
                   ],
                 ),
               ),
             ],
           ),
         ],
       ),
     ),
    );
  }

}