import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soccermgt/customViews/my_button.dart';

import '../EventsObject.dart';
import '../constants.dart';
import '../utilities.dart';

class UploadTeamPage extends StatefulWidget {
  BuildContext oldContext;

  UploadTeamPage({this.oldContext});

  @override
  _UploadTeamPageState createState() => _UploadTeamPageState();
}

class _UploadTeamPageState extends State<UploadTeamPage> {
  bool progress=false;
  final picker= ImagePicker();
  List filePaths=[];
  List<String> imageUrls=[];
  List<Widget> imageWidgets=[];
  File file= File('');
  String filePath;
  String description='';
  String downloadUrl;
  List<Widget> DisplayFormatsList=[];
  String title="";
  String speed="";
  String power="";
  String shot="";
  Widget selectedWidget;
  EventsObject eventsObject;
  FocusNode linkNode=FocusNode();
  FocusNode titleNode=FocusNode();
  FocusNode descriptionNode=FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        backgroundColor: Colors.white,
        title: Text("Upload New Team", style: TextStyle(color:Colors.black),),
        leading: FlatButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Icon(Icons.keyboard_backspace, color: Colors.black,)),
      ),

      body: ModalProgressHUD(
        inAsyncCall: progress,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(

            child: Container(
              color: Color(0xffdddddd),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10,width: double.infinity,),
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.all(Radius.circular(10))

                      ),
                      child: Image.file(file,  height: 250, width: double.maxFinite, fit: BoxFit.cover,)
                  ),
                  Container(
                    height: 50,
                    child: Row(
                      children: [
                        Expanded(
                          child: MyButton(text: 'Select Team logo', buttonColor: Colors.blue, onPressed: (){
                            selectImage();
                          }),
                        ),
                        Expanded(
                          child: MyButton(text: 'Remove Image', buttonColor: Colors.red, onPressed: (){
                            filePath="";
                            file=File('');
                            setState(() {

                            });
                          }),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20,width: double.infinity),
                  TextField(
                      controller: TextEditingController(
                          text: title
                      ),
                      style: TextStyle(color: Colors.black),
                      textAlign: TextAlign.start,
                      onChanged: (text){title=text;},
                      maxLines:2,
                      focusNode: titleNode,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Enter club name',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(
                                color: Colors.black,
                                width: 1.5
                            )),
                      )
                  ),
                  SizedBox(height: 20,width: double.infinity),
                  TextField(
                      controller: TextEditingController(
                          text: speed
                      ),
                      style: TextStyle(color: Colors.black),
                      textAlign: TextAlign.start,
                      focusNode: descriptionNode,
                      onChanged: (text){speed=text;},
                      maxLines:1,
                      maxLength: 2,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Enter avaerage speed of players',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(
                                color: Colors.black,
                                width: 1.5
                            )),
                      )
                  ),
                  SizedBox(height: 20,width: double.infinity),
                  TextField(
                      controller: TextEditingController(
                          text: power
                      ),
                      style: TextStyle(color: Colors.black),
                      textAlign: TextAlign.start,
                      focusNode: descriptionNode,
                      onChanged: (text){power=text;},
                      maxLines:1,
                      maxLength: 2,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Enter avaerage power of players',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(
                                color: Colors.black,
                                width: 1.5
                            )),
                      )
                  ),
                  SizedBox(height: 20,width: double.infinity),
                  TextField(
                      controller: TextEditingController(
                          text: shot
                      ),
                      style: TextStyle(color: Colors.black),
                      textAlign: TextAlign.start,
                      focusNode: descriptionNode,
                      onChanged: (text){shot=text;},
                      maxLines:1,
                      maxLength: 2,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Enter avaerage shot of players',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(
                                color: Colors.black,
                                width: 1.5
                            )),
                      )
                  ),
                  SizedBox(height: 20),
                  MyButton(text: 'Upload', onPressed: (){
                    showUploadPreviewDialog();
                  })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  selectImage() async {
    showProgress(true);
    PickedFile tempFile= await picker.getImage(source: ImageSource.gallery);
    print('tempfile ${tempFile.toString()}');
    String compressedPath= await compressImage(File(tempFile.path).absolute.path);
    filePath=compressedPath;
    file=File(filePath);
    showProgress(false);
  }

  Future<String> compressImage(String imagePath) async {
    final directory= await getApplicationDocumentsDirectory();
    String path= directory.path+'/GmartPics';
    if(!Directory(path).existsSync()) await Directory(path).create();
    String fileId=getUniqueId();
    path+='/$fileId.jpg';
    File newFile=File(path);
    await newFile.create();
    File compressionFile= await FlutterImageCompress.compressAndGetFile(imagePath, path, quality: 25, rotate: 0);
    return compressionFile.path;
  }

  String getUniqueId() {
    List<String> idSrc=FirebaseDatabase.instance.reference().push().key.toString().split('/');
    String id=idSrc[idSrc.length-1];
    return(id.replaceAll('.', '').replaceAll('#', '').replaceAll('[', '').replaceAll(']', '').replaceAll('*', ''));
  }

  Future<String> uploadPicsGetUrl() async {
    FirebaseStorage storage=FirebaseStorage.instance;
    String picId=getUniqueId();
    Reference ref=storage.ref().child('L').child(picId);
    UploadTask uploadTask=ref.putFile(File(filePath));
    print('uploading pic');
    await uploadTask.then((snapshot) async {
      downloadUrl=await snapshot.ref.getDownloadURL();
    });
    print("download url: "+downloadUrl);
    List<String> downloadUrls=downloadUrl.split('/');
    return downloadUrls[downloadUrls.length-1];
  }

  void showProgress(bool b) {
    setState(() {
      progress=b;
    });
  }

  void showUploadPreviewDialog() {
    if(title==null || title.isEmpty){
      uShowErrorDialog(context, "Title cannot be empty");
      return;
    }
    if(power==null || power.isEmpty){
      uShowErrorDialog(context, "Power cannot be empty");
      return;
    }
    if(speed==null || speed.isEmpty){
      uShowErrorDialog(context, "Speed cannot be empty");
      return;
    }
    if(shot==null || shot.isEmpty){
      uShowErrorDialog(context, "Shot cannot be empty");
      return;
    }
    if(filePath==null || filePath.isEmpty){
      uShowErrorDialog(context, "Logo cannot be empty");
      return;
    }
    Dialog errorDialog= Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Color(0xFFDDDDFF),
      child: Container(
        height: (filePath!=null && filePath.isNotEmpty)? 350:200,
        child: Column(
          children: [
            SizedBox(height: 20,),
            Image.file(file, height: (filePath!=null && filePath.isNotEmpty)? 150:0,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(description, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
            ),
            SizedBox(height: 20,),
            Container(
                height: 80,
                padding: EdgeInsets.all(8.0),
                child:MyButton(
                  text: 'Confirm Upload',
                  onPressed: (){
                    Navigator.pop(context);
                    startUploadSequence();
                  },
                )
            )
          ],
        ),
      ),
    );
    showGeneralDialog(context: context,
        barrierLabel: 'kuuuuuusd',
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: Duration(milliseconds: 500),
        transitionBuilder: (_, anim, __, child){
          return SlideTransition(position: Tween(begin: Offset(-1,0), end: Offset(0,0)).animate(anim), child: child,);
        },
        pageBuilder: (BuildContext context, _, __)=>(errorDialog)
    );
  }

  void uShowErrorDialog(BuildContext context, String errorText){
    uShowCustomDialog(context: context, icon:Icons.warning, iconColor: Colors.red, text: errorText );
  }

  Future<void> startUploadSequence() async {
    String uploadPack='';

    showProgress(true);
    if(!(await uCheckInternet())){
      uShowNoInternetDialog(context);
      showProgress(false);
      return;
    }
    String picUrl="";
    if(filePath!=null && filePath.trim().isNotEmpty){
      picUrl = await uploadPicsGetUrl();
    }
    print('picUrl= $picUrl');
//    List<String> dataList= teamData.split('<');
////    teamName=dataList[0];
////    teamSpeed=dataList[1];
////    teamPower=dataList[2];
////    teamShot=dataList[3];
////    teamLogo=dataList[4];
    uploadPack='$title<$speed<$power<$shot<$picUrl';
    print('upload pack: ${eventsObject.toString()}');
    await FirebaseDatabase.instance.reference().child('News').child(getUniqueId()).set(uploadPack);
    showProgress(false);
    Navigator.pop(context);
    showItemUploadedDialog(widget.oldContext);
  }

  void showItemUploadedDialog(BuildContext context) {
    uShowCustomDialog(context:context,icon: Icons.done, iconColor: Colors.green, text: 'Team has been uploaded');
  }

}
