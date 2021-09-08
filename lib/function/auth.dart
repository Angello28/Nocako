import 'package:firebase_auth/firebase_auth.dart';
import 'package:nocako_chatapp/components/class.dart';

class Authentication{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future signInWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return AppUser(userId: result.user!.uid);
    }
    catch(e){
      print(e.toString());
    }
  }

  Future signUpWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return AppUser(userId: result.user!.uid);
    }
    catch(e){
      print(e.toString());
    }
  }

  Future resetPassword(String email) async{
    try{
      return await _auth.sendPasswordResetEmail(email: email);
    }
    catch(e){
      print(e.toString());
    }
  }

  Future signOut() async{
    try{
     return await _auth.signOut();
    }
    catch(e){
      print(e.toString());
    }
  }
}