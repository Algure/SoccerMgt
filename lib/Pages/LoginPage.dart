import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utilities.dart';
import 'MainEventsPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showProgress=false;
  FocusNode emailFocus= FocusNode();
  FocusNode paswordFocus= FocusNode();
  Color textFillColor=Color(0x22FFFFFF);

  String email;

  var hintSelectedColor=Colors.blue;

  var hintColor=Colors.grey;

  String password;

  bool showPassword=false;
  @override
  void initState() {
    loginIfNecessary();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showProgress,
      color: Colors.black.withOpacity(0.9),
      child: Material(
        child: Container(
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                  tag: 'mainLogo',
                  child: Icon(Icons.sports_volleyball, size: 150, color: Colors.white,)),
              SizedBox(height: 30,),
              Text("Masti-Soccer", textAlign: TextAlign.center, style: TextStyle(color:Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
              SizedBox(height: 20,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: (string){email=string.toString();},
                  focusNode: emailFocus,
                  decoration: InputDecoration(
                      filled: true,
                      prefixIcon: Icon(CupertinoIcons.mail, color: Colors.white,),
                      labelText: 'Enter email',
                      labelStyle: TextStyle(
                          color:emailFocus.hasFocus?hintColor:hintSelectedColor
                      ),
                      fillColor: textFillColor
                  ),
                  textInputAction: TextInputAction.next,
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              SizedBox(height: 10,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  onChanged: (string){password=string.toString();},
                  focusNode: paswordFocus,
                  decoration: InputDecoration(
                      filled: true,
                      prefixIcon: Icon(CupertinoIcons.lock, color: Colors.white,),
                      suffixIcon: IconButton(icon: Icon(showPassword?Icons.visibility_off:Icons.visibility, color: Colors.grey,), onPressed: toggleIconVisibility,),
                      labelText: 'Enter password',
                      labelStyle: TextStyle(
                          color:paswordFocus.hasFocus?hintColor:hintSelectedColor
                      ),
                      fillColor: textFillColor
                  ),
                  textInputAction: TextInputAction.done,
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: showPassword?false:true,
                ),
              ),
              SizedBox(height: 20,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                height: 45,
                child: Row(
                  children: [
                    Expanded(
                        child:  Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: FlatButton(onPressed: (){
                            checkDetails();
                          },
                            child: Text('Login', style: TextStyle(
                                color: Colors.white,
                                fontSize: 14
                            ),),
                            splashColor: Colors.white,),
                        )
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                color: Colors.transparent,
                child: FlatButton(onPressed: (){
                  uShowErrorDialog(this.context,'Contact support for password retrieval');
                },
                  child: Text('Forgot password', textAlign: TextAlign.center, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w400 ),),
                  splashColor: Colors.white,),
              )
            ],
          ),
        ),
      ),
    );
  }
  Future<void> loginIfNecessary() async {
    SharedPreferences sp=await SharedPreferences.getInstance();
    if(sp.containsKey('id')){
      String s=await sp.get('id').toString();
      if(s!='null' && s.isNotEmpty)
        Navigator.push(context, MaterialPageRoute(builder:(context)=>MyHomePage()));
      return;
    }
  }

  toggleIconVisibility(){
    showPassword=!showPassword;
    setState(() {

    });
  }
  Future<void> checkDetails () async {
    try {
      bool cancel = false;
      // Check for a valid password, if the user entered one.
      if (password.isEmpty || password.length<6) {
        uShowErrorDialog(this.context,'An error occured: Invalid password.\nPassword cannot not be less than 6 characters.');
        cancel = true;
        return;
      }
      // Check for a valid email address.
      if (email.isEmpty) {
        cancel = true;
        uShowErrorDialog(this.context,'An error occured: Invalid email address');
        return;
      } else if (!email.contains('@')||!email.contains('.com')|| email.length<6) {
        uShowErrorDialog(this.context,'An error occured: Invalid email address');
        cancel = true;
        return;
      }
      if (cancel) {
        uShowErrorDialog(this.context,'An error occured\nInvalid credentials.');
        return;
      }else if(!(await uCheckInternet())){
        uShowNoInternetDialog(this.context);
      }
      else {
        setProgress(true);
        attemptLogin();
      }
    }catch ( e){
      print(e);
      setProgress(false);
      uShowErrorDialog(this.context,'An error occured');
    }
  }

  Future<void> attemptLogin() async {
    setProgress(true);
    SharedPreferences sp = await SharedPreferences.getInstance();
    String falseEmail = sp.getString('failedMail') ?? '';
    try {

      bool error=false;
      print('gotten to sign IN');
      FirebaseAuth fbauth = FirebaseAuth.instance;
      var userCred = await fbauth.signInWithEmailAndPassword(
          email: email, password: password);
      String id = userCred.user.uid.toString();
      uSetPrefsValue('id', id);
      setProgress(false);
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context){
        return MyHomePage(title: 'Soccer Mgt');
      }));
    }catch(e){

      if(e.toString().contains('wrong-password')){
        print(e);
        falseEmail = sp.getString('failedMail') ?? '';
        falseEmail += ',$email';
        await sp.setString('failedMail', falseEmail);
        print(await sp.getString('failedMail'));
        setProgress(false);
        uShowErrorDialog(this.context,'An error occured. Contact support for password retrieval');
        return;
      }
      setProgress(false);
      uShowErrorDialog(context, 'An error occured ! Please re-check inputs');
      print(e);
    }
  }

  void setProgress(bool b) {
    setState(() {
      showProgress=b;
    });
  }

}
