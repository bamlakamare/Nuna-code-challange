import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nuna_tech_code_challange/screens/home_Screen.dart';
import 'package:nuna_tech_code_challange/screens/video_List_Screen.dart';
import 'package:nuna_tech_code_challange/services/fcm_service.dart';
import 'services/firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotifications(navigatorKey);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nuna Code Challenge',
      navigatorKey: navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (context) => MainScreen(),
        '/videoList': (context) => VideoListScreen(),
      },
    );
  }
}
