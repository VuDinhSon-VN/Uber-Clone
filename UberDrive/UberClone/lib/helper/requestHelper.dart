import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RequestHelper{

  static Future<dynamic> getRequest(String url) async{
    print("url: $url");
    http.Response response = await http.get(url);
    print("response: $response");
    try{
      if(response.statusCode == 200){
        String data =response.body;
        var decodedData = jsonDecode(data);
        print("decodedData: $decodedData");
        return decodedData;
      }
      else return false;
    }catch(e){
      print(e.toString());
      return;
    }
  }


}