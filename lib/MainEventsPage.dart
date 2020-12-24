import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:soccermgt/EventData.dart';
import 'package:soccermgt/UploadPage.dart';
import 'package:soccermgt/utilities.dart';
import 'customViews/EventsListItem.dart';
import 'database/OnlineEventsDB.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  List<Widget> itemList=[];

  bool progress;


  @override
  void initState() {
    getAllMarketItems(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        backgroundColor: Colors.black,
        title: Text(widget.title),
        actions: [
          FlatButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>UploadPage(context)));
              },
              child: Icon(Icons.add, color: Colors.white,))
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: progress,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image:AssetImage('images/UnityBackground.png'),
              fit: BoxFit.cover
            )
          ),
          child: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
    if(!(await uCheckInternet())){
      showProgress(false);
      setListFromDb();
      return;
    }
    itemList=[];
    DatabaseReference myRef=FirebaseDatabase.instance.reference().child('Eve');
    DataSnapshot snapShot=await myRef.once();
    print('gotten value');
    print(snapShot.value.toString());
    Map<dynamic , dynamic> maps= Map.from(snapShot.value);
    OnlineEventsDb sDb = OnlineEventsDb();
    for (var key in maps.keys){
      String eventDetails=maps[key];

      if(eventDetails.startsWith('<')){
        itemList.add(EventItem(data: eventDetails.substring(1), id:key,deleteItemFunc: (){
          deleteItem(key);
        },));
      }else{
        List<String> eventD=eventDetails.split('<');
        itemList.add(EventItem(data: eventD[1], id: key , srcImage: kImageUrlStart+eventD[0],deleteItemFunc: (){
          deleteItem(key);
        }));
      }
      await sDb.insertItem(id: key, item: maps[key]);
    }
    showProgress(false);
  }

  void showProgress(bool b) {
    setState(() {
      progress=b;
    });
  }

  Future<void> setListFromDb() async {
    showProgress(true);
    itemList=[];
    OnlineEventsDb sDb = OnlineEventsDb();
    List<EventData> eventsList=await sDb.getEvents();
    for(EventData eves in eventsList){
      itemList.add(EventItem(eventItem: eves,deleteItemFunc:  (){
        deleteItem(eves.l);
      }),);
    }
    showProgress(false);
  }

  Future<void> deleteItem(String key) async {
    if(!(await uCheckInternet())){
      uShowNoInternetDialog(context);
      return;
    }
    showProgress(true);
   await FirebaseDatabase.instance.reference().child('Eve').child(key).remove();
    OnlineEventsDb sDb = OnlineEventsDb();
    await sDb.deleteItem(key);
   setListFromDb();
  }

}


