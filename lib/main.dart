import 'dart:ui' as ui;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:nocako_chatapp/components/const.dart';
import 'package:nocako_chatapp/views/splash_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance
    .activate(webRecaptchaSiteKey: 'Your reCAPTCHA v3 site key...');

  RenderErrorBox.backgroundColor = Colors.transparent;
  RenderErrorBox.textStyle = ui.TextStyle(color: Colors.transparent);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    configOneSignal();
  }

  void configOneSignal()
  {
    OneSignal.shared.setAppId(Constants.myOneSignalId);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nocako ChatApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen()
    );
  }
}
