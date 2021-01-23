import 'package:flutter/material.dart';

import '../constants.dart';
import '../utilities.dart';

class FantasyView extends StatelessWidget {
  String _eventsObject;
  Function onFormatSelected;
  bool isFromNetwork;
  bool isFantasy;
  Function deleteItemFunc;

  FantasyView(this._eventsObject,{this.onFormatSelected, this.deleteItemFunc, this.isFromNetwork=false,});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onFormatSelected??(){},
      child: Container(
        height: kWidgetWidth*1.5+(isFromNetwork?50:0),
        color: Colors.white,
        margin: EdgeInsets.all(3),
        width: kWidgetWidth,
        child: Column(
          children: [
              Image.network(kImageUrlStart+_eventsObject.split('<')[0].trim(), fit: BoxFit.cover, width: double.infinity, height: kWidgetWidth*1.5,),
              FlatButton(
                onPressed: deleteItemFunc??(){},
                child: Row(
                  children: [
                    Icon(Icons.clear, color: Colors.red,),
                    Text('Delete Event', style: TextStyle(color: Colors.red),)
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
