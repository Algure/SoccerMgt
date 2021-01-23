
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soccermgt/EventsObject.dart';
import 'package:soccermgt/constants.dart';
import 'package:soccermgt/customViews/ImageLong.dart';
import 'package:soccermgt/customViews/ImageLongWithText.dart';
import 'package:soccermgt/customViews/ImageShort.dart';
import 'package:soccermgt/customViews/ImageSquare.dart';
import 'package:soccermgt/customViews/ImageTextDescriptionWidget.dart';
import 'package:soccermgt/customViews/ImageTransText.dart';
import 'package:soccermgt/customViews/ImageTransTextDown.dart';
import 'package:soccermgt/customViews/ImageTransTextUp.dart';
import 'file:///C:/FlutterProjects/SoccerMgt/flutter_app/lib/customViews/my_button.dart';
import 'package:soccermgt/utilities.dart';

class UploadPage extends StatefulWidget {
  BuildContext oldContext;
  String uploadHook;
  UploadPage(this.oldContext, {this.uploadHook="News"});
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
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

  String widgetType="";

  String clickLink="";

  Widget selectedWidget;

  EventsObject eventsObject;

  FocusNode linkNode=FocusNode();
  FocusNode titleNode=FocusNode();
  FocusNode descriptionNode=FocusNode();


  @override
  void initState() {
    setupDisplayFormatList();
    linkNode.addListener(() {
      setupDisplayFormatList2();
    });
    titleNode.addListener(() {
      setupDisplayFormatList2();
    });
    descriptionNode.addListener(() {
      setupDisplayFormatList2();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        backgroundColor: Colors.white,
        title: Text("Upload Event", style: TextStyle(color:Colors.black),),
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
                          child: MyButton(text: 'Select Image', buttonColor: Colors.blue, onPressed: (){
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
                        hintText: 'Enter title of event',
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
                          text: description
                      ),
                      style: TextStyle(color: Colors.black),
                      textAlign: TextAlign.start,
                      focusNode: descriptionNode,
                      onChanged: (text){description=text;},
                      maxLines:6,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Enter details of event with links.',
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
                          text: clickLink
                      ),
                      focusNode: linkNode,
                      style: TextStyle(color: Colors.black),
                      textAlign: TextAlign.start,
                      onChanged: (text){clickLink=text;},
                      maxLines:2,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Enter link for event click',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 1.5
                              )),
                      )
                  ),
                  SizedBox(height: 5),
                  Text("Select Display format", style: TextStyle(color: Colors.black),),
                  SizedBox(height: 5),
                  Container(
                      color: Colors.transparent,
                      child:selectedWidget??Container()),
                  Container(
                    height: kWidgetWidth*2,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ImageLongWidget(eventsObject, onFormatSelected: (){
                            EventsObject eventsObject=EventsObject(title: title, value: description, imageUrl: filePath, widgetType: widgetType,        clickLink: clickLink);
                            widgetType="0";
                            selectedWidget=ImageLongWidget(eventsObject);
                            setState(() {

                            });
                          },),
                        SizedBox(width: 20,),
                        ImageLongWithTextWidget(eventsObject, onFormatSelected: (){
                          EventsObject eventsObject=EventsObject(title: title, value: description, imageUrl: filePath, widgetType: widgetType, clickLink: clickLink);
                          widgetType="1";
                          selectedWidget=ImageLongWithTextWidget(eventsObject);
                          setState(() {

                          });
                        },),
                          SizedBox(width: 10,),
                          ImageShort(eventsObject, onFormatSelected: (){
                          EventsObject eventsObject=EventsObject(title: title, value: description, imageUrl: filePath, widgetType: widgetType, clickLink: clickLink);
                          widgetType="2";
                          selectedWidget=ImageShort(eventsObject);
                          setState(() {

                          });
                        },),
                          SizedBox(width: 10,),
                          ImageSquare(eventsObject,  onFormatSelected: (){
                        EventsObject eventsObject=EventsObject(title: title, value: description, imageUrl: filePath, widgetType: widgetType,        clickLink: clickLink);
                        widgetType="3";
                        selectedWidget=ImageSquare(eventsObject);
                        setState(() {

                        });
                      },),
                          SizedBox(width: 10,),
                          ImageTextDescriptionWidget(eventsObject, onFormatSelected: (){
                        EventsObject eventsObject=EventsObject(title: title, value: description, imageUrl: filePath, widgetType: widgetType,        clickLink: clickLink);
                        widgetType="4";
                        selectedWidget=ImageTextDescriptionWidget(eventsObject);
                        setState(() {

                        });
                      },),
                          SizedBox(width: 10,),
                          ImageTransText(eventsObject, onFormatSelected: (){
                        EventsObject eventsObject=EventsObject(title: title, value: description, imageUrl: filePath, widgetType: widgetType,        clickLink: clickLink);
                        widgetType="5";
                        selectedWidget=ImageTransText(eventsObject);
                        setState(() {

                        });
                      },),
                          SizedBox(width: 10,),
                          ImageTransTextDown(eventsObject,  onFormatSelected: (){
                        EventsObject eventsObject=EventsObject(title: title, value: description, imageUrl: filePath, widgetType: widgetType,        clickLink: clickLink);
                        widgetType="6";
                        selectedWidget=ImageTransTextDown(eventsObject);
                        setState(() {

                        });
                      },),
                          SizedBox(width: 10,),
                          ImageTransTextUpWidget(eventsObject,
                        onFormatSelected: (){
                          EventsObject eventsObject=EventsObject(title: title, value: description, imageUrl: filePath, widgetType: widgetType,        clickLink: clickLink);
                          widgetType="7";
                          selectedWidget=ImageTransTextUpWidget(eventsObject);
                          setState(() {

                          });
                        },),
                        ],
                      ),
                    ),
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

  void setupDisplayFormatList2() {
    eventsObject=EventsObject(title: title, value: description, imageUrl: filePath, widgetType: widgetType,clickLink: clickLink);
    setState(() {

    });
  }

  setupDisplayFormatList(){
     eventsObject=EventsObject(title: title, value: description, imageUrl: filePath, widgetType: widgetType,clickLink: clickLink);
  }

  selectImage() async {
    showProgress(true);
    PickedFile tempFile= await picker.getImage(source: ImageSource.gallery);
    print('tempfile ${tempFile.toString()}');
    String compressedPath= await compressImage(File(tempFile.path).absolute.path);
    filePath=compressedPath;
    file=File(filePath);
    setupDisplayFormatList2();
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
    if((title==null||title.trim().isEmpty)&&
        (description==null||description.trim().isEmpty)&&
        (filePath==null||filePath.trim().isEmpty)&&
        (widgetType==null||widgetType.trim().isEmpty)&&
        (clickLink==null||clickLink.trim().isEmpty))
    {
      uShowErrorDialog(context, "Event cannot be empty");
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
    if((title==null||title.trim().isEmpty)&&
    (description==null||description.trim().isEmpty)&&
    (filePath==null||filePath.trim().isEmpty)&&
    (widgetType==null||widgetType.trim().isEmpty)&&
    (clickLink==null||clickLink.trim().isEmpty))
    {
      uShowErrorDialog(context, "Insufficient details");
      return;
    }
    if( (widgetType==null||widgetType.trim().isEmpty)){
      uShowErrorDialog(context, "You must select a widget type");
      return;
    }
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
    uploadPack+='<'+description;
    EventsObject eventsObject=EventsObject(title: title, value: description, imageUrl: filePath, widgetType: widgetType,clickLink: clickLink);
    eventsObject.imageUrl=picUrl;
    print('upload pack: ${eventsObject.toString()}');
    await FirebaseDatabase.instance.reference().child('${widget.uploadHook}').child(getUniqueId()).set(eventsObject.toString());
    showProgress(false);
    Navigator.pop(context);
    showItemUploadedDialog(widget.oldContext);
  }

  void showItemUploadedDialog(BuildContext context) {
    uShowCustomDialog(context:context,icon: Icons.done, iconColor: Colors.green, text: 'Event has been uploaded');
  }

}
