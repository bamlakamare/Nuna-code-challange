import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications(GlobalKey<NavigatorState> navigatorKey) async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    final fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $fcmToken');

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received while in foreground: ${message.notification?.title}');
      _navigateBasedOnMessage(message, navigatorKey);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from notification: ${message.notification?.title}');
      _navigateBasedOnMessage(message, navigatorKey);
    });
  }

  void _navigateBasedOnMessage(RemoteMessage message, GlobalKey<NavigatorState> navigatorKey) {
    if (message.data.containsKey('screen')) {
      String screen = message.data['screen'];
      navigatorKey.currentState?.pushNamed(
        screen,
        arguments: message.data,
      );
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}
