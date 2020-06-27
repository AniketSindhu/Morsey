import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:morsey/GoogleSignin.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
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
          SignInButton(Buttons.GoogleDark, onPressed: ()=>signInWithGoogle(context),text: 'Continue With Google',)
        ]
      ),
    );
  }
}