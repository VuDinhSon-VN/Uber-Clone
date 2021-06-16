
import 'package:UberClone/datamodels/history.dart';
import 'package:flutter/material.dart';

class AppData extends ChangeNotifier{

  String earnings;
  int tripCount;
  List<String> tripHistoryKeys = [];
  List<History> tripHistory = [];

  void updateEarnings(String newEarnings){
    print("updateEarnings");
    earnings = newEarnings;
    print(earnings);
    notifyListeners();
  }

  void updateTripCount(int newTripCount){
    tripCount = 10;//newTripCount;
    notifyListeners();
  }

  void updateTripKeys(List<String> newKeys){
    tripHistoryKeys = newKeys;
    notifyListeners();
  }

  void updateTripHistory(History historyItem){
    tripHistory.add(historyItem);
    notifyListeners();
  }
}