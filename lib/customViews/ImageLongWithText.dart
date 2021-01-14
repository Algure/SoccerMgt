import 'dart:io';

import 'package:flutter/material.dart';
import 'package:soccermgt/EventsObject.dart';

import '../constants.dart';
import '../utilities.dart';

class ImageLongWithTextWidget extends StatelessWidget {

  EventsObject _eventsObject;

  var onFormatSelected;

  bool isFromNetwork;

  Function deleteItemFunc;

  ImageLongWithTextWidget(this._eventsObject,{this.onFormatSelected, this.deleteItemFunc, this.isFromNetwork=false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:onFormatSelected??(){} ,
      child: Container(
        height: kWidgetWidth*1.5+(isFromNetwork?50:0),
        color: Colors.white,
        width: kWidgetWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(_eventsObject.title==null||_eventsObject.title.isEmpty?"Title goes here":_eventsObject.title, style:kTitleStyle),
            ),
            SizedBox(height: 10),
            if(isFromNetwork)
              Image.network(kImageUrlStart+_eventsObject.imageUrl, fit: BoxFit.cover, width:kWidgetWidth, height: kWidgetWidth,)
            else
              if(_eventsObject.imageUrl!=null)Image.file(File(_eventsObject.imageUrl??""), fit: BoxFit.cover, width: kWidgetWidth, height: kWidgetWidth,)
              else Image.asset('images/footim.jpg',  fit: BoxFit.cover,width: kWidgetWidth, height: kWidgetWidth,),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(_eventsObject.value==null||_eventsObject.value.isEmpty?"Value goes here":_eventsObject.title, style:kSubtitleStyle),
            ),
            SizedBox(height: 5),
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