import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nocako_chatapp/components/theme_data.dart';
import 'package:nocako_chatapp/function/helper.dart';
import 'package:nocako_chatapp/components/const.dart';
import 'package:nocako_chatapp/views/main_screen.dart';
import 'package:nocako_chatapp/views/sign_in.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoggedIn = false;

  static String themeName = "";
  ColorTheme theme = getTheme("Default");

  getThemeFromPreferences() async{
    themeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    theme = getTheme(themeName);
    setState((){});
  }

  getLoggedInState() async{
    await HelperFunction.getUserLoggedInSharedPreference().then((value){
      setState(() {
        isLoggedIn = value == null? false : value;
      });
      pushPage();
    });
  }

  pushPage(){
    if(isLoggedIn){
      Timer(Duration(seconds: 1), (){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
      });
    }
    else
      Timer(Duration(seconds: 1), (){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
      });
  }

  @override
  void initState() {
    getLoggedInState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getThemeFromPreferences();
    return Scaffold(
      body: Container(
        width: defaultWidth(context),
        height: defaultHeight(context),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              theme.primaryColor,
              theme.secondaryColor,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/logo.svg',
              width: defaultHeight(context)/3,
              height: defaultHeight(context)/3,
            ),
            SizedBox(height: defaultHeight(context)/10),
            Text('Nocako',
              style: TextStyle(
                color: theme.text1Color,
                fontSize: defaultHeight(context)/13
              ),
            ),
            SizedBox(height: defaultHeight(context)/50),
            Text('Chat App wihout being toxic',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: theme.text1Color,
                  fontSize: defaultHeight(context)/55
              ),
            ),
          ],
        ),
      )
    );
  }
}


