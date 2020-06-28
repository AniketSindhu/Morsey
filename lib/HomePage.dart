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
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'Login.dart';
import 'Signal.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
    FirebaseUser user;
    int _selectedIndex = 0;
    bool fab=true;
    bool old=false;
    @override
    getUser()async{
    final FirebaseAuth _auth = FirebaseAuth.instance;
    user= await _auth.currentUser();
    setState((){
    });
    print(user.email);
    }
    void initState(){
      super.initState();
      getUser();
    }
  Widget build(BuildContext context) {
    var height=SizeConfig.getHeight(context);
    var width=SizeConfig.getWidth(context);
    return Scaffold(
      backgroundColor: Color(0xff1B0536),
      bottomNavigationBar: BottomNavyBar(
        backgroundColor: Color(0xff260F41),
        selectedIndex: _selectedIndex,
        showElevation: true,
        curve: Curves.easeIn, // use this to remove appBar's elevation
         onItemSelected: (index) => setState(() {
                   _selectedIndex = index;
         }),
        items: [
          BottomNavyBarItem(
              icon: Icon(Icons.message),
              title: Text('Signals'),
              activeColor: Color(0xFFFF16CD)
          ),
          BottomNavyBarItem(
              icon: Icon(Icons.image),
              title: Text('OCR'),
              activeColor: Colors.purpleAccent
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.school),
            title: Text('Learn'),
            activeColor: Colors.red,
          ),
        ],
      ),
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
        title: Text('Morsey',style:GoogleFonts.montserrat(textStyle:TextStyle(color: Colors.white,fontSize:27,fontWeight: FontWeight.w600)),),
        actions: <Widget>[
          PopupMenuButton(
            color:Colors.tealAccent[400],
            itemBuilder: (BuildContext context){
              return[
                PopupMenuItem(
                  child: Center(
                    child: FlatButton(
                      onPressed:()async{
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.clear();
                        signOutGoogle();
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Login()),ModalRoute.withName('homepage'));
                      },
                      child: Text('Logout',style:GoogleFonts.orbitron(textStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize:18))),
                      color: Colors.yellowAccent,
                      splashColor: Colors.tealAccent,
                    ),
                  )                
                )
              ];
            },
          )
        ],
      ),
      floatingActionButton: fab?FloatingActionButton(
        onPressed:(){Navigator.push(context, MaterialPageRoute(builder: (context)=>NewSignal(user)));},
        child: Icon(Icons.add),
        backgroundColor: Colors.orange[400],
      ):null,
      body:_selectedIndex==0?user!=null?StreamBuilder(
        stream: Firestore.instance.collection('signals').where('users',arrayContains:user.email).snapshots(),
        builder: (context,snapshot){
          if(snapshot.connectionState==ConnectionState.waiting)
          {
            return Center(child: CircularProgressIndicator());
          }
          else
          if(snapshot.data.documents.length==0)
            {
            return Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children:<Widget>[
                  Lottie.asset('assets/sendSignal1.json',),
                  SizedBox(height:20),
                  Text('No previous Signal found',style: GoogleFonts.varelaRound(textStyle:TextStyle(color:Colors.tealAccent,fontSize:18,fontWeight:FontWeight.w500)),),
                  SizedBox(height:20),
                  RaisedButton(
                    child: Text('Send A Singal',style:GoogleFonts.orbitron(textStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize:18))),
                    color: Colors.yellowAccent,
                    splashColor: Colors.tealAccent,
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>NewSignal(user)));
                    },
                  )
                ]
              );
            }
             return ListView.builder(
               itemCount: snapshot.data.documents.length,
               itemBuilder:(context,index){
                 return Padding(
                   padding: const EdgeInsets.only(top:10),
                   child: Column(
                     children: <Widget>[
                       ListTile(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>Signal(user,snapshot.data.documents[index].data['chatId'],snapshot.data.documents[index].data['chatId'].replaceAll("-","").replaceAll(user.email,"").replaceAll('@gmail.com',''))));
                          },
                          title:Text('${snapshot.data.documents[index].data['chatId'].replaceAll("-","").replaceAll(user.email,"")}',style:GoogleFonts.orbitron(textStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize:14,letterSpacing: 2))),                          
                          leading:Container(
                           height: 60,
                           width: 60,
                           decoration: BoxDecoration(
                           gradient: LinearGradient(
                             colors: [const Color(0xffFF3798),const Color(0xffFF9E50),]),
                             borderRadius: BorderRadius.circular(30)),
                             child: Column(
                               mainAxisAlignment: MainAxisAlignment.spaceAround,
                               children: <Widget>[
                                 SizedBox(height:4),
                                 Expanded(
                                   child: Text(snapshot.data.documents[index].data['chatId'].replaceAll("-","").replaceAll(user.email,"").substring(0, 1),
                                     textAlign: TextAlign.center,
                                     style: TextStyle(
                                       color: Colors.black,
                                       fontSize: 24,
                                       fontFamily: 'OverpassRegular',
                                       fontWeight: FontWeight.w600)),
                                 ),
                                 Text('${Morse(snapshot.data.documents[index].data['chatId'].replaceAll("-","").replaceAll(user.email,"").substring(0, 1)).encode()}',style: TextStyle(color:Colors.black,fontSize:22,fontWeight:FontWeight.w700),),
                                 SizedBox(height:4)
                               ],
                             ),
                           ),
                          enabled: true,
                          trailing: Icon(Icons.navigate_next,color: Colors.greenAccent,size:40),
                        ),
                       Padding(
                         padding: const EdgeInsets.only(top:4.0,left:10,right:10),
                         child: Divider(color: Colors.deepOrange,thickness: 0.3,),
                       )
                     ],
                   ),
                 );
               },
            );
        },
      ):
      Center(child: CircularProgressIndicator(),):
      _selectedIndex==1?OCR():Learn()
    );
  }
}

class NewSignal extends StatefulWidget {
  FirebaseUser user;
  NewSignal(this.user);
  @override
  _NewSignalState createState() => _NewSignalState();
}

class _NewSignalState extends State<NewSignal> {
  String email;
  String error;
  TextEditingController mailController=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1B0536),
      appBar: AppBar(
        centerTitle:true,
        backgroundColor: Colors.purple[900],
        title: Text('New Signal',style:GoogleFonts.orbitron(textStyle:TextStyle(color: Colors.tealAccent,fontSize:23,fontWeight: FontWeight.w800)),),
      ),
      body:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(child: Lottie.asset('assets/sendSignal.json')),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: TextStyle(color:Colors.purpleAccent,fontSize:18),
              controller: mailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5),),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                borderSide: BorderSide(color: Colors.purpleAccent),
              ),
                hintText: 'Enter reciever\'s Email',
                hintStyle: TextStyle(color:Colors.purpleAccent,fontSize:18),
                labelText: 'Enter reciever\'s Email'
              ),
              onChanged: (value){
                email=value;
              },
              onSubmitted: (value){
                email=value;
              },
            ),
          ),
          SizedBox(height:20),
          RaisedButton(
            color: Colors.yellowAccent,
            splashColor: Colors.tealAccent,
            onPressed: ()async{
             final z=await Firestore.instance.collection('users').document(mailController.text).get();
            if(z.exists){
              String chatId='${widget.user.email}-${mailController.text}';
              final x= await Firestore.instance.collection('signals').document(chatId).get();
              final y= await Firestore.instance.collection('signals').document(chatId).get();
              if(x.exists||y.exists)
                {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){return Signal(widget.user,chatId,chatId.replaceAll('-', '').replaceAll(widget.user.email,'').replaceAll('@gmail.com',''));}));
                }
              else{
                await Firestore.instance.collection('signals').document(chatId).setData({'users':[widget.user.email,mailController.text],'chatId':chatId});
                await Firestore.instance.collection('users').document(widget.user.email).collection('ActiveSignals').document(chatId).setData({'signalId':chatId});
                await Firestore.instance.collection('users').document(mailController.text).collection('ActiveSignals').document(chatId).setData({'signalId':chatId});
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){return Signal(widget.user,chatId,chatId.replaceAll('-', '').replaceAll(widget.user.email,'').replaceAll('@gmail.com',''));}));
              }
            }
            else
             Fluttertoast.showToast(
              msg: "Email not registered",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
            );
            },
            child: Text('Send Signal',style:GoogleFonts.orbitron(textStyle:TextStyle(color: Colors.black,fontSize:18,fontWeight: FontWeight.w600)),)
          ),
          SizedBox(height:40)
        ],
      ) ,
    );
  }
}

class OCR extends StatefulWidget {
  @override
  _OCRState createState() => _OCRState();
}

class _OCRState extends State<OCR> {
  int _cameraOcr = FlutterMobileVision.CAMERA_BACK;
  String _textValue = "sample";
  @override
  Future<Null> _read() async {
    List<OcrText> texts = [];
    try {
      texts = await FlutterMobileVision.read(
        camera: _cameraOcr,
        waitTap: true,
        fps: 2.0
      );

      setState(() {
        _textValue = (texts[0].value);
      });
    } on Exception {
      texts.add(new OcrText('Failed to recognize text.'));
    }
  }
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Lottie.asset('assets/scan-some-words.json',repeat: false),
            SizedBox(height:20),
            Text(_textValue,style:GoogleFonts.orbitron(textStyle:TextStyle(color: Colors.white,fontSize:20,fontWeight: FontWeight.w500)),textAlign: TextAlign.center,),
            SizedBox(height:10),
            Text(Morse(_textValue).encode(),style:GoogleFonts.orbitron(textStyle:TextStyle(color: Colors.white,fontSize:20,fontWeight: FontWeight.w500)),textAlign: TextAlign.center,),
            SizedBox(height:30),
            RaisedButton(
               onPressed: _read,
              child: new Text('Start Scanning'),
              color: Color(0xFFFF16CD),
              splashColor: Colors.orangeAccent,
            ),
            SizedBox(height:10),
            Text('Tap on the text to convert into morse code',style: TextStyle(color:Color(0xffE6BBFC)),)
          ]
        )
      ),
    );
  }
}


class Learn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child:Padding(
      padding: const EdgeInsets.all(12.0),
      child: Center(child: Image.asset('assets/learnMorse.jpg')),
    ));
  }
}