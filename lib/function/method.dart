import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nocako_chatapp/components/const.dart';
import 'package:nocako_chatapp/views/chat_screen.dart';

class UserMethod{
  getUserByUsername(String username){
    return FirebaseFirestore.instance.collection('users')
    .where('searchkey',
      isEqualTo : username.substring(0, 1)
    )
        .get();
  }

  getUserByUserEmail(String email){
    return FirebaseFirestore.instance.collection('users')
      .where('email',
      isEqualTo : email
    )
      .get()
      .catchError((e) {
        print(e.toString());
    });
  }

  uploadUserInfo(userMap){
    FirebaseFirestore.instance.collection('users').add(userMap);
  }

  createChatRoom(String chatRoomId, chatRoomMap){
    FirebaseFirestore.instance.collection('chatroom')
      .doc(chatRoomId).set(chatRoomMap).catchError((e){
        print(e.toString());
    });
  }

  getChatMessages(String chatRoomId){
    return FirebaseFirestore.instance.collection('chatroom')
      .doc(chatRoomId).collection('chats').orderBy('timestamp', descending: false).snapshots();
  }

  addChatMessages(String chatRoomId, messageMap){
    FirebaseFirestore.instance.collection('chatroom')
        .doc(chatRoomId).collection('chats').add(messageMap).catchError((e){
      print(e.toString());
    });
  }

  getChatRooms(String username){
    return FirebaseFirestore.instance.collection('chatroom')
        .where('users', arrayContains: username).snapshots();
  }
}

class SearchMethod{
  // ignore: non_constant_identifier_names
  StartChatting({required String username, required BuildContext context, required TickerProvider tickerProvider}){
    if(username != Constants.myName){
      List<String> users = [username, Constants.myName];
      String chatroomid = getChatRoomId(username, Constants.myName);

      Map<String, dynamic> chatRoomMap = {
        "users": users,
        "chatroomid": chatroomid
      };

      UserMethod().createChatRoom(chatroomid, chatRoomMap);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatScreen(
        chatRoomId: chatroomid,
        chatRoomStream: UserMethod().getChatMessages(chatroomid),
      )));
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('You can\'t chat yourself', textAlign: TextAlign.center),
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0)
          ),
          width: defaultWidth(context)/2,
          animation: CurvedAnimation(
            parent: AnimationController(duration: const Duration(seconds: 1), vsync: tickerProvider),
            curve: Curves.linear
          ),
        ),
      );
    }
  }

  getChatRoomId(String uname, String uname2){
    if(uname.substring(0, 1).codeUnitAt(0) > uname2.substring(0, 1).codeUnitAt(0)){
      return '$uname2\_$uname';
    }
    else
      return '$uname\_$uname2';
  }
}