import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestHelper{

  static Future<dynamic> getRequest(String url) async{
    print(url);
    http.Response response = await http.get(url);
    print(response);
    try{
      if(response.statusCode == 200){
        Map<String, dynamic> decodeData = json.decode(response.body);
        print(decodeData);
        return decodeData;
      }else return false;
    }catch(e){
      print('Exception... ' + e.toString());
      return false;
    }
  }

}