import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nocako_chatapp/components/const.dart';
import 'package:nocako_chatapp/components/theme_data.dart';
import 'package:nocako_chatapp/function/helper.dart';
import 'package:nocako_chatapp/function/method.dart';
import 'package:nocako_chatapp/views/photo_screen.dart';

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

  bool isLoading = false;
  TextEditingController usernameTextController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    getThemeFromPreferences();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Profil', style: TextStyle(
          color: Constants.myTheme.text1Color
        )),
        backgroundColor: Constants.myTheme.primaryColor,
        iconTheme: IconThemeData(color: Constants.myTheme.text1Color),
        backwardsCompatibility: false,
        systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
      ),
      body: Container(
        height: defaultHeight(context),
        width: defaultWidth(context),
        color: Constants.myTheme.backgroundColor,
        padding: EdgeInsets.symmetric(vertical: defaultHeight(context)/20, horizontal: defaultWidth(context)/10),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                if(Constants.myProfileImage != "")
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoScreen(
                    title: 'Foto Profil',
                    imageUrl: Constants.myProfileImage,
                  )));
              },
              child: Container(
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
                    isLoading ?
                    CircularProgressIndicator(
                      backgroundColor: Colors.transparent,
                      color: Constants.myTheme.buttonColor,
                    )
                        :
                    CachedNetworkImage(
                      imageUrl: Constants.myProfileImage,
                      progressIndicatorBuilder: (context, url, downloadProgress) =>
                        CircularProgressIndicator(
                          backgroundColor: Colors.transparent,
                          color: Constants.myTheme.buttonColor,
                          value: downloadProgress.progress,
                        ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.cover,
                      width: defaultHeight(context)/5,
                      height: defaultHeight(context)/5,
                    ),
                  ),
                )
              ),
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
                            'Ganti foto profil',
                            style: TextStyle(
                              color: Constants.myTheme.text2Color
                            ),
                          ),
                          onTap: () async{
                            isLoading = true;
                            XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
                            Navigator.pop(context);
                            String path = await StorageMethod().uploadProfileImage(Constants.myId, image!);
                            await UserMethod().updateProfileImage(Constants.myId, path);
                            await HelperFunction.saveUserProfileImageSharedPreference(path);
                            setState(() {
                              Constants.myProfileImage = path;
                              isLoading = false;
                            });
                          },
                        ),
                        ListTile(
                          title: Text(
                            'Hapus foto profil',
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
              child: Text('Edit foto', style: TextStyle(
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
                trailing: InkWell(
                  onTap: () async{
                    showDialog(
                        context: context,
                        builder: (context){
                          return AlertDialog(
                            backgroundColor: Constants.myTheme.backgroundColor,
                            buttonPadding: EdgeInsets.only(right: defaultWidth(context)/10),
                            title: Text(
                              'Masukkan Nama Baru',
                              style: TextStyle(
                                color: Constants.myTheme.text2Color
                              ),
                            ),
                            content: TextField(
                              controller: usernameTextController,
                              style: TextStyle(
                                color: Constants.myTheme.text2Color
                              ),
                              decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Constants.myTheme.borderColor)
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Constants.myTheme.buttonColor)
                                ),
                              ),
                            ),
                            actions: [
                              InkWell(
                                child: Text(
                                  'Batal',
                                  style: TextStyle(
                                    color: Constants.myTheme.text2Color
                                  ),
                                ),
                                onTap: () => Navigator.pop(context),
                              ),
                              InkWell(
                                child: Text(
                                  'Ubah',
                                  style: TextStyle(
                                    color: Constants.myTheme.buttonColor
                                  ),
                                ),
                                onTap: () async{
                                  UserMethod().updateUserName(Constants.myId, usernameTextController.text);
                                  HelperFunction.saveUserNameSharedPreference(usernameTextController.text);
                                  setState(() {
                                    Constants.myName = usernameTextController.text;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        }
                    );
                  },
                  child: Icon(
                    Icons.create,
                    color: Constants.myTheme.buttonColor
                  )
                ),
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
