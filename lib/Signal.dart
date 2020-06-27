import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:morsey/GoogleSignin.dart';
import 'package:morsey/config/size.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:morse/morse.dart';
import 'package:flutter_shake_plugin/flutter_shake_plugin.dart';

class Signal extends StatefulWidget {
  final String chatId;
  final FirebaseUser user;
  final String toUser;
  Signal(this.user,this.chatId,this.toUser);
  @override
  _SignalState createState() => _SignalState();
}

class _SignalState extends State<Signal> {
  final Firestore _firestore = Firestore.instance;
  bool english=false;
  FlutterShakePlugin _shakePlugin;
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  Future<void> callback() async {
    if (messageController.text.length > 0) {
      String morseMessage=Morse(messageController.text).encode();
      await _firestore.collection('signals').document(widget.chatId).collection('Chats').add({
        'text': morseMessage,
        'from': widget.user.email,
        'date': DateTime.now().toIso8601String().toString(),
      });
      messageController.clear();
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }
  void initState(){
    super.initState();
    _shakePlugin = FlutterShakePlugin(
      onPhoneShaken: (){
        english==false?english=true:english=false;
        setState(() {
        });
        print(english);
      },
    )..startListening();
  }
    void dispose() {
    super.dispose();
    _shakePlugin.stopListening();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1B0536),
      appBar: AppBar(
      centerTitle:true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
              end: Alignment.centerRight,
                colors: <Color>[
                Color(0xff6D0B60),
                Color(0xffFF21B7),
            ])          
         ),        
        ), 
        title: Text(widget.toUser,style:GoogleFonts.montserrat(textStyle:TextStyle(color: Colors.white,fontSize:25,fontWeight: FontWeight.w600)),),
        actions: <Widget>[],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(!english?"Shake to turn morse code into English":'Shake to turn English into Morse code',style: TextStyle(color:Colors.white),),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('signals').document(widget.chatId).collection('Chats')
                    .orderBy('date')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(
                      child: CircularProgressIndicator(),
                    );

                  List<DocumentSnapshot> docs = snapshot.data.documents;

                  List<Widget> messages = docs
                      .map((doc) => Message(
                            message: english?Morse(doc.data['text']).decode():doc.data['text'],
                            sendByMe: widget.user.email == doc.data['from'],
                          ))
                      .toList();

                  return ListView(
                    controller: scrollController,
                    children: <Widget>[
                      ...messages,
                    ],
                  );
                },
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom:10.0,left: 8),
                      child: TextField(
                        onSubmitted: (value) => callback(),
                        decoration: InputDecoration(
                          hoverColor: Colors.deepPurpleAccent,
                          hintText: "Enter a signal message",
                          hintStyle: TextStyle(color:Color(0xffE6BBFC)),
                          border: const OutlineInputBorder(),
                        ),
                        controller: messageController,
                      ),
                    ),
                  ),
                  SendButton(
                    text: "Send",
                    callback: callback,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class SendButton extends StatelessWidget {
  final String text;
  final VoidCallback callback;

  const SendButton({Key key, this.text, this.callback}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.send,size: 33,),
      color: Color(0xffFF16CD),
      onPressed: callback,
    );
  }
}

class Message extends StatelessWidget {
  final String message;
  final bool sendByMe;

  Message({@required this.message, @required this.sendByMe});


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: sendByMe ? 0 : 24,
          right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: sendByMe
            ? EdgeInsets.only(left: 30)
            : EdgeInsets.only(right: 30),
        padding: EdgeInsets.only(
            top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: sendByMe ? BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
                bottomLeft: Radius.circular(23)
            ) :
            BorderRadius.only(
        topLeft: Radius.circular(23),
          topRight: Radius.circular(23),
          bottomRight: Radius.circular(23)),
            gradient: LinearGradient(
              colors: sendByMe ? [
                const Color(0xffFF3798),
                const Color(0xffFF9E50),
              ]
                  : [
                Colors.deepPurple,
                Colors.teal
              ],
            )
        ),
        child: Text(message,
            textAlign: TextAlign.start,
            style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'OverpassRegular',
            fontWeight: FontWeight.w700)),
      ),
    );
  }
}