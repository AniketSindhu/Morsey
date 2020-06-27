import 'package:cloud_firestore/cloud_firestore.dart';
class FirebaseAdd{

  addUser(String name,String email, String phoneNumber,String uid,String imageUrl){
    Firestore.instance.collection('users').document(email)
    .setData({ 'name': name, 'email': email,'uid':uid,'profilePic':imageUrl});
  }
}