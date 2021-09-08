import 'package:flutter/material.dart';
import 'package:nocako_chatapp/components/const.dart';
import 'package:nocako_chatapp/components/theme_data.dart';

class ThemeSetting extends StatefulWidget {
  const ThemeSetting({Key? key}) : super(key: key);

  @override
  _ThemeSettingState createState() => _ThemeSettingState();
}

class _ThemeSettingState extends State<ThemeSetting> {
  List<String> themeList = ["Default", "Dark", "Lofi"];

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Theme', style: TextStyle(
          color: theme.text1Color
        )),
        backgroundColor: theme.primaryColor,
        iconTheme: IconThemeData(color: theme.text1Color),
      ),
      body: Container(
        height: defaultHeight(context),
        width: defaultWidth(context),
        color: theme.backgroundColor,
        child: ListView.builder(
          itemCount: themeList.length,
          shrinkWrap: true,
          itemBuilder: (context, index){
            return ListTile(
              onTap: (){
                setState((){
                  ThemeGetterAndSetter.setThemeSharedPreferences(themeList[index]);
                });
              },
              trailing: Radio(
                value: themeList[index],
                groupValue: themeName == "" ? 'Default' : themeName,
                onChanged: (val) {
                  setState((){
                    ThemeGetterAndSetter.setThemeSharedPreferences(themeList[index]);
                  });
                },
                activeColor: theme.buttonColor,
              ),
              title: Text(themeList[index],
                style: TextStyle(
                  color: theme.text2Color
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}
