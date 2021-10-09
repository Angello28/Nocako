import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nocako_chatapp/components/const.dart';
import 'package:nocako_chatapp/components/theme_data.dart';
import 'package:nocako_chatapp/function/auth.dart';
import 'package:nocako_chatapp/function/helper.dart';
import 'package:nocako_chatapp/function/method.dart';
import 'package:nocako_chatapp/views/profile_screen.dart';
import 'package:nocako_chatapp/views/sign_in.dart';
import 'package:nocako_chatapp/views/theme_setting.dart';

// ignore: must_be_immutable
class NavDrawer extends StatefulWidget {
  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  Authentication authentication = new Authentication();

  getThemeFromPreferences() async{
    Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    Constants.myTheme = getTheme(Constants.myThemeName);
    setState(() {});
  }


  getProfileImage() async{
    Constants.myProfileImage = (await HelperFunction.getUserProfileImageSharedPreference())!;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getProfileImage();
    getThemeFromPreferences();
    return Drawer(
      child: Container(
        padding: EdgeInsets.only(left: defaultHeight(context) / 70, right: defaultHeight(context) / 70, top: defaultHeight(context) / 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              Constants.myTheme.secondaryColor,
              Constants.myTheme.primaryColor,
            ],
          ),
        ),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: defaultHeight(context)/50),
              height: defaultHeight(context) / 5,
              width: defaultWidth(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: defaultHeight(context)/40),
                  Container(
                    width: defaultHeight(context)/10,
                    height: defaultHeight(context)/10,
                    child: CircleAvatar(
                      maxRadius: 50,
                      minRadius: 40,
                      backgroundColor: Colors.transparent,
                      child: ClipOval(
                        child: Constants.myProfileImage == "" ?
                        Icon(
                          Icons.account_circle,
                          color: Constants.myTheme.buttonColor == Constants.myTheme.primaryColor ?
                            Colors.white : Constants.myTheme.buttonColor,
                          size: defaultHeight(context)/10
                        )
                            :
                        CachedNetworkImage(
                          imageUrl: Constants.myProfileImage,
                          placeholder: (context, url) => Icon(
                            Icons.account_circle,
                            color: Constants.myTheme.buttonColor == Constants.myTheme.primaryColor ?
                              Colors.white : Constants.myTheme.buttonColor,
                            size: defaultHeight(context)/10
                          ),
                          fit: BoxFit.cover,
                          width: defaultHeight(context)/10,
                          height: defaultHeight(context)/10,
                        ),
                      )
                    ),
                  ),
                  SizedBox(height: defaultHeight(context)/45),
                  Row(
                    children: [
                      SizedBox(width: defaultWidth(context)/100),
                      Text(Constants.myName, style: TextStyle(
                          color: Constants.myTheme.text1Color,
                          fontSize: defaultHeight(context) / 50
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: defaultWidth(context)/100),
                      Text(Constants.myEmail, style: TextStyle(
                          color: Constants.myTheme.text1Color,
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
              color: Constants.myTheme.text1Color,
            ),
            ListTile(
              leading: Icon(Icons.home, color: Constants.myTheme.text1Color, size:defaultHeight(context) / 25),
              title: Text(
                'Home',
                style: TextStyle(
                    color: Constants.myTheme.text1Color,
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
              leading: Icon(Icons.account_circle, color: Constants.myTheme.text1Color, size:defaultHeight(context) / 25),
              title: Text('Profile', style: TextStyle(
                  color: Constants.myTheme.text1Color,
                  fontSize: defaultHeight(context) / 45
                ),
              ),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Profile())),
            ),
            SizedBox(
              height: defaultHeight(context) / 100,
            ),
            ListTile(
              leading: Icon(Icons.brush, color: Constants.myTheme.text1Color, size:defaultHeight(context) / 25),
              title: Text('Theme', style: TextStyle(
                  color: Constants.myTheme.text1Color,
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
              leading: Icon(Icons.exit_to_app, color: Constants.myTheme.text1Color, size:defaultHeight(context) / 25),
              title: Text('Sign Out', style: TextStyle(
                  color: Constants.myTheme.text1Color,
                  fontSize: defaultHeight(context) / 45
                ),
              ),
              onTap: () async{
                authentication.signOut();
                await UserMethod().updateStatus(Constants.myId, 'offline');
                await UserMethod().updateToken(Constants.myId, '');
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
              }
            ),
          ],
        ),
      ),
    );
  }
}
