import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nocako_chatapp/components/const.dart';
import 'package:nocako_chatapp/components/theme_data.dart';
import 'package:nocako_chatapp/function/auth.dart';
import 'package:nocako_chatapp/views/sign_in.dart';
import 'package:nocako_chatapp/views/theme_setting.dart';

// ignore: must_be_immutable
class NavDrawer extends StatefulWidget {
  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  Authentication authentication = new Authentication();
  static String themeName = "";
  ColorTheme theme = getTheme("Default");

  getThemeFromPreferences() async{
    themeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    theme = getTheme(themeName);
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    getThemeFromPreferences();
    return Drawer(
      child: Container(
        padding: EdgeInsets.only(left: defaultHeight(context) / 70, right: defaultHeight(context) / 70, top: defaultHeight(context) / 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              theme.secondaryColor,
              theme.primaryColor,
            ],
          ),
        ),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: defaultHeight(context) / 50, right: defaultHeight(context) / 50),
              height: defaultHeight(context) / 5,
              width: defaultWidth(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: defaultHeight(context)/40),
                  Container(
                    width: defaultHeight(context)/10,
                    height: defaultHeight(context)/10,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.text1Color,
                      borderRadius: BorderRadius.circular(40)
                    ),
                    child: Text("${Constants.myName.substring(0,1).toUpperCase()}",
                        style: TextStyle(
                          fontSize: defaultHeight(context)/25,
                          color: theme.primaryColor
                        ),
                    ),
                  ),
                  SizedBox(height: defaultHeight(context)/45),
                  Row(
                    children: [
                      SizedBox(width: defaultWidth(context)/100),
                      Text(Constants.myName, style: TextStyle(
                          color: theme.text1Color,
                          fontSize: defaultHeight(context) / 50
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: defaultWidth(context)/100),
                      Text(Constants.myEmail, style: TextStyle(
                          color: theme.text1Color,
                          fontSize: defaultHeight(context) / 50
                        ),
                      ),
                    ],
                  )
                ],
              )
            ),
            Divider(
              thickness: 1.5,
              height: defaultHeight(context) / 15,
              color: theme.text1Color,
            ),
            ListTile(
              leading: Icon(Icons.home, color: theme.text1Color, size:defaultHeight(context) / 25),
              title: Text(
                'Home',
                style: TextStyle(
                    color: theme.text1Color,
                    fontSize: defaultHeight(context) / 45
                ),
              ),
              onTap: () => {
                Navigator.of(context).pop(),
              },
            ),
            SizedBox(
              height: defaultHeight(context) / 100,
            ),
            ListTile(
              leading: Icon(Icons.account_circle, color: theme.text1Color, size:defaultHeight(context) / 25),
              title: Text('Profile', style: TextStyle(
                  color: theme.text1Color,
                  fontSize: defaultHeight(context) / 45
                ),
              ),
              onTap: () => {},
            ),
            SizedBox(
              height: defaultHeight(context) / 100,
            ),
            ListTile(
              leading: Icon(Icons.brush, color: theme.text1Color, size:defaultHeight(context) / 25),
              title: Text('Theme', style: TextStyle(
                  color: theme.text1Color,
                  fontSize: defaultHeight(context) / 45
                ),
              ),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ThemeSetting())).then((value) => {
                getThemeFromPreferences()
              }),
            ),
            SizedBox(
              height: defaultHeight(context) / 100,
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: theme.text1Color, size:defaultHeight(context) / 25),
              title: Text('Sign Out', style: TextStyle(
                  color: theme.text1Color,
                  fontSize: defaultHeight(context) / 45
                ),
              ),
              onTap: (){
                authentication.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
              }
            ),
            SizedBox(
              height: defaultHeight(context)/4,
            ),
            ListTile(
              leading: Icon(Icons.close, color: theme.text1Color, size:defaultHeight(context) / 25),
              title: Text('Exit', style: TextStyle(
                  color: theme.text1Color,
                  fontSize: defaultHeight(context) / 45
                ),
              ),
              onTap: () => {SystemNavigator.pop()},
            ),
          ],
        ),
      ),
    );
  }
}
