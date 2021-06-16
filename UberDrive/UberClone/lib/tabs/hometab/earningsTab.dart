
import 'package:UberClone/screen/historyPage.dart';
import 'package:UberClone/widget/brandDivider.dart';
import 'package:UberClone/widget/historyTile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../brand_color.dart';
import '../../dataprovider.dart';

class EarningsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Container(
          color: BrandColors.colorPrimary,
          width: double.infinity,
          child: Padding(
            padding:  EdgeInsets.symmetric(vertical: 70),
            child: Column(
              children: [

                Text('Total Earnings', style: TextStyle(color: Colors.white),),
                Text('\$${Provider.of<AppData>(context).earnings}', style: TextStyle(color: Colors.white, fontSize: 40, fontFamily: 'Brand-Bold'),)
              ],
            ),
          ),
        ),

       Padding(
            padding:  EdgeInsets.symmetric(horizontal: 30, vertical: 18),
            child: Row(
              children: [
                Image.asset('images/taxi.png', width: 70,),
                SizedBox(width: 16,),
                Text('History', style: TextStyle(fontSize: 16), ),
                Expanded(child: Container(child: Text(Provider.of<AppData>(context).tripCount.toString(), textAlign: TextAlign.end, style: TextStyle(fontSize: 18),))),
              ],
            ),
          ),

        BrandDivider(),

    ListView.separated(
      padding: EdgeInsets.all(10),
      itemBuilder: (context, index) {
        return HistoryTile(
          history: Provider.of<AppData>(context).tripHistory[index],
          );
        },
      separatorBuilder: (BuildContext context, int index) => BrandDivider(),
      itemCount: Provider.of<AppData>(context).tripHistory.length,
      physics: ClampingScrollPhysics(),
      shrinkWrap:  true,
    ),

      ],
    );
  }

}