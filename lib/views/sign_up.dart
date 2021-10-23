import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nocako_chatapp/components/components.dart';
import 'package:nocako_chatapp/components/responsive.dart';
import 'package:nocako_chatapp/components/theme_data.dart';
import 'package:nocako_chatapp/components/const.dart';
import 'package:nocako_chatapp/function/auth.dart';
import 'package:nocako_chatapp/function/helper.dart';
import 'package:nocako_chatapp/function/method.dart';
import 'package:nocako_chatapp/views/main_screen.dart';
import 'package:nocako_chatapp/views/sign_in.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with TickerProviderStateMixin{

  bool isLoading = false;

  Authentication authentication = new Authentication();
  UserMethod userMethod = new UserMethod();

  final formKey = GlobalKey<FormState>();
  TextEditingController usernameTextController = new TextEditingController();
  TextEditingController emailTextController = new TextEditingController();
  TextEditingController passwordTextController = new TextEditingController();

  getThemeFromPreferences() async{
    Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    Constants.myTheme = getTheme(Constants.myThemeName);
    setState(() {});
  }

  signUpValidator() async {
    if(formKey.currentState!.validate()){
      setState(() {
        isLoading = true;
      });
      await authentication.signUpWithEmailAndPassword(emailTextController.text, passwordTextController.text).then((value) async{
        if(value!= null){
          String? tokenId = "";
          if(!kIsWeb){
            var status = await OneSignal.shared.getDeviceState();
            tokenId = status!.userId;
          }

          Map<String, String> userInfo = {
            "id" : await UserMethod().generateID(),
            "name" : usernameTextController.text,
            "email": emailTextController.text,
            "searchkey": usernameTextController.text.substring(0, 1).toLowerCase(),
            "profileImg": "",
            "tokenId": tokenId.toString()
          };
          await userMethod.uploadUserInfo(userInfo);
          QuerySnapshot userInfoFetch = await userMethod.getUserByUserEmail(emailTextController.text);
          HelperFunction.saveUserIdSharedPreference(userInfoFetch.docs[0]['id']);
          HelperFunction.saveUserLoggedInSharedPreference(true);
          HelperFunction.saveUserNameSharedPreference(userInfoFetch.docs[0]['name']);
          HelperFunction.saveUserEmailSharedPreference(emailTextController.text);
          HelperFunction.saveUserProfileImageSharedPreference(userInfoFetch.docs[0]['profileImg']);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
        }
        else{
          setState(() {
            isLoading = false;
            print(isLoading);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Email ini sudah terdaftar', textAlign: TextAlign.center),
                    InkWell(
                      onTap: ()=> ScaffoldMessenger.of(context).clearSnackBars(),
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
                    parent: AnimationController(duration: const Duration(seconds: 1), vsync: this),
                    curve: Curves.linear
                ),
              ),
            );
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    getThemeFromPreferences();
    return Scaffold(
      body: isLoading ?
      LoadingScreen()
          :
      Responsive(
        mobile: Container(
          width: defaultWidth(context),
          height: defaultHeight(context),
          color: Constants.myTheme.backgroundColor,
          child: SingleChildScrollView(
            child: Container(
              width: defaultWidth(context),
              height: defaultHeight(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: defaultHeight(context)/50),
                    height: defaultHeight(context)/2.3,
                    width: defaultWidth(context),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(Constants.myTheme.signWallpaper),
                          fit: BoxFit.cover
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Buat akun,', style: TextStyle(
                          color: Constants.myTheme.text1Color,
                          fontSize: defaultHeight(context)/25
                        )),
                        Text('Daftar', style: TextStyle(
                          color: Constants.myTheme.text1Color,
                          fontSize: defaultHeight(context)/13
                        )),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: defaultHeight(context)/50),
                    child: Column(
                      children: [
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                style: TextStyle(
                                  color: Constants.myTheme.text2Color
                                ),
                                validator: (val){
                                  return val!.isEmpty ? "Nama tidak boleh kosong" : val.length<4 ? "Nama terlalu pendek" : null;
                                },
                                controller: usernameTextController,
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Constants.myTheme.borderColor)
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Constants.myTheme.buttonColor)
                                  ),
                                  hintText: 'Nama', hintStyle: TextStyle(color: Constants.myTheme.text2Color)
                                ),
                              ),
                              TextFormField(
                                style: TextStyle(
                                  color: Constants.myTheme.text2Color
                                ),
                                validator: (val){
                                  return RegExp(regexSource).hasMatch(val!) ? null : "Email tidak valid";
                                },
                                controller: emailTextController,
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Constants.myTheme.borderColor)
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Constants.myTheme.buttonColor)
                                  ),
                                  hintText: 'Email', hintStyle: TextStyle(color: Constants.myTheme.text2Color)
                                ),
                              ),
                              TextFormField(
                                style: TextStyle(
                                  color: Constants.myTheme.text2Color
                                ),
                                validator: (val){
                                  return val!.isEmpty || val.length<6 ? "Kata sandi terlalu pendek (minimal 6 karakter)" : null;
                                },
                                controller: passwordTextController,
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Constants.myTheme.borderColor)
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Constants.myTheme.buttonColor)
                                  ),
                                  hintText: 'Kata Sandi', hintStyle: TextStyle(color: Constants.myTheme.text2Color)
                                ),
                                obscureText: true,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: defaultHeight(context)/30),
                        ElevatedButton(
                          onPressed: () => signUpValidator(),
                          style: ElevatedButton.styleFrom(
                            primary: Constants.myTheme.buttonColor,
                            textStyle: TextStyle(fontSize: defaultHeight(context)/40),
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0),
                            ),
                            minimumSize: Size(defaultWidth(context)/1.5, defaultHeight(context)/20),
                          ),
                          child: Text('Daftar', style: TextStyle(color: Constants.myTheme.text1Color))
                        ),
                        SizedBox(height: defaultHeight(context)/30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Sudah punya akun?', style: TextStyle(color: Constants.myTheme.text2Color)),
                            InkWell(
                              onTap: (){
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
                              },
                              child: Text(' Masuk',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Constants.myTheme.buttonColor
                                ),
                              )
                            ),
                          ],
                        ),
                        SizedBox(height: defaultHeight(context)/8),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        desktop: Container(
          width: defaultWidth(context),
          height: defaultHeight(context),
          color: Constants.myTheme.backgroundColor,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: defaultHeight(context)/50),
                height: defaultHeight(context),
                width: defaultWidth(context)/2,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(Constants.myTheme.signWebWallpaper),
                    fit: BoxFit.cover
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/logo.svg',
                      width: defaultHeight(context)/3,
                      height: defaultHeight(context)/3,
                    ),
                    SizedBox(height: defaultHeight(context)/20),
                    Text('Nocako', style: TextStyle(
                      color: Constants.myTheme.text1Color,
                      fontSize: defaultHeight(context)/15
                    )),
                    Text('Chat App', style: TextStyle(
                      color: Constants.myTheme.text1Color,
                      fontSize: defaultHeight(context)/20
                    )),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: defaultHeight(context)/10),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Buat akun', style: TextStyle(
                          color: Constants.myTheme.text2Color,
                          fontSize: defaultHeight(context)/15
                        )),
                        Text('Daftar', style: TextStyle(
                          color: Constants.myTheme.text2Color,
                          fontSize: defaultHeight(context)/10
                        )),
                        SizedBox(height: defaultHeight(context)/5),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                style: TextStyle(
                                  color: Constants.myTheme.text2Color
                                ),
                                validator: (val){
                                  return val!.isEmpty ? "Nama tidak boleh kosong" : val.length<4 ? "Nama terlalu pendek" : null;
                                },
                                controller: usernameTextController,
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Constants.myTheme.borderColor)
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Constants.myTheme.buttonColor)
                                  ),
                                  hintText: 'Nama', hintStyle: TextStyle(color: Constants.myTheme.text2Color)
                                ),
                              ),
                              TextFormField(
                                style: TextStyle(
                                  color: Constants.myTheme.text2Color
                                ),
                                validator: (val){
                                  return RegExp(regexSource).hasMatch(val!) ? null : "Email tidak valid";
                                },
                                controller: emailTextController,
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Constants.myTheme.borderColor)
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Constants.myTheme.buttonColor)
                                  ),
                                  hintText: 'Email', hintStyle: TextStyle(color: Constants.myTheme.text2Color)
                                ),
                              ),
                              TextFormField(
                                style: TextStyle(
                                  color: Constants.myTheme.text2Color
                                ),
                                validator: (val){
                                  return val!.isEmpty || val.length<6 ? "Kata sandi terlalu pendek (minimal 6 karakter)" : null;
                                },
                                controller: passwordTextController,
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Constants.myTheme.borderColor)
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Constants.myTheme.buttonColor)
                                  ),
                                  hintText: 'Kata sandi', hintStyle: TextStyle(color: Constants.myTheme.text2Color)
                                ),
                                obscureText: true,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: defaultHeight(context)/30),
                        ElevatedButton(
                          onPressed: () => signUpValidator(),
                          style: ElevatedButton.styleFrom(
                            primary: Constants.myTheme.buttonColor,
                            textStyle: TextStyle(fontSize: defaultHeight(context)/40),
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0),
                            ),
                            fixedSize: Size(defaultWidth(context)/5, defaultHeight(context)/20),
                          ),
                          child: Text('Daftar', style: TextStyle(color: Constants.myTheme.text1Color))
                        ),
                        SizedBox(height: defaultHeight(context)/30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Sudah punya akun?', style: TextStyle(color: Constants.myTheme.text2Color)),
                            InkWell(
                              onTap: (){
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
                              },
                              child: Text(' Masuk',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Constants.myTheme.buttonColor
                                ),
                              )
                            ),
                          ],
                        ),
                        SizedBox(height: defaultHeight(context)/8),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}
