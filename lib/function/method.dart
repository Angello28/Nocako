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

  getChatMessages(String chatRoomId){
    return FirebaseFirestore.instance.collection('chatroom')
        .doc(chatRoomId).collection('chats').orderBy('timestamp', descending: true).snapshots();
  }

  getRecentChatMessages(String chatRoomId){
    return FirebaseFirestore.instance.collection('chatroom')
        .doc(chatRoomId).collection('chats').limit(1).orderBy('timestamp', descending: true).snapshots();
  }

  getEmptyChatRoom(String chatRoomId){
    return FirebaseFirestore.instance.collection('chatroom')
      .doc(chatRoomId).collection('chats').limit(1).orderBy('timestamp', descending: true).get();
  }

  getChatRooms(String id){
    return FirebaseFirestore.instance.collection('chatroom')
      .where('users', arrayContains: id)
      .orderBy('recentTimeStamp', descending: true)
      .snapshots();
  }

  getUsernameById(String id) async{
    String name = "";
    await FirebaseFirestore.instance.collection('users')
      .where('id', isEqualTo: id).get().then((value){
        name = value.docs[0]['name'];
    });
    return name;
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

  getTokenById(String id) async{
    String token = "";
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').where('id', isEqualTo: id).get();
    if(snapshot.size != 0)
      token = snapshot.docs[0]['tokenId'];
    else
      token = "";
    return token;
  }

  getStatusById(String id) async{
    String status = "";
    await FirebaseFirestore.instance.collection('users')
        .where('id', isEqualTo: id).get().then((value){
      status = value.docs[0]['status'];
    });
    return status;
  }

  uploadUserInfo(userMap){
    FirebaseFirestore.instance.collection('users').add(userMap);
  }
  
  getUnreadMessage(String id, String chatRoomId) async{
    int count = 0;
    await FirebaseFirestore.instance.collection('chatroom').doc(chatRoomId).collection('chats')
      .where('sendBy', isEqualTo: id)
      .where('isRead', isEqualTo: false).get().then((value){
        count = value.size;
    });
    return count;
  }

  createChatRoom(String chatRoomId, chatRoomMap){
    FirebaseFirestore.instance.collection('chatroom')
      .doc(chatRoomId).get().then((value){
        if(!value.exists){
          FirebaseFirestore.instance.collection('chatroom')
            .doc(chatRoomId).set(chatRoomMap).catchError((e){
              print(e.toString());
          });
        }
        else{
          FirebaseFirestore.instance.collection('chatroom')
              .doc(chatRoomId).update(chatRoomMap).catchError((e){
            print(e.toString());
          });
        }
    });
  }

  addChatMessages(String chatRoomId, messageMap){
    FirebaseFirestore.instance.collection('chatroom')
        .doc(chatRoomId).collection('chats').add(messageMap).catchError((e){
      print(e.toString());
    });
    FirebaseFirestore.instance.collection('chatroom')
        .doc(chatRoomId).update({'recentTimeStamp': messageMap['timestamp']});
  }

  deleteChatMessages(String chatRoomId){
    FirebaseFirestore.instance.collection('chatroom').doc(chatRoomId).collection('chats').get().then((value) {
      for(DocumentSnapshot ds in value.docs){
        ds.reference.delete();
      }
    });
    FirebaseFirestore.instance.collection('chatroom').doc(chatRoomId).delete();
  }

  updateProfileImage(String id, String profileImgUrl){
    FirebaseFirestore.instance.collection('users').where('id', isEqualTo: id).get().then((value) {
      FirebaseFirestore.instance.collection('users').doc(value.docs[0].id).update({'profileImg': profileImgUrl});
    });
  }

  updateUserName(String id, String newUserName){
    FirebaseFirestore.instance.collection('users').where('id', isEqualTo: id).get().then((value) {
      FirebaseFirestore.instance.collection('users').doc(value.docs[0].id).update({'name': newUserName});
      FirebaseFirestore.instance.collection('users').doc(value.docs[0].id).update({'searchkey': newUserName.substring(0,1).toLowerCase()});
    });
  }

  updateToken(String id, String newToken){
    FirebaseFirestore.instance.collection('users').where('id', isEqualTo: id).get().then((value) {
      FirebaseFirestore.instance.collection('users').doc(value.docs[0].id).update({'tokenId': newToken});
    });
  }

  updateStatus(String id, String status){
    FirebaseFirestore.instance.collection('users').where('id', isEqualTo: id).get().then((value) {
      FirebaseFirestore.instance.collection('users').doc(value.docs[0].id).update({'status': status});
    });
  }

  updateReadMessage(String id, String chatRoomId){
    FirebaseFirestore.instance.collection('chatroom').doc(chatRoomId).collection('chats')
      .where('sendBy', isEqualTo: id).where('isRead', isEqualTo: false).get().then((value){
        value.docs.forEach((element) {
          FirebaseFirestore.instance.collection('chatroom').doc(chatRoomId)
            .collection('chats').doc(element.id).update({'isRead': true});
        });
    });
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
  StartChatting({required String userId, required String tokenId, required String profileImg, required BuildContext context, required TickerProvider tickerProvider}){
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
        tokenId: tokenId,
      )));
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('You can\'t chat yourself', textAlign: TextAlign.center),
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
          width: defaultWidth(context)/1.5,
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

    if(formatMessage.length > 30){
      formatMessage = formatMessage.substring(0, 30) + '...';
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

  String separatorDateFormat(DateTime timestamp){
    if(DateTime(timestamp.year, timestamp.month, timestamp.day).difference(DateTime.now()).inDays == 0)
      return 'Today';
    else if(DateTime(timestamp.year, timestamp.month, timestamp.day).difference(DateTime.now()).inDays == -1)
      return 'Yesterday';
    else
      return DateFormat('MMMM dd, yyyy').format(timestamp);
  }
}