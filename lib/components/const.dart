import 'package:flutter/material.dart';
import 'package:nocako_chatapp/components/theme_data.dart';

String regexSource = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
const charId = 'ABCDEF0123456789';

double defaultWidth(BuildContext context){
  return MediaQuery.of(context).size.width;
}

double defaultHeight(BuildContext context){
  return MediaQuery.of(context).size.height;
}

class Constants{
  static String myId = "";
  static String myName = "";
  static String myEmail = "";
  static String myProfileImage = "";
  static String myThemeName = "";
  static ColorTheme myTheme = getTheme('Default');
}

