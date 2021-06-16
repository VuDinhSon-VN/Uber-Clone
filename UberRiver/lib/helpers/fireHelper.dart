import 'dart:ui';

import 'package:UberClone/datamodels/nearbydriver.dart';

class FireHelper{

  static List<NearbyDriver> nearbyDriverList = [];


  static void removeFromList(String key){
    print('removeFromList');

    int index = nearbyDriverList.indexWhere((element) => element.key == key);
    print(index);
    if(nearbyDriverList.length > 0){
      nearbyDriverList.removeAt(index);
    }
  }

  static void updateNearbyLocation(NearbyDriver nearbyDriver){
    print('updateNearByLocation');
    int index = nearbyDriverList.indexWhere((element) => element.key == nearbyDriver.key);

    nearbyDriverList[index].latitude = nearbyDriver.latitude;
    nearbyDriverList[index].longitude = nearbyDriver.longitude;
    print(nearbyDriverList[index].latitude);
    print(nearbyDriverList[index].longitude);
  }


}