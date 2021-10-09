import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:nocako_chatapp/components/const.dart';
import 'package:nocako_chatapp/components/theme_data.dart';

class ThemeSetting extends StatefulWidget {
  const ThemeSetting({Key? key}) : super(key: key);

  @override
  _ThemeSettingState createState() => _ThemeSettingState();
}

class _ThemeSettingState extends State<ThemeSetting> {
  List<String> themeList = ["Default", "Dark", "Lofi", "Neon"];

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
        title: Text('Theme', style: TextStyle(
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
        child: ListView.builder(
          itemCount: themeList.length,
          shrinkWrap: true,
          itemBuilder: (context, index){
            return ListTile(
              onTap: () async{
                setState((){
                  ThemeGetterAndSetter.setThemeSharedPreferences(themeList[index]);
                });
                Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
                Constants.myTheme = getTheme(Constants.myThemeName);
              },
              trailing: Radio(
                value: themeList[index],
                groupValue: Constants.myThemeName == "" ? 'Default' : Constants.myThemeName,
                onChanged: (val) async{
                  setState((){
                    ThemeGetterAndSetter.setThemeSharedPreferences(themeList[index]);
                  });
                  Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
                  Constants.myTheme = getTheme(Constants.myThemeName);
                },
                activeColor: Constants.myTheme.buttonColor,
              ),
              title: Text(themeList[index],
                style: TextStyle(
                  color: Constants.myTheme.text2Color
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}
