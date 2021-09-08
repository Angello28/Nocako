import 'package:flutter/material.dart';

String regexSource = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";

double defaultWidth(BuildContext context){
  return MediaQuery.of(context).size.width;
}

double defaultHeight(BuildContext context){
  return MediaQuery.of(context).size.height;
}

class Constants{
  static String myName = "";
  static String myEmail = "";
}

