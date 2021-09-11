import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nocako_chatapp/components/const.dart';
import 'package:nocako_chatapp/components/responsive.dart';
import 'package:nocako_chatapp/components/theme_data.dart';
import 'package:nocako_chatapp/components/components.dart';
import 'package:nocako_chatapp/function/auth.dart';
import 'package:nocako_chatapp/function/helper.dart';
import 'package:nocako_chatapp/function/method.dart';
import 'package:nocako_chatapp/views/chat_screen.dart';
import 'package:nocako_chatapp/views/nav_drawer.dart';
import 'package:nocako_chatapp/views/search_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  String getId = '';
  Stream<QuerySnapshot> getMessagesStream = Stream.empty();

  Authentication authentication = new Authentication();
  UserMethod userMethod = new UserMethod();
  Stream<QuerySnapshot> chatRoomStream = Stream.empty();

  static String themeName = "";
  ColorTheme theme = getTheme("Default");

  getThemeFromPreferences() async{
    themeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    theme = getTheme(themeName);
    setState((){});
  }

  getUserInfo() async{
    Constants.myName = (await HelperFunction.getUserNameSharedPreference())!;
    Constants.myEmail = (await HelperFunction.getUserEmailSharedPreference())!;
    setState(() {
      chatRoomStream = userMethod.getChatRooms(Constants.myName);
    });
  }

  Widget sideChatScreen(){
    if(getId == ''){
      return Container(
        color: theme.backgroundColor,
        height: defaultHeight(context),
        child: Center(
          child:Text('Center', style: TextStyle(color: theme.text1Color))
        ),
      );
    }
    else{
      return ChatScreen(chatRoomId: getId, chatRoomStream: getMessagesStream);
    }
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getThemeFromPreferences();
    return Responsive(
      mobile: Scaffold(
        drawer: NavDrawer(),
        onDrawerChanged: (bool isOpened)=>{
          getThemeFromPreferences()
        },
        appBar: AppBar(
          title: Text('Nocako', style: TextStyle(
              color: theme.text1Color
          )),
          backgroundColor: theme.primaryColor,
          iconTheme: IconThemeData(color: theme.text1Color),
        ),
        body: Stack(
            children: [
              Container(
                width: defaultWidth(context),
                height: defaultHeight(context),
                color: theme.backgroundColor,
              ),
              ChatRoomList(
                chatRoomStream: chatRoomStream,
                getChatIdFromList: (id){
                  getId = id;
                  setState(() {});
                },
                getStreamFromList: (stream){
                  setState(() {
                    getMessagesStream = stream;
                  });
                },
              )
            ]
        ),
        floatingActionButton: Container(
          margin: EdgeInsets.only(right: defaultWidth(context)/30, bottom: defaultHeight(context)/60),
          width: defaultWidth(context)/5,
          height: defaultHeight(context)/11,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Search()));
            },
            child: Icon(Icons.chat, size: defaultHeight(context)/25, color: theme.text1Color),
            backgroundColor: theme.buttonColor,
          ),
        ),
      ),
      tablet: Scaffold(
        drawer: NavDrawer(),
        onDrawerChanged: (bool isOpened)=>{
          getThemeFromPreferences()
        },
        appBar: AppBar(
          title: Text('Nocako', style: TextStyle(
              color: theme.text1Color
          )),
          backgroundColor: theme.primaryColor,
          iconTheme: IconThemeData(color: theme.text1Color),
        ),
        body: Stack(
            children: [
              Container(
                width: defaultWidth(context),
                height: defaultHeight(context),
                color: theme.backgroundColor,
              ),
              ChatRoomList(
                chatRoomStream: chatRoomStream,
                getChatIdFromList: (id){
                  getId = id;
                  setState(() {});
                },
                getStreamFromList: (stream){
                  setState(() {
                    getMessagesStream = stream;
                  });
                },
              )
            ]
        ),
        floatingActionButton: Container(
          margin: EdgeInsets.only(right: defaultWidth(context)/30, bottom: defaultHeight(context)/60),
          width: defaultWidth(context)/5,
          height: defaultHeight(context)/11,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Search()));
            },
            child: Icon(Icons.chat, size: defaultHeight(context)/25, color: theme.text1Color),
            backgroundColor: theme.buttonColor,
          ),
        ),
      ),
      desktop: Row(
        children: [
          Expanded(
            flex: 1,
            child: Scaffold(
              drawer: NavDrawer(),
              onDrawerChanged: (bool isOpened)=>{
                getThemeFromPreferences()
              },
              appBar: AppBar(
                title: Text('Nocako', style: TextStyle(
                    color: theme.text1Color
                )),
                backgroundColor: theme.primaryColor,
                iconTheme: IconThemeData(color: theme.text1Color),
              ),
              body: Stack(
                children: [
                  Container(
                    width: defaultWidth(context),
                    height: defaultHeight(context),
                    color: theme.backgroundColor,
                  ),
                  ChatRoomList(
                    chatRoomStream: chatRoomStream,
                    getChatIdFromList: (id){
                      setState(() {
                        getId = id;
                      });
                    },
                    getStreamFromList: (stream){
                      setState(() {
                        getMessagesStream = stream;
                      });
                    },
                  )
                ]
              ),
              floatingActionButton: Container(
                margin: EdgeInsets.only(left: defaultWidth(context)/5),
                width: defaultWidth(context)/5,
                height: defaultHeight(context)/11,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Search()));
                  },
                  child: Icon(Icons.chat, size: defaultHeight(context)/25, color: theme.text1Color),
                  backgroundColor: theme.buttonColor,
                ),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            ),
          ),
          Expanded(
            flex: 3,
            child: sideChatScreen()
          ),
        ],
      )
    );
  }
}

