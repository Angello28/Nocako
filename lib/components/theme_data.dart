import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'const.dart';

class ColorTheme{
  Color primaryColor;
  Color secondaryColor;
  Color backgroundColor;
  Color buttonColor;
  Color borderColor;
  Color text1Color;
  Color text2Color;
  Color text3Color;
  Color bubbleChat1;
  Color bubbleChat2;
  String signWallpaper;
  String signWebWallpaper;
  ColorTheme({
    required this.primaryColor, required this.secondaryColor, required this.backgroundColor,
    required this.buttonColor, required this.borderColor, required this.text1Color,
    required this.text2Color, required this.text3Color, required this.bubbleChat1,
    required this.bubbleChat2, required this.signWallpaper, required this.signWebWallpaper
  });
}

class ThemeGetterAndSetter{
  static String sharedPreferenceTheme = "Default";

  static Future<bool> setThemeSharedPreferences (String themeName) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferenceTheme, themeName);
  }

  static Future<String?> getThemeSharedPreferences() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(sharedPreferenceTheme);
  }
}

ColorTheme getTheme(String themeName){
  if(themeName == 'Dark'){
    return ColorTheme(
      primaryColor: Colors.black87,
      secondaryColor: Colors.black87,
      backgroundColor: Colors.black87,
      buttonColor: Color(0xFF505AC9),
      borderColor: Colors.white,
      text1Color: Colors.white,
      text2Color: Colors.white,
      text3Color: Colors.white,
      bubbleChat1: Color(0xFF505AC9),
      bubbleChat2: Colors.black45,
      signWallpaper: 'assets/sign_dark.png',
      signWebWallpaper: 'assets/signweb_dark.png'
    );
  }
  else if(themeName == 'Lofi'){
    return ColorTheme(
      primaryColor: Color(0xFF9C96B2),
      secondaryColor: Color(0xFFFFA08E),
      backgroundColor: Color(0xFF9C96B2),
      buttonColor: Color(0xFF5A4743),
      borderColor: Color(0xFF774F69),
      text1Color: Colors.white,
      text2Color: Colors.white,
      text3Color: Colors.white,
      bubbleChat1: Color(0xFFDF9A8C),
      bubbleChat2: Color(0xFFBF9892),
      signWallpaper: 'assets/sign_lofi.png',
      signWebWallpaper: 'assets/signweb_lofi.png'
    );
  }
  else{
    return ColorTheme(
      primaryColor: Colors.blue,
      secondaryColor: Colors.lightBlueAccent.shade200,
      backgroundColor: Colors.white,
      buttonColor: Colors.blue,
      borderColor: Colors.black,
      text1Color: Colors.white,
      text2Color: Colors.black,
      text3Color: Colors.blue,
      bubbleChat1: Colors.blue,
      bubbleChat2: Colors.grey.shade300,
      signWallpaper: 'assets/sign_default.png',
      signWebWallpaper: 'assets/signweb_default.png'
    );
  }
}