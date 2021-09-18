import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
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
  final String chatProfileImgUrl;
  ChatScreen({required this.chatRoomId, required this.chatRoomStream, required this.chatProfileImgUrl});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  UserMethod userMethod = new UserMethod();
  TextEditingController messageTextController = new TextEditingController();
  ScrollController scrollController = ScrollController();

  Stream<QuerySnapshot> chatMessagesStream = Stream.empty();

  getThemeFromPreferences() async{
    Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    Constants.myTheme = getTheme(Constants.myThemeName);
    setState(() {});
  }

  // fungsi untuk mengirim pesan, implemen api disini
  // ignore: non_constant_identifier_names
  SendMessage(){
    if(messageTextController.text.isNotEmpty && messageTextController.text.trim().length > 0){
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
          scrollController.position.minScrollExtent,
        );
      }
    });
  }

  @override
  void initState() {
    AutoScroll(scrollController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getThemeFromPreferences();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: Responsive.isMobile(context)? true : false,
        backgroundColor: Constants.myTheme.primaryColor,
        iconTheme: IconThemeData(color: Constants.myTheme.text1Color),
        title: FutureBuilder(
          future: UserMethod().getUsernameById(widget.chatRoomId.replaceAll("_", "").replaceAll(Constants.myId, "")),
          builder: (context, future){
            return Row(
              children: [
                Container(
                  width: defaultHeight(context)/20,
                  height: defaultHeight(context)/20,
                  child: CircleAvatar(
                    maxRadius: 50,
                    minRadius: 40,
                    backgroundColor: Colors.transparent,
                    child: ClipOval(
                      child: widget.chatProfileImgUrl == "" ?
                      Icon(
                        Icons.account_circle,
                        color: Constants.myTheme.buttonColor == Constants.myTheme.primaryColor ?
                          Colors.white : Constants.myTheme.buttonColor,
                        size: defaultHeight(context)/20
                      )
                          :
                      CachedNetworkImage(
                        imageUrl: widget.chatProfileImgUrl,
                        placeholder: (context, url) => Icon(
                          Icons.account_circle,
                          color: Constants.myTheme.buttonColor == Constants.myTheme.primaryColor ?
                            Colors.white : Constants.myTheme.buttonColor,
                          size: defaultHeight(context)/20
                        ),
                        fit: BoxFit.cover,
                        width: defaultHeight(context)/20,
                        height: defaultHeight(context)/20,
                      ),
                    ),
                  )
                ),
                SizedBox(width: defaultWidth(context)/30),
                Text(future.data.toString(),
                  style: TextStyle(color: Constants.myTheme.text1Color),
                ),
              ],
            );
          }
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: defaultWidth(context),
            height: defaultHeight(context),
            color: Constants.myTheme.backgroundColor,
          ),
          Container(
            height: defaultHeight(context),
            padding: EdgeInsets.symmetric(vertical: defaultHeight(context)/60, horizontal: defaultWidth(context)/35),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
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
                            minLines: 1,
                            maxLines: 4,
                            controller: messageTextController,
                            style: TextStyle(color: Constants.myTheme.text2Color),
                            onTap: (){AutoScroll(scrollController);},
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(30)),
                                borderSide: BorderSide(color: Constants.myTheme.borderColor)
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(30)),
                                borderSide: BorderSide(color: Constants.myTheme.buttonColor)
                              ),
                              hintText: 'Message', hintStyle: TextStyle(color: Constants.myTheme.text2Color)
                            ),
                            enabled: true,
                          ),
                        ),
                        SizedBox(width: defaultWidth(context)/50),
                        Container(
                          decoration: ShapeDecoration(
                            color: Constants.myTheme.buttonColor,
                            shape: CircleBorder(),
                          ),
                          child: IconButton(
                            onPressed: (){
                              SendMessage();
                              AutoScroll(scrollController);
                            },
                            icon: Icon(Icons.send, color: Constants.myTheme.text1Color),
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

