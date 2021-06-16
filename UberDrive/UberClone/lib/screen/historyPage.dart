import 'package:UberClone/widget/brandDivider.dart';
import 'package:UberClone/widget/historyTile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../brand_color.dart';
import '../dataprovider.dart';

class HistoryPage extends StatefulWidget{
  @override
  _HistoryPageState createState() => _HistoryPageState();
}
 class _HistoryPageState extends State<HistoryPage>{
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        padding: EdgeInsets.all(0),
        itemBuilder: (context, index) {
          return HistoryTile(
            history: Provider.of<AppData>(context).tripHistory[index],
          );
        },
        separatorBuilder: (BuildContext context, int index) => BrandDivider(),
        itemCount: Provider.of<AppData>(context).tripHistory.length,
        physics: ClampingScrollPhysics(),
        shrinkWrap:  true,
    );
  }

 }