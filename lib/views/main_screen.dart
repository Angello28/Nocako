import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nocako_chatapp/components/const.dart';
import 'package:nocako_chatapp/components/responsive.dart';
import 'package:nocako_chatapp/components/theme_data.dart';
import 'package:nocako_chatapp/components/components.dart';
import 'package:nocako_chatapp/function/auth.dart';
import 'package:nocako_chatapp/function/helper.dart';
import 'package:nocako_chatapp/function/method.dart';
import 'package:nocako_chatapp/views/chat_screen.dart';
import 'package:nocako_chatapp/views/nav_drawer.dart';
import 'package:nocako_chatapp/views/search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver{

  String getId = '';
  Stream<QuerySnapshot> getMessagesStream = Stream.empty();

  Authentication authentication = new Authentication();
  Stream<QuerySnapshot> chatRoomStream = Stream.empty();

  getUserInfo() async{
    Constants.myId = (await HelperFunction.getUserIdSharedPreference())!;
    Constants.myName = (await HelperFunction.getUserNameSharedPreference())!;
    Constants.myEmail = (await HelperFunction.getUserEmailSharedPreference())!;
    Constants.myProfileImage = (await HelperFunction.getUserProfileImageSharedPreference())!;
    chatRoomStream = await UserMethod().getChatRooms(Constants.myId);
    await UserMethod().updateStatus(Constants.myId, 'online');
    setState(() {});
  }

  getThemeFromPreferences() async{
    Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    Constants.myTheme = getTheme(Constants.myThemeName);
    setState(() {});
  }

  Widget sideChatScreen(){
    if(getId == ''){
      return Container(
        color: Constants.myTheme.backgroundColor,
        height: defaultHeight(context),
        child: Center(
          child:Text('Center', style: TextStyle(color: Constants.myTheme.text1Color))
        ),
      );
    }
    else{
      return ChatScreen(
        chatRoomId: getId,
        chatRoomStream: getMessagesStream,
        chatProfileImgUrl: "",
      );
    }
  }

  @override
  void initState() {
    getUserInfo();
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async{
    super.didChangeAppLifecycleState(state);
    if(state == AppLifecycleState.resumed){
      await UserMethod().updateStatus(Constants.myId, 'online');
      setState(() {});
    }
    else{
      await UserMethod().updateStatus(Constants.myId, 'offline');
      setState(() {});
    }
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
            color: Constants.myTheme.text1Color
          )),
          backgroundColor: Constants.myTheme.primaryColor,
          iconTheme: IconThemeData(color: Constants.myTheme.text1Color),
          backwardsCompatibility: false,
          systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
        ),
        body: Stack(
          children: [
            Container(
              width: defaultWidth(context),
              height: defaultHeight(context),
              color: Constants.myTheme.backgroundColor,
            ),
            chatRoomStream != Stream.empty() ?
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
                :
            Container(
              child: Text('kosong'),
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
            child: Icon(Icons.chat, size: defaultHeight(context)/25, color: Constants.myTheme.text1Color),
            backgroundColor: Constants.myTheme.buttonColor,
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
            color: Constants.myTheme.text1Color
          )),
          backgroundColor: Constants.myTheme.primaryColor,
          iconTheme: IconThemeData(color: Constants.myTheme.text1Color),
        ),
        body: Stack(
            children: [
              Container(
                width: defaultWidth(context),
                height: defaultHeight(context),
                color: Constants.myTheme.backgroundColor,
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
            child: Icon(Icons.chat, size: defaultHeight(context)/25, color: Constants.myTheme.text1Color),
            backgroundColor: Constants.myTheme.buttonColor,
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
                    color: Constants.myTheme.text1Color
                )),
                backgroundColor: Constants.myTheme.primaryColor,
                iconTheme: IconThemeData(color: Constants.myTheme.text1Color),
              ),
              body: Stack(
                children: [
                  Container(
                    width: defaultWidth(context),
                    height: defaultHeight(context),
                    color: Constants.myTheme.backgroundColor,
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
                  child: Icon(Icons.chat, size: defaultHeight(context)/25, color: Constants.myTheme.text1Color),
                  backgroundColor: Constants.myTheme.buttonColor,
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

