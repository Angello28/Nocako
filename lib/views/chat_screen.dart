import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nocako_chatapp/components/const.dart';
import 'package:nocako_chatapp/components/responsive.dart';
import 'package:nocako_chatapp/components/theme_data.dart';
import 'package:nocako_chatapp/components/components.dart';
import 'package:nocako_chatapp/function/method.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final Stream<QuerySnapshot> chatRoomStream;
  ChatScreen({required this.chatRoomId, required this.chatRoomStream});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  UserMethod userMethod = new UserMethod();
  TextEditingController messageTextController = new TextEditingController();
  ScrollController scrollController = ScrollController();

  Stream<QuerySnapshot> chatMessagesStream = Stream.empty();

  static String themeName = "";
  ColorTheme theme = getTheme("Default");

  getThemeFromPreferences() async{
    themeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    theme = getTheme(themeName);
    setState((){});
  }

  // fungsi untuk mengirim pesan, implemen api disini
  // ignore: non_constant_identifier_names
  SendMessage(){
    if(messageTextController.text.isNotEmpty){
      Map<String, dynamic> messageMap = {
        'message': messageTextController.text,
        'sendBy' : Constants.myName,
        'timestamp' : DateTime.now().microsecondsSinceEpoch,
      };
      userMethod.addChatMessages(widget.chatRoomId, messageMap);
    }
    messageTextController.text = "";
  }

  // ignore: non_constant_identifier_names
  AutoScroll(ScrollController scrollController){
    WidgetsBinding.instance!.addPostFrameCallback((_){
      if(scrollController.hasClients){
        setState(() {});
        scrollController.jumpTo(
          scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AutoScroll(scrollController);
    getThemeFromPreferences();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: Responsive.isMobile(context)? true : false,
        backgroundColor: theme.primaryColor,
        iconTheme: IconThemeData(color: theme.text1Color),
        title: Text(widget.chatRoomId.replaceAll("_", "").replaceAll(Constants.myName, ""),
          style: TextStyle(color: theme.text1Color),
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: defaultWidth(context),
            height: defaultHeight(context),
            color: theme.backgroundColor,
          ),
          Container(
            height: defaultHeight(context),
            padding: EdgeInsets.symmetric(vertical: defaultHeight(context)/60, horizontal: defaultWidth(context)/35),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  MessageList(
                    chatMessagesStream: widget.chatRoomStream,
                    scrollController: scrollController,
                  ),
                  Container(
                    padding: EdgeInsets.only(top: defaultHeight(context)/60),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: messageTextController,
                            style: TextStyle(color: theme.text2Color),
                            onTap: (){AutoScroll(scrollController);},
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(50)),
                                  borderSide: BorderSide(color: theme.borderColor)
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(50)),
                                  borderSide: BorderSide(color: theme.buttonColor)
                              ),
                              hintText: 'Message', hintStyle: TextStyle(color: theme.text2Color)
                            ),
                            enabled: true,
                          ),
                        ),
                        SizedBox(width: defaultWidth(context)/50),
                        Container(
                          decoration: ShapeDecoration(
                            color: theme.buttonColor,
                            shape: CircleBorder(),
                          ),
                          child: IconButton(
                            onPressed: (){
                              SendMessage();
                              AutoScroll(scrollController);
                            },
                            icon: Icon(Icons.send, color: theme.text1Color),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

