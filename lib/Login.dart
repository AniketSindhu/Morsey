import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:morsey/GoogleSignin.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:url_launcher/url_launcher.dart';
class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  bool checked=false;
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1B0536),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:<Widget>[
          Text('MORSEY',style: GoogleFonts.orbitron(textStyle:TextStyle(color:Colors.tealAccent,fontSize:40,fontWeight: FontWeight.bold)),),
          Text('Chat Morse',style: TextStyle(color: Colors.tealAccent),),
          SizedBox(height:10),
          Lottie.asset('assets/loginAnim.json'),
          SizedBox(height:10),
          SignInButton(Buttons.GoogleDark,
            onPressed: (){
              if(checked==true)
              signInWithGoogle(context);
              else
               Fluttertoast.showToast(
                 msg: "Please review privacy policy first",
                backgroundColor: Colors.redAccent,
                textColor: Colors.white
              );
            },
            text:'Continue With Google',
          ),
          SizedBox(height:10),
          CheckboxListTile(
            title: Text.rich(TextSpan(
              children:[
                TextSpan(text:"You accept the"),
                TextSpan(text:" Privacy policy ",recognizer: TapGestureRecognizer()..onTap=(){
                  launch("https://morsey.flycricket.io/privacy.html");
                },style: TextStyle(color:Colors.blue,fontStyle: FontStyle.italic)),
                TextSpan(text:"of morsey")
              ] )),
            value: checked,
            onChanged: (newValue) { 
              setState(() {
                   checked = newValue; 
                 }); 
               },
            controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
          )
        ]
      ),
    );
  }
}