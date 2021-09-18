import 'package:cached_network_image/cached_network_image.dart';
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
  final String chatProfileImgUrl;
  final void Function(String) getChatId;
  final void Function(Stream<QuerySnapshot>) getChatStream;
  ChatRoomTile({
    required this.username, required this.chatRoomId, required this.chatProfileImgUrl,
    required this.getChatId,required this.getChatStream
  });

  @override
  _ChatRoomTileState createState() => _ChatRoomTileState();
}

class _ChatRoomTileState extends State<ChatRoomTile> {

  getThemeFromPreferences() async{
    Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    Constants.myTheme = getTheme(Constants.myThemeName);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    getThemeFromPreferences();
    return StreamBuilder<QuerySnapshot>(
        stream: UserMethod().getRecentChatMessages(widget.chatRoomId),
        builder: (context, snapshot){
          if(snapshot.hasData){
            return FutureBuilder(
              future: UserMethod().getUsernameById(widget.username),
              builder: (context, future){
                return ListTile (
                  contentPadding: EdgeInsets.symmetric(vertical: defaultHeight(context)/80, horizontal: defaultWidth(context)/20),
                  leading: Container(
                    width: defaultHeight(context)/16,
                    height: defaultHeight(context)/16,
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      maxRadius: 50,
                      minRadius: 40,
                      child: ClipOval(
                        child: widget.chatProfileImgUrl == "" ?
                        Icon(
                          Icons.account_circle,
                          color: Constants.myTheme.buttonColor,
                          size: defaultHeight(context)/16
                        )
                            :
                        CachedNetworkImage(
                          imageUrl: widget.chatProfileImgUrl,
                          placeholder: (context, url) => Container(
                            width: defaultHeight(context)/16,
                            height: defaultHeight(context)/16,
                            child: Icon(
                              Icons.account_circle,
                              color: Constants.myTheme.buttonColor,
                              size: defaultHeight(context)/16
                            )
                          ),
                          fit: BoxFit.cover,
                          width: defaultHeight(context)/16,
                          height: defaultHeight(context)/16,
                        ),
                      ),
                    ),
                  ),
                  trailing: Text(
                    FormattingMethod().recentDateMessageFormat(
                      DateTime.fromMicrosecondsSinceEpoch(snapshot.data!.docs[0]['timestamp'])
                    ),
                    style: TextStyle(
                      fontSize: defaultHeight(context)/70,
                      color: Constants.myTheme.text2Color
                    )
                  ),
                  title: Text(
                    future.data.toString(),
                    style: TextStyle(
                      fontSize: defaultHeight(context)/40,
                      color: Constants.myTheme.text2Color
                    )
                  ),
                  subtitle: Text(
                    FormattingMethod().recentMessageFormat(snapshot.data!.docs[0]['message'], snapshot.data!.docs[0]['sendBy']),
                    style: TextStyle(
                      fontSize: defaultHeight(context)/60,
                      color: Constants.myTheme.text2Color
                    )
                  ),
                  onTap: (){
                    if(Responsive.isMobile(context) || Responsive.isTablet(context)){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(
                        chatRoomId: widget.chatRoomId,
                        chatRoomStream: UserMethod().getChatMessages(widget.chatRoomId),
                        chatProfileImgUrl: widget.chatProfileImgUrl,
                      )));
                    }
                    else{
                      setState(() {
                        widget.getChatId(widget.chatRoomId);
                        widget.getChatStream(UserMethod().getChatMessages(widget.chatRoomId));
                      });
                    }
                  },
                  onLongPress: (){
                    showDialog(
                      context: context,
                      builder: (context){
                        return AlertDialog(
                          backgroundColor: Constants.myTheme.backgroundColor,
                          buttonPadding: EdgeInsets.only(right: defaultWidth(context)/10),
                          title: Text(
                            'Delete Chat (${future.data.toString()})',
                            style: TextStyle(
                              color: Constants.myTheme.text2Color
                            ),
                          ),
                          content: Text(
                            'Warning: Once you delete this chat, you can\'t recover it anymore. Are you sure want to delete this chat?',
                            style: TextStyle(
                              color: Constants.myTheme.text2Color
                            ),
                          ),
                          actions: [
                            InkWell(
                              child: Text(
                                'Delete',
                                style: TextStyle(
                                  color: Constants.myTheme.buttonColor
                                ),
                              ),
                              onTap: () {
                                UserMethod().deleteChatMessages(widget.chatRoomId);
                                Navigator.pop(context);
                              },
                            ),
                            InkWell(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Constants.myTheme.text2Color
                                ),
                              ),
                              onTap: () => Navigator.pop(context),
                            ),
                          ],
                        );
                      }
                    );
                  },
                );
              }
          );
        }
        else{
          return Container();
        }
      }
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
              return FutureBuilder(
                future: UserMethod().getProfileImageById(
                  snapshot.data!.docs[index]['chatroomid'].toString().replaceAll("_", "").replaceAll(Constants.myId, ""),
                ),
                builder: (context, future){
                  return ChatRoomTile(
                    username: snapshot.data!.docs[index]['chatroomid'].toString().replaceAll("_", "").replaceAll(Constants.myId, ""),
                    chatRoomId: snapshot.data!.docs[index]['chatroomid'],
                    chatProfileImgUrl: future.data.toString(),
                    getChatId: widget.getChatIdFromList,
                    getChatStream: widget.getStreamFromList,
                  );
                }
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

  getThemeFromPreferences() async{
    Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    Constants.myTheme = getTheme(Constants.myThemeName);
    setState(() {});
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
              color: widget.isItMe ? Constants.myTheme.text3Color : Constants.myTheme.text2Color,
              fontSize: defaultHeight(context)/80,
            ),
          ),
          SizedBox(height: defaultHeight(context)/150),
          Container(
            decoration: BoxDecoration(
              color: widget.isItMe ? Constants.myTheme.bubbleChat1 : Constants.myTheme.bubbleChat2,
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
                    color: widget.isItMe? Constants.myTheme.text1Color : Constants.myTheme.text2Color,
                    fontSize: defaultHeight(context)/45),
                ),
                SizedBox(height: defaultHeight(context)/100),
                Text(
                  DateFormat('HH:mm').format(DateTime.fromMicrosecondsSinceEpoch(widget.dateTime)).toString(),
                  style: TextStyle(
                    color: widget.isItMe ? Constants.myTheme.text1Color : Constants.myTheme.text2Color,
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
            height: defaultHeight(context)/(Responsive.isDesktop(context)? 1.28 : 1.35),
            child: ListView.builder(
              reverse: true,
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
  final String userId;
  final String username;
  final String email;
  final String profileImg;
  final SearchMethod searchMethod;
  UserTile({
    required this.userId, required this.username, required this.email,
    required this.profileImg, required this.searchMethod
  });

  @override
  _UserTileState createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> with TickerProviderStateMixin{

  getThemeFromPreferences() async{
    Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    Constants.myTheme = getTheme(Constants.myThemeName);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    getThemeFromPreferences();
    return Container(
      margin: EdgeInsets.only(bottom: defaultHeight(context)/45),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: defaultHeight(context)/16,
            height: defaultHeight(context)/16,
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              maxRadius: 50,
              minRadius: 40,
              child: ClipOval(
                child: widget.profileImg == "" ?
                Icon(
                    Icons.account_circle,
                    color: Constants.myTheme.buttonColor,
                    size: defaultHeight(context)/16
                )
                    :
                CachedNetworkImage(
                  imageUrl: widget.profileImg,
                  placeholder: (context, url) => Container(
                    width: defaultHeight(context)/16,
                    height: defaultHeight(context)/16,
                    child: Icon(
                      Icons.account_circle,
                      color: Constants.myTheme.buttonColor,
                      size: defaultHeight(context)/16
                    )
                  ),
                  fit: BoxFit.cover,
                  width: defaultHeight(context)/16,
                  height: defaultHeight(context)/16,
                ),
              ),
            ),
          ),
          Container(
            width: defaultWidth(context)/2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.username, style: TextStyle(color: Constants.myTheme.text2Color)),
                Text(widget.email, style: TextStyle(color: Constants.myTheme.text2Color)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => widget.searchMethod.StartChatting(
              userId: widget.userId,
              profileImg: widget.profileImg,
              context: context,
              tickerProvider: this
            ),
            style: ElevatedButton.styleFrom(
              primary: Constants.myTheme.buttonColor,
              textStyle: TextStyle(fontSize: defaultHeight(context)/45),
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)
              ),
              minimumSize: Size(defaultWidth(context)/5, defaultHeight(context)/20),
            ),
            child: Text('Chat', style: TextStyle(color: Constants.myTheme.text1Color))
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

  getThemeFromPreferences() async{
    Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    Constants.myTheme = getTheme(Constants.myThemeName);
    setState(() {});
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
            Constants.myTheme.primaryColor,
            Constants.myTheme.secondaryColor,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitSpinningLines(
              color: Constants.myTheme.text1Color,
              size: defaultHeight(context)/5,
            ),
            SizedBox(height: defaultHeight(context)/15),
            Text('Loading', style: TextStyle(
              color: Constants.myTheme.text1Color,
              fontSize: defaultHeight(context)/20
            )),
          ],
        )
      )
    );
  }
}
