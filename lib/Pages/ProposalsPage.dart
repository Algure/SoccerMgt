import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:soccermgt/Pages/MainEventsPage.dart';
import 'package:soccermgt/customViews/ProposedEvent.dart';
import 'package:soccermgt/customViews/my_button.dart';
import 'package:soccermgt/database/ProposalsDatabase.dart';

import '../EventData.dart';
import '../utilities.dart';

class Proposals extends StatefulWidget {
  @override
  _ProposalsState createState() => _ProposalsState();
}

class _ProposalsState extends State<Proposals> {
  List<Widget> downloadedProposals=[];
  bool progress=false;

  RefreshController _refreshController=RefreshController(initialRefresh: false);


  @override
  void initState() {
    downloadProposals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: progress,
        child: Container(
          color: Colors.black,
          child: SmartRefresher(
            onRefresh: (){
              reDownloadProposals();
            },
            controller: _refreshController,
            child: ListView(
              children: downloadedProposals,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Proposals'),
        ],
        backgroundColor: Colors.transparent,
        currentIndex: 1,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: (dex){
          if(dex==0){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>MyHomePage(title: 'Soccer Mgt')));
          }
        },
      ),
    );
  }

  void reDownloadProposals() async{
    showProgress(true);
    DateTime now= DateTime.now();
    String formattedDate=  DateFormat('YY:MM:dd').format(now);
    if(!(await uCheckInternet()) ){
    showProgress(false);
    setListFromDb();
    return;
    }
    downloadedProposals=[];
    DatabaseReference myRef=FirebaseDatabase.instance.reference().child('Prop');
    DataSnapshot snapShot=await myRef.once();
    print('gotten value');
    print(snapShot.value.toString());
    Map<dynamic , dynamic> maps= Map.from(snapShot.value);
    ProposalsDB sDb = ProposalsDB();
    for (var key in maps.keys){
    String eventDetails=maps[key];
    downloadedProposals.add(ProposedEvent(data: eventDetails, id:key,onDeleleteItemFunc: (){
    deleteItem(key);
    },));
    await sDb.insertItem(id: key, item: maps[key]);
    }
    uSetPrefsValue('l2date', formattedDate);
    print("done downloading");
    showProgress(false);
  }
  void downloadProposals() async {

    showProgress(true);
    DateTime now= DateTime.now();
    String formattedDate=  DateFormat('YY:MM:dd').format(now);
    if(!(await uCheckInternet()) || ((await uGetSharedPrefValue('l2date')).toString())==formattedDate){
      showProgress(false);
      setListFromDb();
      return;
    }
    downloadedProposals=[];
    DatabaseReference myRef=FirebaseDatabase.instance.reference().child('Prop');
    DataSnapshot snapShot=await myRef.once();
    print('gotten value');
    print(snapShot.value.toString());
    Map<dynamic , dynamic> maps= Map.from(snapShot.value);
    ProposalsDB sDb = ProposalsDB();
    for (var key in maps.keys){
      String eventDetails=maps[key];
      downloadedProposals.add(ProposedEvent(data: eventDetails, id:key,onDeleleteItemFunc: (){
        deleteItem(key);
      },));
      await sDb.insertItem(id: key, item: maps[key]);
    }
    uSetPrefsValue('l2date', formattedDate);
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
    downloadedProposals=[];
    ProposalsDB sDb = ProposalsDB();
    List<EventData> eventsList=await sDb.getEvents();
    for(EventData eves in eventsList){
      downloadedProposals.add(ProposedEvent(data: eves.e, id:eves.l,onDeleleteItemFunc: (){
        deleteItem(eves.l);
      },));
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
    await FirebaseDatabase.instance.reference().child('Prop').child(key).remove();
    print('DELETED+');
    ProposalsDB sDb = ProposalsDB();
    await sDb.deleteItem(key);
    setListFromDb();
  }

}
