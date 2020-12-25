import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:soccermgt/EventData.dart';
import 'package:soccermgt/UploadPage.dart';
import 'package:soccermgt/customViews/my_button.dart';
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
  RefreshController _refreshController=RefreshController(initialRefresh: false);

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
            color: Colors.black,
            child: SmartRefresher(
             onRefresh: (){
               reDownloadItems();
             },
            controller: _refreshController,
            child: ListView(
              children: itemList
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
    if(!(await uCheckInternet()) || ((await uGetSharedPrefValue('ldate')).toString())==formattedDate){
      showProgress(false);
      setListFromDb();
      return;
    }
    uSetPrefsValue('ldate', formattedDate);
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
    print("done downloading");
    showProgress(false);
  }

  void showProgress(bool b) {
    progress=b;
    _refreshController.refreshCompleted();
    setState(() {
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
    setState(() {

    });
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
    uShowNoInternetDialog(context);
    setListFromDb();
    return;
    }
    uSetPrefsValue('ldate', formattedDate);
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
    print("done downloading");
    showProgress(false);
    setState(() {

    });
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
    await FirebaseDatabase.instance.reference().child('Eve').child(key).remove();
    print('DELETED+');
    OnlineEventsDb sDb = OnlineEventsDb();
    await sDb.deleteItem(key);
    setListFromDb();
  }

}


