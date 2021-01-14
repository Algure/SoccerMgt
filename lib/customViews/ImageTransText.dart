import 'dart:io';

import 'package:flutter/material.dart';
import 'package:soccermgt/EventsObject.dart';
import 'package:soccermgt/constants.dart';

import '../utilities.dart';

class ImageTransText extends StatelessWidget {

  EventsObject _eventsObject;
  Function onFormatSelected;

  var deleteItemFunc;

  var isFromNetwork;

  ImageTransText(this._eventsObject,{this.onFormatSelected,  this.deleteItemFunc, this.isFromNetwork=false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onFormatSelected??(){},
      child: Container(
          decoration: BoxDecoration(
          image: DecorationImage(image: isFromNetwork?NetworkImage(kImageUrlStart+_eventsObject.imageUrl):
          (_eventsObject.imageUrl!=null)?FileImage(File(_eventsObject.imageUrl??""),): AssetImage('images/footim.jpg', ), fit: BoxFit.cover)
          ,color: Colors.white,
        ),
        height: kWidgetWidth*0.8+(isFromNetwork?50:0),
        width: kWidgetWidth,
        child:Column(
          children: [
            SizedBox(height: kWidgetWidth*0.5,),
            Container(
              height: kWidgetWidth*0.3,
              width: double.infinity,
              color: Colors.black.withOpacity(0.5),
              child: Padding(
                padding:  EdgeInsets.all(3.0),
                child: Text(_eventsObject.title==null||_eventsObject.title.isEmpty?"Title goes here":_eventsObject.title, style: TextStyle(color: Colors.white, fontSize: 11,fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,),
              ),
            ),
            isFromNetwork?FlatButton(
              onPressed: deleteItemFunc??(){},
              child: Row(
                children: [
                  Icon(Icons.clear, color: Colors.red,),
                  Text('Delete Event', style: TextStyle(color: Colors.red),)
                ],
              ),
            ):Container(),
          ],
        )
      ),
    );
  }
}
