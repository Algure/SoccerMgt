import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soccermgt/TeamDataObject.dart';
import 'package:soccermgt/customViews/ImageLong.dart';
import 'package:soccermgt/customViews/ImageLongWithText.dart';
import 'package:soccermgt/customViews/ImageShort.dart';
import 'package:soccermgt/customViews/ImageSquare.dart';
import 'package:soccermgt/customViews/ImageTextDescriptionWidget.dart';
import 'package:soccermgt/customViews/ImageTransText.dart';
import 'package:soccermgt/customViews/ImageTransTextDown.dart';
import 'package:soccermgt/customViews/ImageTransTextUp.dart';
import 'package:soccermgt/customViews/TeamWidget.dart';
import 'package:soccermgt/customViews/my_button.dart';
import 'package:soccermgt/database/TeamsDataDatabase.dart';

import '../EventsObject.dart';
import '../utilities.dart';
import 'UploadPage.dart';

class TeamDataPage extends StatefulWidget {
  String teamName;
  String teamId;

  TeamDataPage({this.teamName, this.teamId});

  @override
  _TeamDataPageState createState() => _TeamDataPageState();
}

class _TeamDataPageState extends State<TeamDataPage> {

  int _counter = 0;
  List<Widget> itemList=[];
  bool progress=false;
  RefreshController _refreshController=RefreshController(initialRefresh: false);

  @override
  void initState() {
    getAllMarketItems(context);
    //loginIfNecessary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        backgroundColor: Colors.black,
        title: Text(widget.teamName??'Team'),
        actions: [
          Expanded(child: SizedBox(),),
          FlatButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>UploadPage(context,uploadHook: widget.teamId,)));
              },
              child: Icon(Icons.add, color: Colors.white,)),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: progress,
        child: Container(
          color: Colors.black,
          child: SmartRefresher(
            onRefresh: (){
              reDownloadItems();
            },
            controller: _refreshController,
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: itemList
              ),
            ),
          ),
        ),
      ),

    );
  }


  Future<void> getAllMarketItems(BuildContext context) async {
    showProgress(true);
    DateTime now= DateTime.now();
    String formattedDate=  DateFormat('YY:MM:dd').format(now);
    if(!(await uCheckInternet()) || ((await uGetSharedPrefValue('ldateTEAM${widget.teamName}')).toString())==formattedDate){
      showProgress(false);
      await setListFromDb();
      return;
    }
    itemList=[];
    DatabaseReference myRef=FirebaseDatabase.instance.reference().child('${widget.teamId}');
    DataSnapshot snapShot=await myRef.once();
    print('gotten value');
    print(snapShot.value.toString());
    if(snapShot.value.toString()=="null"){
      showProgress(false);
      return;
    }
    Map<dynamic , dynamic> maps= Map.from(snapShot.value);
    TeamsDataDb sDb = TeamsDataDb();

    for (var key in maps.keys){
      TeamData teamData=TeamData.fromMap(maps[key]);
      await sDb.insertItem(id: key, teamData: teamData);
      try{
        String eventDetails=teamData.e;
        try {
          EventsObject eveOb = EventsObject.fromString(eventDetails);
          if (eveOb.widgetType == '0') {
            itemList.add(ImageLongWidget(eveOb, isFromNetwork: true,deleteItemFunc: (){
              deleteItem(key.toString());
            },));
          } else if (eveOb.widgetType == '1') {
            itemList.add(ImageLongWithTextWidget(eveOb, isFromNetwork: true,deleteItemFunc: (){
              deleteItem(key.toString());
            },));
          } else if (eveOb.widgetType == '2') {
            itemList.add(ImageShort(eveOb, isFromNetwork: true, deleteItemFunc: (){
              deleteItem(key.toString());
            },));
          } else if (eveOb.widgetType == '3') {
            itemList.add(ImageSquare(eveOb, isFromNetwork: true, deleteItemFunc: (){
              deleteItem(key.toString());
            },));
          } else if (eveOb.widgetType == '4') {
            itemList.add(ImageTextDescriptionWidget(eveOb, isFromNetwork: true, deleteItemFunc: (){
              deleteItem(key.toString());
            },));
          } else if (eveOb.widgetType == '5') {
            itemList.add(ImageTransText(eveOb, isFromNetwork: true, deleteItemFunc: (){
              deleteItem(key.toString());
            },));
          } else if (eveOb.widgetType == '6') {
            itemList.add(ImageTransTextDown(eveOb, isFromNetwork: true, deleteItemFunc: (){
              deleteItem(key.toString());
            },));
          } else if (eveOb.widgetType == '7') {
            itemList.add(ImageTransTextUpWidget(eveOb, isFromNetwork: true, deleteItemFunc: (){
              deleteItem(key.toString());
            },));
          }
        }catch(e){
          print("Event add exception ${e.toString()}");
        }
      }catch(e){
        print("Event add exception ${e.toString()}");
      }
    }
    showProgress(false);
  }

  void showProgress(bool b) {
    setState(() {
      progress=b;
      _refreshController.refreshCompleted();
    });
  }

  Future<void> setListFromDb() async {
    showProgress(true);
    itemList=[];
    TeamsDataDb sDb = TeamsDataDb();
    List<TeamData> eventsList=await sDb.getAllTeamData(widget.teamId);
    for (TeamData teamData in eventsList){
      String key=teamData.i;
      String eventDetails=teamData.e;
      try {
        EventsObject eveOb = EventsObject.fromString(eventDetails);
        if (eveOb.widgetType == '0') {
          itemList.add(ImageLongWidget(eveOb, isFromNetwork: true,deleteItemFunc: (){
            deleteItem(key.toString());
          },));
        } else if (eveOb.widgetType == '1') {
          itemList.add(ImageLongWithTextWidget(eveOb, isFromNetwork: true,deleteItemFunc: (){
            deleteItem(key.toString());
          },));
        } else if (eveOb.widgetType == '2') {
          itemList.add(ImageShort(eveOb, isFromNetwork: true, deleteItemFunc: (){
            deleteItem(key.toString());
          },));
        } else if (eveOb.widgetType == '3') {
          itemList.add(ImageSquare(eveOb, isFromNetwork: true, deleteItemFunc: (){
            deleteItem(key.toString());
          },));
        } else if (eveOb.widgetType == '4') {
          itemList.add(ImageTextDescriptionWidget(eveOb, isFromNetwork: true, deleteItemFunc: (){
            deleteItem(key.toString());
          },));
        } else if (eveOb.widgetType == '5') {
          itemList.add(ImageTransText(eveOb, isFromNetwork: true, deleteItemFunc: (){
            deleteItem(key.toString());
          },));
        } else if (eveOb.widgetType == '6') {
          itemList.add(ImageTransTextDown(eveOb, isFromNetwork: true, deleteItemFunc: (){
            deleteItem(key.toString());
          },));
        } else if (eveOb.widgetType == '7') {
          itemList.add(ImageTransTextUpWidget(eveOb, isFromNetwork: true, deleteItemFunc: (){
            deleteItem(key.toString());
          },));
        }
      }catch(e){
        print("Event add exception ${e.toString()}");
      }
    }
    print('event list length: ${itemList.length}');
    showProgress(false);
  }

  Future<void> deleteItem(String key) async {
    if(!(await uCheckInternet())){
      uShowNoInternetDialog(context);
      return;
    }
    uShowDeleteDialog(key:key);
  }

  void reDownloadItems() async{
    showProgress(true);
    DateTime now= DateTime.now();
    String formattedDate=  DateFormat('YY:MM:dd').format(now);
    if(!(await uCheckInternet()) ){
      showProgress(false);
      await setListFromDb();
      return;
    }
    itemList=[];
    DatabaseReference myRef=FirebaseDatabase.instance.reference().child('${widget.teamId}');
    DataSnapshot snapShot=await myRef.once();
    print('gotten value');
    print(snapShot.value.toString());
    if(snapShot.value.toString()=="null"){
      showProgress(false);
      return;
    }
    Map<dynamic , dynamic> maps= Map.from(snapShot.value);
    TeamsDataDb sDb = TeamsDataDb();

    for (var key in maps.keys){
      TeamData teamData=TeamData.fromMap(maps[key]);
      await sDb.insertItem(id: key, teamData: teamData);
      try{
        String eventDetails=teamData.e;
        try {
          EventsObject eveOb = EventsObject.fromString(eventDetails);
          if (eveOb.widgetType == '0') {
            itemList.add(ImageLongWidget(eveOb, isFromNetwork: true,deleteItemFunc: (){
              deleteItem(key.toString());
            },));
          } else if (eveOb.widgetType == '1') {
            itemList.add(ImageLongWithTextWidget(eveOb, isFromNetwork: true,deleteItemFunc: (){
              deleteItem(key.toString());
            },));
          } else if (eveOb.widgetType == '2') {
            itemList.add(ImageShort(eveOb, isFromNetwork: true, deleteItemFunc: (){
              deleteItem(key.toString());
            },));
          } else if (eveOb.widgetType == '3') {
            itemList.add(ImageSquare(eveOb, isFromNetwork: true, deleteItemFunc: (){
              deleteItem(key.toString());
            },));
          } else if (eveOb.widgetType == '4') {
            itemList.add(ImageTextDescriptionWidget(eveOb, isFromNetwork: true, deleteItemFunc: (){
              deleteItem(key.toString());
            },));
          } else if (eveOb.widgetType == '5') {
            itemList.add(ImageTransText(eveOb, isFromNetwork: true, deleteItemFunc: (){
              deleteItem(key.toString());
            },));
          } else if (eveOb.widgetType == '6') {
            itemList.add(ImageTransTextDown(eveOb, isFromNetwork: true, deleteItemFunc: (){
              deleteItem(key.toString());
            },));
          } else if (eveOb.widgetType == '7') {
            itemList.add(ImageTransTextUpWidget(eveOb, isFromNetwork: true, deleteItemFunc: (){
              deleteItem(key.toString());
            },));
          }
        }catch(e){
          print("Event add exception ${e.toString()}");
        }
      }catch(e){
        print("Event add exception ${e.toString()}");
      }
    }
    showProgress(false);
  }
  displayAboutDialog(){
    Navigator.pop(context);
    showAboutDialog(
      applicationName: 'Soccer-Masti Mgt.',
      context: this.context,
      applicationLegalese: 'Brought to you by Cyber-Techies',
      applicationVersion: '1.0.0',
      applicationIcon:Container(child: Icon(Icons.sports_volleyball,size: 70, color: Colors.deepPurple,),),

    );
  }
  void uShowDeleteDialog({String key}){
    List<Widget> butList=[];
    Dialog errorDialog= Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.black,
      child: Container(
        height: 350,
        child: Column(
          children: [
            Expanded(child: Icon(Icons.delete, color: Colors.red, size: 200,)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('This event would be permanently deleted.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
            ),
            SizedBox(height: 20,),
            Container(
                height: butList!=null?50:2,
                padding: EdgeInsets.all(8.0),
                child: MyButton(text: 'Delete', buttonColor: Colors.white, textColor: Colors.black, onPressed: (){
                  Navigator.pop(context);
                  realDeleteItem(key);
                },)
            )
          ],
        ),
      ),
    );
    showGeneralDialog(context: context,
        barrierLabel: 'iugisss',
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: Duration(milliseconds: 500),
        transitionBuilder: (_, anim, __, child){
          return SlideTransition(position: Tween(begin: Offset(-1,0), end: Offset(0,0)).animate(anim), child: child,);
        },
        pageBuilder: (BuildContext context, _, __)=>(errorDialog)
    );
  }


  void realDeleteItem(String key) async{
    if(!(await uCheckInternet())){
      uShowNoInternetDialog(context);
      return;
    }
    print('key2delete: '+key);
    showProgress(true);
    await FirebaseDatabase.instance.reference().child('${widget.teamId}').child(key).remove();
    print('DELETED+');
    TeamsDataDb sDb = TeamsDataDb();
    await sDb.deleteItem(key);
    setListFromDb();
  }

//  Future<void> loginIfNecessary() async {
////    SharedPreferences sp=await SharedPreferences.getInstance();
////    if(sp.containsKey('id')){
////      String s=await sp.get('id').toString();
////      if(s=='null' || s.isEmpty)
////        Navigator.push(context, MaterialPageRoute(builder:(context)=>LoginPage()));
////      return;
////    }
//  }

}
