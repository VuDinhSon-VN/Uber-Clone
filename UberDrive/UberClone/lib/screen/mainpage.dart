import 'package:UberClone/screen/loginpage.dart';
import 'package:UberClone/tabs/hometab/earningsTab.dart';
import 'package:UberClone/tabs/hometab/homeTab.dart';
import 'package:UberClone/tabs/hometab/profileTab.dart';
import 'package:UberClone/tabs/hometab/ratingsTab.dart';
import 'package:UberClone/widget/brand_color.dart';
import 'package:UberClone/widget/globalvariable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  static const String id = 'mainpage';
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {

  TabController tabController;
  int selecetdIndex = 0;

  void onItemClicked(int index){
    setState(() {
      selecetdIndex = index;
      tabController.index = selecetdIndex;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
          body: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: tabController,
              children: <Widget>[
                HomeTab(),
                EarningsTab(),
                RatingTab(),
                ProfileTab(),
              ],),
          bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                title: Text('Home'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.credit_card),
                title: Text('Earnings'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star),
                title: Text('Ratings'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                title: Text('Account'),
              ),
            ],
            currentIndex: selecetdIndex,
            unselectedItemColor: BrandColors.colorIcon,
            selectedItemColor: BrandColors.colorOrange,
            showUnselectedLabels: true,
            selectedLabelStyle: TextStyle(fontSize: 12),
            type: BottomNavigationBarType.fixed,
            onTap: onItemClicked,
          ),
    );

  }
}
