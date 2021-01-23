import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soccermgt/customViews/ImageLong.dart';
import 'package:soccermgt/customViews/ImageLongWithText.dart';
import 'package:soccermgt/customViews/ImageShort.dart';
import 'package:soccermgt/customViews/ImageSquare.dart';
import 'package:soccermgt/customViews/ImageTextDescriptionWidget.dart';
import 'package:soccermgt/customViews/ImageTransText.dart';
import 'package:soccermgt/customViews/ImageTransTextDown.dart';
import 'package:soccermgt/customViews/ImageTransTextUp.dart';
import 'package:soccermgt/customViews/my_button.dart';
import 'package:soccermgt/database/TournamentsDatabase.dart';

import '../EventData.dart';
import '../EventsObject.dart';
import '../utilities.dart';
import 'FantasyDataPage.dart';
import 'MainEventsPage.dart';
import 'TeamsPage.dart';
import 'UploadPage.dart';

class TournamentPage extends StatefulWidget {
  @override
  _TournamentPageState createState() => _TournamentPageState();
}

class _TournamentPageState extends State<TournamentPage> {
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
        backgroundColor: Colors.white,
        title: Text('Tournaments', style: TextStyle(color: Colors.black),),
        actions: [
          FlatButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>UploadPage(context, uploadHook:'Tourn')));
              },
              child: Icon(Icons.add, color: Colors.black,)),
          FlatButton(
              onPressed: (){
                displayAboutDialog();
              },
              child: Icon(Icons.info_outline, color: Colors.black,))
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: progress,
        child: Container(
          color: Color(0xFFEEEEEE),
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
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.description), label: 'News'),
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'Teams'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Tournament'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_volleyball), label: 'Fantasy'),
        ],
        backgroundColor: Colors.black,
        currentIndex: 2,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: (dex){
          if(dex==0){
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context)=>MyHomePage()));
          }
          if(dex==1){
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context)=>TeamsPage()));
          }
          else if(dex==2){
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context)=>TournamentPage()));
          }
          else if(dex==3){
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context)=>FantasyDataPage()));
          }
        },
      ),
    );
  }

  Future<void> getAllMarketItems(BuildContext context) async {
    showProgress(true);
    DateTime now= DateTime.now();
    String formattedDate=  DateFormat('YY:MM:dd').format(now);
    if(!(await uCheckInternet()) || ((await uGetSharedPrefValue('ldatetm')).toString())==formattedDate){
      showProgress(false);
      await setListFromDb();
      return;
    }
    itemList=[];
    DatabaseReference myRef=FirebaseDatabase.instance.reference().child('Tourn');
    DataSnapshot snapShot=await myRef.once();
    print('gotten value');
    print(snapShot.value.toString());
    if(snapShot.value.toString()=="null"){
      showProgress(false);
      return;
    }
    Map<dynamic , dynamic> maps= Map.from(snapShot.value);
    TournamentsDb sDb = TournamentsDb();

    for (var key in maps.keys){
      await sDb.insertItem(id: key, item: maps[key].toString());
      String eventDetails=maps[key];
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
    TournamentsDb sDb = TournamentsDb();
    List<EventData> eventsList=await sDb.getEvents();
    for(EventData eves in eventsList){
//      itemList.add(EventItem(eventItem: eves,deleteItemFunc:  (){
//        deleteItem(eves.l);
//      }),);
      try {
        EventsObject eveOb = EventsObject.fromString(eves.e);
        if (eveOb.widgetType == '0') {
          itemList.add(ImageLongWidget(eveOb, isFromNetwork: true, deleteItemFunc: (){
            deleteItem(eves.l);
          },));
        } else if (eveOb.widgetType == '1') {
          itemList.add(ImageLongWithTextWidget(eveOb, isFromNetwork: true,deleteItemFunc: (){
            deleteItem(eves.l);
          },));
        } else if (eveOb.widgetType == '2') {
          itemList.add(ImageShort(eveOb, isFromNetwork: true,deleteItemFunc: (){
            deleteItem(eves.l);
          },));
        } else if (eveOb.widgetType == '3') {
          itemList.add(ImageSquare(eveOb, isFromNetwork: true,deleteItemFunc: (){
            deleteItem(eves.l);
          },));
        } else if (eveOb.widgetType == '4') {
          itemList.add(ImageTextDescriptionWidget(eveOb, isFromNetwork: true,deleteItemFunc: (){
            deleteItem(eves.l);
          },));
        } else if (eveOb.widgetType == '5') {
          itemList.add(ImageTransText(eveOb, isFromNetwork: true,deleteItemFunc: (){
            deleteItem(eves.l);
          },));
        } else if (eveOb.widgetType == '6') {
          itemList.add(ImageTransTextDown(eveOb, isFromNetwork: true,deleteItemFunc: (){
            deleteItem(eves.l);
          },));
        } else if (eveOb.widgetType == '7') {
          itemList.add(ImageTransTextUpWidget(eveOb, isFromNetwork: true,deleteItemFunc: (){
            deleteItem(eves.l);
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
//    showProgress(true);
//    DateTime now= DateTime.now();
//    String formattedDate=  DateFormat('YY:MM:dd').format(now);
//
//    if(!(await uCheckInternet()) ){
//      showProgress(false);
////      uShowNoInternetDialog(context);
//      await setListFromDb();
//      return;
//    }
//    uSetPrefsValue('ldate', formattedDate);
//    itemList=[];
//    DatabaseReference myRef=FirebaseDatabase.instance.reference().child('Eve');
//    DataSnapshot snapShot=await myRef.once();
//    print('gotten value');
//    print(snapShot.value.toString());
//    Map<dynamic , dynamic> maps= Map.from(snapShot.value);
//    OnlineEventsDb sDb = OnlineEventsDb();
//    for (var key in maps.keys){
//    String eventDetails=maps[key];
//
//    if(eventDetails.startsWith('<')){
//      itemList.add(EventItem(data: eventDetails.substring(1), id:key,deleteItemFunc: (){
//      deleteItem(key);
//    },));
//    }else{
//    List<String> eventD=eventDetails.split('<');
//      itemList.add(EventItem(data: eventD[1], id: key , srcImage: kImageUrlStart+eventD[0],deleteItemFunc: (){
//        deleteItem(key);
//      }));
//    }
//    await sDb.insertItem(id: key, item: maps[key]);
//    }
//    print("done downloading");
//    showProgress(false);
//    setState(() {
//
//    });
    showProgress(true);
    DateTime now= DateTime.now();
    String formattedDate=  DateFormat('YY:MM:dd').format(now);
    if(!(await uCheckInternet()) || ((await uGetSharedPrefValue('ldatetnm')).toString())==formattedDate){
      showProgress(false);
      await setListFromDb();
      return;
    }
    itemList=[];
    DatabaseReference myRef=FirebaseDatabase.instance.reference().child('Tourn');
    DataSnapshot snapShot=await myRef.once();
    print('gotten value');
    print(snapShot.value.toString());
    if(snapShot.value.toString()=="null"){
      showProgress(false);
      return;
    }
    Map<dynamic , dynamic> maps= Map.from(snapShot.value);
    TournamentsDb sDb = TournamentsDb();

    for (var key in maps.keys){
      await sDb.insertItem(id: key, item: maps[key].toString());
      String eventDetails=maps[key];
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
    await FirebaseDatabase.instance.reference().child('News').child(key).remove();
    print('DELETED+');
    TournamentsDb sDb = TournamentsDb();
    await sDb.deleteItem(key);
    setListFromDb();
  }



}
