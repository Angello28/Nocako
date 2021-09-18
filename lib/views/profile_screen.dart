import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nocako_chatapp/components/const.dart';
import 'package:nocako_chatapp/components/theme_data.dart';
import 'package:nocako_chatapp/function/helper.dart';
import 'package:nocako_chatapp/function/method.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  getThemeFromPreferences() async{
    Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    Constants.myTheme = getTheme(Constants.myThemeName);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    getThemeFromPreferences();
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(
          color: Constants.myTheme.text1Color
        )),
        backgroundColor: Constants.myTheme.primaryColor,
        iconTheme: IconThemeData(color: Constants.myTheme.text1Color),
      ),
      body: Container(
        height: defaultHeight(context),
        width: defaultWidth(context),
        color: Constants.myTheme.backgroundColor,
        padding: EdgeInsets.symmetric(vertical: defaultHeight(context)/20, horizontal: defaultWidth(context)/10),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: defaultHeight(context)/5,
              height: defaultHeight(context)/5,
              child: CircleAvatar(
                maxRadius: 50,
                minRadius: 40,
                backgroundColor: Colors.transparent,
                child: ClipOval(
                  child: Constants.myProfileImage == "" ?
                  Icon(
                    Icons.account_circle,
                    color: Constants.myTheme.buttonColor,
                    size: defaultHeight(context)/5
                  )
                      :
                  CachedNetworkImage(
                    imageUrl: Constants.myProfileImage,
                    placeholder: (context, url) => CircularProgressIndicator(
                      backgroundColor: Colors.transparent,
                      color: Constants.myTheme.buttonColor,
                    ),
                    fit: BoxFit.cover,
                    width: defaultHeight(context)/5,
                    height: defaultHeight(context)/5,
                  ),
                ),
              )
            ),
            SizedBox(height: defaultHeight(context)/40),
            InkWell(
              onTap: () async{
                showMaterialModalBottomSheet(
                  backgroundColor: Constants.myTheme.backgroundColor,
                  context: context,
                  builder: (context){
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text(
                            'Change Profile Picture',
                            style: TextStyle(
                              color: Constants.myTheme.text2Color
                            ),
                          ),
                          onTap: () async{
                            XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
                            Navigator.pop(context);
                            String path = await StorageMethod().uploadProfileImage(Constants.myId, image!);
                            await UserMethod().updateProfileImage(Constants.myId, path);
                            await HelperFunction.saveUserProfileImageSharedPreference(path);
                            setState(() {
                              Constants.myProfileImage = path;
                            });
                          },
                        ),
                        ListTile(
                          title: Text(
                            'Delete Profile Picture',
                            style: TextStyle(
                              color: Constants.myTheme.text2Color
                            ),
                          ),
                          onTap: () async{
                            await UserMethod().updateProfileImage(Constants.myId, "");
                            await HelperFunction.saveUserProfileImageSharedPreference("");
                            setState(() {
                              Constants.myProfileImage = "";
                            });
                            Navigator.pop(context);
                          },
                        )
                      ],
                    );
                  }
                );
              },
              child: Text('Edit Photo', style: TextStyle(
                color: Constants.myTheme.buttonColor,
                fontSize: defaultHeight(context)/50,
              )),
            ),
            Divider(
              thickness: 1.5,
              height: defaultHeight(context)/15,
              color: Constants.myTheme.text2Color,
            ),
            Container(
              width: defaultWidth(context)/1.2,
              child: ListTile(
                leading: Icon(Icons.bookmark, color: Constants.myTheme.text2Color, size: defaultHeight(context)/20),
                title: Text(Constants.myId, style: TextStyle(
                  color: Constants.myTheme.text2Color,
                  fontSize: defaultHeight(context)/45
                )),
              ),
            ),
            Container(
              width: defaultWidth(context)/1.2,
              child: ListTile(
                leading: Icon(Icons.account_circle, color: Constants.myTheme.text2Color, size: defaultHeight(context)/20),
                title: Text(Constants.myName, style: TextStyle(
                  color: Constants.myTheme.text2Color,
                  fontSize: defaultHeight(context)/45
                )),
              ),
            ),
            Container(
              width: defaultWidth(context)/1.2,
              child: ListTile(
                leading: Icon(Icons.mail, color: Constants.myTheme.text2Color, size: defaultHeight(context)/20),
                title: Text(Constants.myEmail, style: TextStyle(
                  color: Constants.myTheme.text2Color,
                  fontSize: defaultHeight(context)/45
                )),
              ),
            ),
          ],
        ),
      )
    );
  }
}
