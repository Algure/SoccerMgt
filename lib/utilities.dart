
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


const kImageUrlStart='';

Future<bool> uCheckInternet() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  return false;
}

void uShowNoInternetDialog(BuildContext context){
  uShowCustomDialog(context:context, icon: CupertinoIcons.cloud_bolt_rain, iconColor: Colors.grey,text:'No iternet connection. 😕');
}
void uShowCustomDialog({BuildContext context, IconData icon, Color iconColor, String text, List buttonList}){
  List<Widget> butList=[];
  if(buttonList!=null && buttonList.length>0){
    for(var arr in buttonList){
      butList.add(Expanded(
        child: Container(
          margin: EdgeInsets.all(4.0),
          decoration: BoxDecoration(
              color: arr[1],
              borderRadius: BorderRadius.circular(20)
          ),
          child: FlatButton(onPressed: arr[2],
            child: Padding(
              padding: EdgeInsets.all(2),
              child: Text(arr[0], style: TextStyle(color: Colors.black),),
            ),
            splashColor: Colors.white,),
        ),
      ));
    }
  }
  Dialog errorDialog= Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    backgroundColor: Color(0xFFDDDDFF),
    child: Container(
      height: 350,
      child: Column(
        children: [
          Expanded(child: Icon(icon, color: iconColor, size: 200,)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(text, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
          ),
          SizedBox(height: 20,),
          Container(
            height: butList!=null?50:2,
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: buttonList!=null?butList:[],
            ),
          )
        ],
      ),
    ),
  );
  showGeneralDialog(context: context,
      barrierLabel: text,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 500),
      transitionBuilder: (_, anim, __, child){
        return SlideTransition(position: Tween(begin: Offset(-1,0), end: Offset(0,0)).animate(anim), child: child,);
      },
      pageBuilder: (BuildContext context, _, __)=>(errorDialog)
  );
}
