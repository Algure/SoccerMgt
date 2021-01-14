import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:intl/intl.dart';
import 'package:soccermgt/Pages/UploadTeamPage.dart';
import 'package:soccermgt/customViews/TeamWidget.dart';
import 'package:soccermgt/customViews/my_button.dart';
import 'package:soccermgt/database/TeamsDatabase.dart';

import '../EventData.dart';
import '../utilities.dart';
import 'MainEventsPage.dart';
import 'UploadPage.dart';

class TeamsPage extends StatefulWidget {
  @override
  _TeamsPageState createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  List<Widget> itemList=[];
  bool progress;
  RefreshController _refreshController=RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        backgroundColor: Colors.black,
        title: Text("Teams", style: TextStyle(color: Colors.black),),
        actions: [
          Expanded(child: SizedBox(),),
          FlatButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>UploadTeamPage(oldContext: context)));
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
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'Proposals'),
        ],
        backgroundColor: Colors.black,
        currentIndex: 0,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: (dex){
          if(dex==0){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>MyHomePage()));
          }
        },
      ),

    );
  }


  Future<void> getAllMarketItems(BuildContext context) async {
    showProgress(true);
    DateTime now= DateTime.now();
    String formattedDate=  DateFormat('YY:MM:dd').format(now);
    if(!(await uCheckInternet()) || ((await uGetSharedPrefValue('ldateteam')).toString())==formattedDate){
      showProgress(false);
      await setListFromDb();
      return;
    }
    itemList=[];
    DatabaseReference myRef=FirebaseDatabase.instance.reference().child('Teams');
    DataSnapshot snapShot=await myRef.once();
    print('gotten value');
    print(snapShot.value.toString());
    if(snapShot.value.toString()=="null"){
      showProgress(false);
      return;
    }
    Map<dynamic , dynamic> maps= Map.from(snapShot.value);
    TeamsDb sDb = TeamsDb();
    for (var key in maps.keys){
      await sDb.insertItem(id: key, item: maps[key].toString());
      String eventDetails=maps[key];
      try {

          itemList.add(TeamWidget( teamData:maps[key].toString(),onDeletePressed: (){
            deleteItem(key.toString());
          },));

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
    TeamsDb sDb = TeamsDb();
    List<EventData> eventsList=await sDb.getEvents();
    for(EventData eves in eventsList){
      try {
        itemList.add(TeamWidget( teamData:eves.e,onDeletePressed: (){
          deleteItem(eves.l);
        },));

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
    if(!(await uCheckInternet()) || ((await uGetSharedPrefValue('ldateteam')).toString())==formattedDate){
      showProgress(false);
      await setListFromDb();
      return;
    }
    itemList=[];
    DatabaseReference myRef=FirebaseDatabase.instance.reference().child('Teams');
    DataSnapshot snapShot=await myRef.once();
    print('gotten value');
    print(snapShot.value.toString());
    if(snapShot.value.toString()=="null"){
      showProgress(false);
      return;
    }
    Map<dynamic , dynamic> maps= Map.from(snapShot.value);
    TeamsDb sDb = TeamsDb();
    for (var key in maps.keys){
      await sDb.insertItem(id: key, item: maps[key].toString());
      String eventDetails=maps[key];
      try {

        itemList.add(TeamWidget( teamData:maps[key].toString(),onDeletePressed: (){
          deleteItem(key.toString());
        },));

      }catch(e){
        print("Event update exception ${e.toString()}");
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
    await FirebaseDatabase.instance.reference().child('Teams').child(key).remove();
    print('DELETED+');
    TeamsDb sDb = TeamsDb();
    await sDb.deleteItem(key);
    setListFromDb();
  }

}
