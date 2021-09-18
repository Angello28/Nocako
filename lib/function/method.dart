import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
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
      .doc(chatRoomId).collection('chats').orderBy('timestamp', descending: true).snapshots();
  }

  getRecentChatMessages(String chatRoomId){
    return FirebaseFirestore.instance.collection('chatroom')
      .doc(chatRoomId).collection('chats').limit(1).orderBy('timestamp', descending: true).snapshots();
  }

  addChatMessages(String chatRoomId, messageMap){
    FirebaseFirestore.instance.collection('chatroom')
        .doc(chatRoomId).collection('chats').add(messageMap).catchError((e){
      print(e.toString());
    });
  }

  deleteChatMessages(String chatRoomId){
    FirebaseFirestore.instance.collection('chatroom').doc(chatRoomId).delete().catchError((e){
      print(e);
    });
  }

  getChatRooms(String id){
    return FirebaseFirestore.instance.collection('chatroom')
      .where('users', arrayContains: id).snapshots();
  }

  getUsernameById(String id) async{
    String name = "";
    await FirebaseFirestore.instance.collection('users')
      .where('id', isEqualTo: id).get().then((value){
        name = value.docs[0]['name'];
    });
    return name;
  }

  updateProfileImage(String id, String profileImgUrl){
    FirebaseFirestore.instance.collection('users').where('id', isEqualTo: id).get().then((value) {
      return FirebaseFirestore.instance.collection('users').doc(value.docs[0].id).update({'profileImg': profileImgUrl});
    });
  }

  getProfileImageById(String id) async{
    String imgUrl = "";
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').where('id', isEqualTo: id).get();
    if(snapshot.size != 0)
      imgUrl = snapshot.docs[0]['profileImg'];
    else
      imgUrl = "";
    return imgUrl;
  }

  generateID() async{
    Random _rnd = Random();
    String getRandomID = String.fromCharCodes(Iterable.generate(
      7, (_) => charId.codeUnitAt(_rnd.nextInt(charId.length))
    ));
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('company')
        .where('name', isEqualTo: getRandomID)
        .limit(1)
        .get();
    if(result.size == 0)
      return getRandomID;
    else
      generateID();
  }
}

class StorageMethod{
  Reference storage = FirebaseStorage.instance.refFromURL('gs://nocakochatapp.appspot.com/');

  Future<String> uploadProfileImage(String id, XFile file) async{
    var storageRef = storage.child('profile/${id}_profile_image');
    var uploadTask = storageRef.putFile(File(file.path), SettableMetadata(contentType: 'image/jpeg'));
    var completedTask = await Future.value(uploadTask);
    String downloadUrl = await completedTask.ref.getDownloadURL();
    return downloadUrl;
  }
}

class SearchMethod{
  // ignore: non_constant_identifier_names
  StartChatting({required String userId, required String profileImg, required BuildContext context, required TickerProvider tickerProvider}){
    if(userId != Constants.myId){
      List<String> users = [userId, Constants.myId];
      String chatroomid = returnChatId(userId, Constants.myId);

      Map<String, dynamic> chatRoomMap = {
        "users": users,
        "chatroomid": chatroomid
      };

      UserMethod().createChatRoom(chatroomid, chatRoomMap);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatScreen(
        chatRoomId: chatroomid,
        chatRoomStream: UserMethod().getChatMessages(chatroomid),
        chatProfileImgUrl: profileImg,
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

  String returnChatId(String id1, String id2){
    int asciiId1 = asciiCount(id1);
    int asciiId2 = asciiCount(id2);
    if(asciiId1 > asciiId2)
      return '$id2\_$id1';
    else
      return '$id1\_$id2';
  }

  int asciiCount(String id){
    int total = 0;
    for(int i = 0; i < id.length; i++){
      total += id.codeUnitAt(i);
    }
    return total;
  }
}

class FormattingMethod{
  String recentMessageFormat(String message, String sender){
    String formatMessage = "";
    if(sender != Constants.myName){
      formatMessage = '$sender: $message';
    }
    else{
      formatMessage = message;
    }

    if(formatMessage.length > 35){
      formatMessage = formatMessage.substring(0, 35) + '...';
    }

    if(formatMessage.contains('\n')){
      int index = formatMessage.indexOf('\n');
      formatMessage = formatMessage.substring(0, index) + '...';
    }

    return formatMessage;
  }

  String recentDateMessageFormat(DateTime timestamp){
    if(DateTime(timestamp.year, timestamp.month, timestamp.day).difference(DateTime.now()).inDays == 0)
      return DateFormat('HH:mm').format(timestamp);
    else if(DateTime(timestamp.year, timestamp.month, timestamp.day).difference(DateTime.now()).inDays == -1)
      return 'Yesterday';
    else
      return DateFormat('dd/MM/yy').format(timestamp);
  }
}