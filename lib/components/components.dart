import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nocako_chatapp/components/const.dart';
import 'package:nocako_chatapp/components/responsive.dart';
import 'package:nocako_chatapp/components/theme_data.dart';
import 'package:nocako_chatapp/function/method.dart';
import 'package:nocako_chatapp/views/chat_screen.dart';

// ignore: must_be_immutable
class ChatRoomTile extends StatefulWidget {
  final String username;
  final String chatRoomId;
  final void Function(String) getChatId;
  final void Function(Stream<QuerySnapshot>) getChatStream;
  ChatRoomTile({required this.username, required this.chatRoomId, required this.getChatId,required this.getChatStream});

  @override
  _ChatRoomTileState createState() => _ChatRoomTileState();
}

class _ChatRoomTileState extends State<ChatRoomTile> {
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
    return InkWell(
      onTap: (){
        if(Responsive.isMobile(context) || Responsive.isTablet(context)){
          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(
            chatRoomId: widget.chatRoomId,
            chatRoomStream: UserMethod().getChatMessages(widget.chatRoomId),
          )));
        }
        else{
          setState(() {
            widget.getChatId(widget.chatRoomId);
            widget.getChatStream(UserMethod().getChatMessages(widget.chatRoomId));
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: defaultHeight(context)/50,
          horizontal: defaultWidth(context)/defaultWidth(context) < defaultHeight(context) ? 20 : 50),
        child: Row(
          children: [
            Container(
              width: defaultHeight(context)/16,
              height: defaultHeight(context)/16,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: theme.buttonColor,
                  borderRadius: BorderRadius.circular(40)
              ),
              child: Text("${widget.username.substring(0,1).toUpperCase()}",
                  style: TextStyle(fontSize: defaultHeight(context)/40, color: theme.text1Color)
              ),
            ),
            SizedBox(width: defaultWidth(context)/defaultWidth(context) < defaultHeight(context) ? 20 : 50),
            Text(widget.username, style: TextStyle(fontSize: defaultHeight(context)/40, color: theme.text2Color))
          ],
        ),
      ),
    );
  }
}

class ChatRoomList extends StatefulWidget {
  final Stream<QuerySnapshot> chatRoomStream;
  final void Function(String) getChatIdFromList;
  final void Function(Stream<QuerySnapshot>) getStreamFromList;
  ChatRoomList({required this.chatRoomStream, required this.getChatIdFromList, required this.getStreamFromList});

  @override
  _ChatRoomListState createState() => _ChatRoomListState();
}

class _ChatRoomListState extends State<ChatRoomList> {
  static String themeName = "";
  ColorTheme theme = getTheme("Default");

  getThemeFromPreferences() async{
    themeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    theme = getTheme(themeName);
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.chatRoomStream,
      builder: (context, snapshot){
        return snapshot.hasData ? Container(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index){
              return ChatRoomTile(
                username: snapshot.data!.docs[index]['chatroomid'].toString().replaceAll("_", "").replaceAll(Constants.myName, ""),
                chatRoomId: snapshot.data!.docs[index]['chatroomid'],
                getChatId: widget.getChatIdFromList,
                getChatStream: widget.getStreamFromList,
              );
            }
          ),
        ) : Container();
      },
    );
  }
}

class ChatBubble extends StatefulWidget {
  final String message;
  final int dateTime;
  final bool isItMe;
  ChatBubble({required this.message, required this.dateTime, required this.isItMe});

  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: defaultHeight(context)/100),
      padding: widget.isItMe ? EdgeInsets.only(left: defaultWidth(context)/8) : EdgeInsets.only(right: defaultWidth(context)/8),
      width: defaultWidth(context),
      alignment: widget.isItMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: widget.isItMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('MMM dd, yyyy').format(DateTime.fromMicrosecondsSinceEpoch(widget.dateTime)).toString(),
            style: TextStyle(
              color: widget.isItMe ? theme.text3Color : theme.text2Color,
              fontSize: defaultHeight(context)/80,
            ),
          ),
          SizedBox(height: defaultHeight(context)/150),
          Container(
            decoration: BoxDecoration(
              color: widget.isItMe ? theme.bubbleChat1 : theme.bubbleChat2,
              borderRadius: widget.isItMe ?
              BorderRadius.only(
                topLeft: Radius.circular(25),
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)
              ) :
              BorderRadius.only(
                topRight: Radius.circular(25),
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)
              )
            ),
            padding: EdgeInsets.symmetric(
                vertical: defaultHeight(context)/80,
                horizontal: defaultWidth(context)/(defaultHeight(context)>defaultWidth(context)?20:50)
            ),
            child: Column(
              crossAxisAlignment: widget.isItMe? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  widget.message,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: widget.isItMe? theme.text1Color : theme.text2Color,
                    fontSize: defaultHeight(context)/45),
                ),
                SizedBox(height: defaultHeight(context)/100),
                Text(
                  DateFormat('HH:mm').format(DateTime.fromMicrosecondsSinceEpoch(widget.dateTime)).toString(),
                  style: TextStyle(
                    color: widget.isItMe ? theme.text1Color : theme.text2Color,
                    fontSize: defaultHeight(context)/80
                  ),
                )
              ],
            )
          ),
        ],
      ),
    );
  }
}

class MessageList extends StatefulWidget {
  final Stream<QuerySnapshot> chatMessagesStream;
  final ScrollController scrollController;
  MessageList({required this.chatMessagesStream, required this.scrollController});

  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: widget.chatMessagesStream,
        builder: (context, snapshot){
          if (snapshot.hasData) {
            return Container(
              height: defaultHeight(context)/ 1.28,
              child: ListView.builder(
                shrinkWrap: true,
                controller: widget.scrollController,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index){
                  return ChatBubble(
                    message: snapshot.data!.docs[index]['message'],
                    isItMe: snapshot.data!.docs[index]['sendBy'] == Constants.myName,
                    dateTime: snapshot.data!.docs[index]['timestamp'],
                  );
                },
              ),
            );
          }
          else
            return Container(height: defaultHeight(context)/1.4);
        }
    );
  }
}

class UserTile extends StatefulWidget {
  final String username;
  final String email;
  final SearchMethod searchMethod;
  UserTile({required this.username, required this.email, required this.searchMethod});

  @override
  _UserTileState createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> with TickerProviderStateMixin{
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
    return Container(
      margin: EdgeInsets.only(bottom: defaultHeight(context)/45),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.username, style: TextStyle(color: theme.text2Color)),
              Text(widget.email, style: TextStyle(color: theme.text2Color)),
            ],
          ),
          ElevatedButton(
              onPressed: () => widget.searchMethod.StartChatting(
                username: widget.username,
                context: context,
                tickerProvider: this),
              style: ElevatedButton.styleFrom(
                primary: theme.buttonColor,
                textStyle: TextStyle(fontSize: defaultHeight(context)/45),
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)
                ),
                minimumSize: Size(defaultWidth(context)/5, defaultHeight(context)/20),
              ),
              child: Text('Chat', style: TextStyle(color: theme.text1Color))
          )
        ],
      ),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
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
    return Container(
      width: defaultWidth(context),
      height: defaultHeight(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            theme.primaryColor,
            theme.secondaryColor,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitSpinningLines(
              color: theme.text1Color,
              size: defaultHeight(context)/5,
            ),
            SizedBox(height: defaultHeight(context)/15),
            Text('Loading', style: TextStyle(
              color: theme.text1Color,
              fontSize: defaultHeight(context)/20
            )),
          ],
        )
      )
    );
  }
}
