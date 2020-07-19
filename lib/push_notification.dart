import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging();

  Future initialise() async {
    if (Platform.isAndroid) {
      _messaging.requestNotificationPermissions(IosNotificationSettings());
    }

    _messaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
    });
  }
}
