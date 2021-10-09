import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nocako_chatapp/components/const.dart';
import 'package:nocako_chatapp/components/responsive.dart';
import 'package:nocako_chatapp/components/theme_data.dart';
import 'package:nocako_chatapp/function/method.dart';
import 'package:nocako_chatapp/views/chat_screen.dart';
import 'package:nocako_chatapp/views/photo_screen.dart';

// ignore: must_be_immutable
class ChatRoomTile extends StatefulWidget {
  final String username;
  final String chatRoomId;
  final String chatProfileImgUrl;
  final String tokenId;
  final void Function(String) getChatId;
  final void Function(Stream<QuerySnapshot>) getChatStream;
  ChatRoomTile({
    required this.username, required this.chatRoomId, required this.chatProfileImgUrl,
    required this.tokenId, required this.getChatId,required this.getChatStream
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
              if (future.hasData){
                return FutureBuilder(
                  future: UserMethod().getUsernameById(snapshot.data!.docs[0]['sendBy']),
                  builder: (context, future2) => ListTile (
                    contentPadding: EdgeInsets.symmetric(vertical: defaultHeight(context)/80, horizontal: defaultWidth(context)/20),
                    leading: InkWell(
                      onTap: (){
                        if(widget.chatProfileImgUrl != "") {
                          String url = widget.chatProfileImgUrl;
                          showGeneralDialog(
                            transitionBuilder: (context, a1, a2, widget) {
                              return Transform.scale(
                                scale: a1.value,
                                alignment: Alignment.centerLeft,
                                child: Opacity(
                                  opacity: a1.value,
                                  child: Dialog(
                                    backgroundColor: Constants.myTheme.backgroundColor,
                                    insetPadding: EdgeInsets.symmetric(vertical: defaultHeight(context)/5, horizontal: defaultWidth(context)/10),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          color: Constants.myTheme.buttonColor,
                                          width: defaultWidth(context),
                                          padding: EdgeInsets.symmetric(vertical: defaultHeight(context)/80, horizontal: defaultWidth(context)/30),
                                          child: Text(
                                            future.data.toString(),
                                            style: TextStyle(
                                              color: Constants.myTheme.text1Color,
                                              fontSize: defaultHeight(context)/40
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoScreen(
                                              title: future.data.toString(),
                                              imageUrl: url,
                                            )));
                                          },
                                          child: Container(
                                            constraints: BoxConstraints(
                                              maxHeight: defaultWidth(context)/1.25,
                                            ),
                                            child: SingleChildScrollView(
                                              child: CachedNetworkImage(
                                                imageUrl: url,
                                                progressIndicatorBuilder: (context, url, downloadProgress) =>
                                                  CircularProgressIndicator(
                                                    backgroundColor: Colors.transparent,
                                                    color: Constants.myTheme.buttonColor,
                                                    value: downloadProgress.progress,
                                                  ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ),
                              );
                            },
                            transitionDuration: Duration(milliseconds: 200),
                            barrierDismissible: true,
                            barrierLabel: '',
                            context: context,
                            pageBuilder: (context, animation1, animation2) {throw false;}
                          );
                        }
                      },
                      child: FutureBuilder(
                        future: UserMethod().getStatusById(widget.username),
                        builder: (context, future3) => Container(
                          width: defaultHeight(context)/16,
                          height: defaultHeight(context)/16,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.transparent,
                                maxRadius: 50,
                                minRadius: 40,
                                child: ClipOval(
                                  child: widget.chatProfileImgUrl == "" ?
                                  Icon(
                                    Icons.account_circle,
                                    color: Constants.myTheme.buttonColor,
                                    size: defaultHeight(context)/16,
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
                              Visibility(
                                visible: future3.data.toString() == 'online' ? true : false,
                                child: Badge(
                                  badgeColor: Colors.green,
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          FormattingMethod().recentDateMessageFormat(
                            DateTime.fromMicrosecondsSinceEpoch(snapshot.data!.docs[0]['timestamp'])
                          ),
                          style: TextStyle(
                            fontSize: defaultHeight(context)/70,
                            color: Constants.myTheme.text2Color
                          )
                        ),
                        FutureBuilder(
                          future: UserMethod().getUnreadMessage(
                            widget.chatRoomId.replaceAll("_", "").replaceAll(Constants.myId, ""),
                            widget.chatRoomId
                          ),
                          builder: (context, future3){
                            return Visibility(
                              visible: future3.data != 0 ? true : false,
                              child: Column(children: [
                                  SizedBox(height: defaultHeight(context)/200),
                                  Badge(
                                    badgeColor: Constants.myTheme.buttonColor,
                                    badgeContent: Text(
                                      future3.data.toString(),
                                      style: TextStyle(
                                        fontSize: defaultHeight(context)/70,
                                        color: Constants.myTheme.text1Color
                                      ),
                                    ),
                                    elevation: 0,
                                  ),
                                ],
                              )
                            );
                          },
                        )
                      ],
                    ),
                    title: Text(
                      future.data.toString(),
                      style: TextStyle(
                        fontSize: defaultHeight(context)/40,
                        color: Constants.myTheme.text2Color,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    subtitle: Text(
                      FormattingMethod().recentMessageFormat(snapshot.data!.docs[0]['message'], future2.data.toString()),
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
                          tokenId: widget.tokenId,
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
                                  'Cancel',
                                  style: TextStyle(
                                      color: Constants.myTheme.text2Color
                                  ),
                                ),
                                onTap: () => Navigator.pop(context),
                              ),
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
                            ],
                          );
                        }
                      );
                    },
                  )
                );
              }
              else{
                return Container();
              }
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
        if(snapshot.data!.docs.length != 0) {
          return Container(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index){
                return FutureBuilder(
                  future: UserMethod().getProfileImageById(
                    snapshot.data!.docs[index]['chatroomid'].toString().replaceAll("_", "").replaceAll(Constants.myId, ""),
                  ),
                  builder: (context, future){
                    return FutureBuilder(
                      future: UserMethod().getTokenById(
                        snapshot.data!.docs[index]['chatroomid'].toString().replaceAll("_", "").replaceAll(Constants.myId, ""),
                      ),
                      builder: (context, future2){
                        return ChatRoomTile(
                          username: snapshot.data!.docs[index]['chatroomid'].toString().replaceAll("_", "").replaceAll(Constants.myId, ""),
                          chatRoomId: snapshot.data!.docs[index]['chatroomid'],
                          chatProfileImgUrl: future.data.toString(),
                          getChatId: widget.getChatIdFromList,
                          getChatStream: widget.getStreamFromList,
                          tokenId: future2.data.toString(),
                        );
                      },
                    );
                  }
                );
              }
            ),
          );
        }
        else
          return Container(
            width: defaultWidth(context),
            height: defaultHeight(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat,
                  color: Constants.myTheme.text2Color,
                  size: defaultHeight(context)/10,
                ),
                SizedBox(height: defaultHeight(context)/50),
                Text('No Conversation',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Constants.myTheme.text2Color,
                    fontSize: defaultHeight(context)/35,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: defaultHeight(context)/50),
                Text('Start chatting with people',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Constants.myTheme.text2Color,
                    fontSize: defaultHeight(context)/60
                  ),
                ),
              ],
            ),
          );
      },
    );
  }
}

class ChatBubble extends StatefulWidget {
  final String message;
  final int dateTime;
  final bool isItMe;
  final bool isRead;
  final TickerProvider tickerProvider;
  ChatBubble({required this.message, required this.dateTime, required this.isItMe,
    required this.isRead, required this.tickerProvider
  });

  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>{

  getThemeFromPreferences() async{
    Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    Constants.myTheme = getTheme(Constants.myThemeName);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    getThemeFromPreferences();
    return Container(
      margin: EdgeInsets.symmetric(vertical: defaultHeight(context)/300),
      padding: widget.isItMe ? EdgeInsets.only(left: defaultWidth(context)/8) : EdgeInsets.only(right: defaultWidth(context)/8),
      width: defaultWidth(context),
      alignment: widget.isItMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: widget.isItMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: (){
              Clipboard.setData(ClipboardData(text: widget.message));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.black,
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Message copied to clipboard', textAlign: TextAlign.center),
                      InkWell(
                        onTap: ()=> ScaffoldMessenger.of(context).removeCurrentSnackBar(),
                        child: Icon(
                          Icons.cancel,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  behavior: SnackBarBehavior.floating,
                  elevation: 0,
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)
                  ),
                  width: defaultWidth(context)/1.4,
                  animation: CurvedAnimation(
                    parent: AnimationController(duration: const Duration(seconds: 1), vsync: widget.tickerProvider),
                    curve: Curves.linear
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: widget.isItMe ? Constants.myTheme.bubbleChat1 : Constants.myTheme.bubbleChat2,
                borderRadius: widget.isItMe ?
                BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20)
                ) :
                BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20)
                )
              ),
              padding: EdgeInsets.symmetric(
                vertical: defaultHeight(context)/100,
                horizontal: defaultWidth(context)/(defaultHeight(context)>defaultWidth(context)?20:50)
              ),
              constraints: BoxConstraints(
                maxWidth: defaultWidth(context)/1.5,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      widget.message,
                      //textAlign: widget.isItMe ? TextAlign.end : TextAlign.start,
                      style: TextStyle(
                        color: widget.isItMe? Constants.myTheme.text1Color : Constants.myTheme.text2Color,
                        fontSize: defaultHeight(context)/50),
                    ),
                  ),
                  SizedBox(width: defaultHeight(context)/100),
                  Text(
                    DateFormat('HH:mm').format(DateTime.fromMicrosecondsSinceEpoch(widget.dateTime)).toString(),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: widget.isItMe ? Constants.myTheme.text1Color : Constants.myTheme.text2Color,
                      fontSize: defaultHeight(context)/90,
                    ),
                  ),
                  SizedBox(width: defaultHeight(context)/150),
                  Visibility(
                    visible: widget.isItMe,
                    child: SvgPicture.asset(
                      widget.isRead ? 'assets/read.svg' : 'assets/delivered.svg',
                      width: defaultHeight(context)/80,
                      height: defaultHeight(context)/80,
                      color: Constants.myTheme.text1Color,
                    ),
                  )
                ],
              )
            ),
          ),
        ],
      ),
    );
  }
}

class MessageList extends StatefulWidget {
  final Stream<QuerySnapshot> chatMessagesStream;
  final ScrollController scrollController;
  final String chatRoomId;
  MessageList({required this.chatMessagesStream, required this.scrollController, required this.chatRoomId});

  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> with TickerProviderStateMixin{
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.chatMessagesStream,
      builder: (context, snapshot){
        if (snapshot.hasData) {
          return GroupedListView<QueryDocumentSnapshot, DateTime>(
            elements: snapshot.data!.docs,
            groupBy: (element) =>
              DateTime(
                DateTime.fromMicrosecondsSinceEpoch(element['timestamp']).year,
                DateTime.fromMicrosecondsSinceEpoch(element['timestamp']).month,
                DateTime.fromMicrosecondsSinceEpoch(element['timestamp']).day,
              ),
            itemComparator: (item1, item2) => item1['timestamp'].compareTo(item2['timestamp']),
            order: GroupedListOrder.DESC,
            floatingHeader: true,
            groupSeparatorBuilder: (DateTime value) => Container(
              padding: EdgeInsets.symmetric(vertical: defaultHeight(context)/100),
              margin: EdgeInsets.symmetric(vertical: defaultHeight(context)/60, horizontal: defaultWidth(context)/3.5),
              width: defaultWidth(context)/2.5,
              decoration: BoxDecoration(
                color: Constants.myTheme.buttonColor.withOpacity(0.5),
                borderRadius: BorderRadius.all(Radius.circular(50))
              ),
              child: Text(
                FormattingMethod().separatorDateFormat(value),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: defaultHeight(context)/65, color: Constants.myTheme.text1Color),
              ),
            ),
            itemBuilder: (context, element) {
              return FutureBuilder(
                future: UserMethod().updateReadMessage(
                  widget.chatRoomId.replaceAll("_", "").replaceAll(Constants.myId, ""),
                  widget.chatRoomId
                ),
                builder: (context, future){
                  return ChatBubble(
                    message: element['message'],
                    isItMe: element['sendBy'] == Constants.myId,
                    dateTime: element['timestamp'],
                    isRead: element['isRead'],
                    tickerProvider: this,
                  );
                },
              );
            },
            shrinkWrap: true,
            controller: widget.scrollController,
            reverse: true,
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
  final String tokenId;
  final SearchMethod searchMethod;
  UserTile({
    required this.userId, required this.username, required this.email,
    required this.profileImg, required this.tokenId, required this.searchMethod
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
    return ListTile(
      leading: Container(
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
      title: Text(
        widget.username,
        style: TextStyle(
          color: Constants.myTheme.text2Color,
          fontSize: defaultHeight(context)/55
        )
      ),
      subtitle: Text(
        widget.email,
        style: TextStyle(
          color: Constants.myTheme.text2Color,
          fontSize: defaultHeight(context)/55
        )
      ),
      onTap: (){
        widget.searchMethod.StartChatting(
          userId: widget.userId,
          profileImg: widget.profileImg,
          context: context,
          tokenId: widget.tokenId,
          tickerProvider: this
        );
      },
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
