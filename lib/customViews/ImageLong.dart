import 'dart:io';

import 'package:flutter/material.dart';
import 'package:soccermgt/EventsObject.dart';

import '../constants.dart';
import '../utilities.dart';

class ImageLongWidget extends StatelessWidget {

  EventsObject _eventsObject;
  Function onFormatSelected;
  bool isFromNetwork;
  bool isFantasy;
  Function deleteItemFunc;

  ImageLongWidget(this._eventsObject,{this.onFormatSelected, this.deleteItemFunc, this.isFromNetwork=false, this.isFantasy=false});

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
            if(isFromNetwork)
              Image.network(kImageUrlStart+_eventsObject.imageUrl, fit: BoxFit.cover, width: double.infinity, height: kWidgetWidth*1.5,)
            else
              if(_eventsObject.imageUrl!=null)Image.file(File(_eventsObject.imageUrl??""), fit: BoxFit.cover, width: kWidgetWidth, height: kWidgetWidth*1.5,)
              else Image.asset('images/footim.jpg', fit: BoxFit.cover, width: kWidgetWidth, height: kWidgetWidth*1.5,),
            if(isFromNetwork)
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
