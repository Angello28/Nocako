import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nocako_chatapp/components/components.dart';
import 'package:nocako_chatapp/components/theme_data.dart';
import 'package:nocako_chatapp/components/const.dart';
import 'package:nocako_chatapp/function/helper.dart';
import 'package:nocako_chatapp/function/method.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>{

  UserMethod userMethod = new UserMethod();
  SearchMethod searchMethod = new SearchMethod();
  var queryResultSet = [];
  var tempSearchStore =[];

  static String themeName = "";
  ColorTheme theme = getTheme("Default");

  getThemeFromPreferences() async{
    themeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    theme = getTheme(themeName);
    setState((){});
  }

  // ignore: non_constant_identifier_names
  Searching(String value){
    if(value.length == 0){
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }

    var keyword = value.substring(0,1) + value.substring(1);

    if(queryResultSet.length == 0 && value.length == 1){
      userMethod.getUserByUsername(value).then((QuerySnapshot snapshot){
        for (var message in snapshot.docs) {
          setState(() {
            queryResultSet.add(message.data());
          });
        }
      });
    }
    else{
      tempSearchStore =[];
      queryResultSet.forEach((element) {
        if(element['name'].startsWith(keyword)){
          setState(() {
            tempSearchStore.add(element);
          });
        }
      });
    }
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async{
    Constants.myName = (await HelperFunction.getUserNameSharedPreference())!;
  }

  @override
  Widget build(BuildContext context) {
    getThemeFromPreferences();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        iconTheme: IconThemeData(color: theme.text1Color),
        title: Text('Search', style: TextStyle(color: theme.text1Color))
      ),
      body: Container(
        color: theme.backgroundColor,
        padding: EdgeInsets.symmetric(vertical: defaultHeight(context)/50, horizontal: defaultWidth(context)/25),
        child: Column(
          children: [
            Container(
              child: TextField(
                style: TextStyle(color: theme.text2Color),
                onChanged: (val){
                  Searching(val);
                },
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: theme.borderColor)
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: theme.buttonColor)
                  ),
                  hintText: 'Search username', hintStyle: TextStyle(color: theme.text2Color)
                ),
                enabled: true,
              ),
            ),
            SizedBox(height: defaultHeight(context)/30),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: [
                      tempSearchStore.length == 0 && queryResultSet.length == 0 ?
                      Container(
                        child: Center(
                          child: Text('Search for chat',
                            style: TextStyle(
                              color: theme.text2Color
                            )
                          )
                        )
                      )
                          :
                      tempSearchStore.length == 0 && queryResultSet.length != 0 ?
                      Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: queryResultSet.length,
                          itemBuilder: (context, index){
                            return UserTile(
                              username: queryResultSet[index]['name'],
                              email: queryResultSet[index]['email'],
                              searchMethod: searchMethod
                            );
                          }
                        ),
                      )
                          :
                      Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: tempSearchStore.length,
                          itemBuilder: (context, index){
                            return UserTile(
                              username: tempSearchStore[index]['name'],
                              email: tempSearchStore[index]['email'],
                              searchMethod: searchMethod
                            );
                          }
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
