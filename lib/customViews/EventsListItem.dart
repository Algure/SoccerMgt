import 'package:flutter/material.dart';
import 'package:soccermgt/EventData.dart';

import '../utilities.dart';

class EventItem extends StatelessWidget {

  String id;
  String srcImage='';
  String data;
  EventData eventItem;
  Function deleteItemFunc;

  EventItem({this.data, this.id, this.srcImage, this.eventItem, this.deleteItemFunc}){
    if(eventItem!=null){
      id = eventItem.l;
      if(eventItem.e!=null && eventItem.e.isNotEmpty){
        if(eventItem.e.trim().startsWith('<')){
          data=eventItem.e.substring(1);
        }else{
          List<String> dataBank=eventItem.e.split('<');
          if(dataBank.length>1)data=dataBank[1];
          srcImage=kImageUrlStart+dataBank[0];
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      color: Colors.black.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(srcImage, height: 100, fit: BoxFit.cover,),
          SizedBox(height: 15,),
          Text(data, style: TextStyle(color: Colors.white, fontSize: 20)),
          SizedBox(height: 10,),
          FlatButton(
            onPressed: deleteItemFunc,
            child: Row(
              children: [
                Icon(Icons.clear, color: Colors.white,),
                Text('Delete Event', style: TextStyle(color: Colors.white),)
              ],
            ),
          )
        ],
      ),
    );
  }
}
