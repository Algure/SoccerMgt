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
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        backgroundColor: Colors.black,
        title: Text("Soccer Mgt"),
      ),
      body: ModalProgressHUD(
        inAsyncCall: progress,
        child: SafeArea(
          child: Container(
            color: Colors.black,
            child: SmartRefresher(
              onRefresh: (){
                reDownloadProposals();
              },
              controller: _refreshController,
              child: SingleChildScrollView(
                child: Column(
                  children: downloadedProposals,
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Proposals'),
        ],
        backgroundColor: Colors.black,
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
    await setListFromDb();
    setState(() {

    });
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
      String eventDetails=maps[key].toString();
      downloadedProposals.add(ProposedEvent(data: eventDetails, id:key,onDeleleteItemFunc: (){
        deleteItem(key);
      },
      onPushToMainFunc: (){
        approveItem(key, eventDetails);
      },
      ));
      await sDb.insertItem(id: key, item: maps[key].toString());
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
      await setListFromDb();
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
      String eventDetails=maps[key].toString();
      downloadedProposals.add(ProposedEvent(data: eventDetails, id:key,onDeleleteItemFunc: (){
        deleteItem(key);
      },
        onPushToMainFunc: (){
          approveItem(key, eventDetails);
        },));
      await sDb.insertItem(id: key, item: maps[key].toString());
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
      },
        onPushToMainFunc: (){
          approveItem(eves.l, eves.e);
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

  Future<void> approveItem(String key, String details) async {
    if(!(await uCheckInternet())){
      uShowNoInternetDialog(context);
      return;
    }
    uShowApproveDialog(key:key, details: details);
  }
  void uShowApproveDialog({String key, String details}){
    List<Widget> butList=[];
    Dialog errorDialog= Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.black,
      child: Container(
        height: 350,
        child: Column(
          children: [
            Expanded(child: Icon(Icons.approval, color: Colors.green, size: 200,)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('This event would be made public on the app.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
            ),
            SizedBox(height: 20,),
            Container(
                height: butList!=null?50:2,
                padding: EdgeInsets.all(8.0),
                child: MyButton(text: 'Proceed', buttonColor: Colors.green, textColor: Colors.white, onPressed: (){
                  Navigator.pop(context);
                  realApproveItem(key, details);
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
  void realApproveItem(String key, String details) async{
    if(!(await uCheckInternet())){
      uShowNoInternetDialog(context);
      return;
    }
    List<String> detailsList= details.split(':')[1].replaceAll('"', '').split('<');
    print('key2delete: '+key);
    showProgress(true);
    await FirebaseDatabase.instance.reference().child('Eve').child(key).set('<'+detailsList[0].trim());
    await FirebaseDatabase.instance.reference().child('Prop').child(key).remove();
    print('Published');
    ProposalsDB sDb = ProposalsDB();
    await sDb.deleteItem(key);
    setListFromDb();
  }

}
