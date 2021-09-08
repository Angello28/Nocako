import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nocako_chatapp/components/components.dart';
import 'package:nocako_chatapp/components/theme_data.dart';
import 'package:nocako_chatapp/components/const.dart';
import 'package:nocako_chatapp/components/responsive.dart';
import 'package:nocako_chatapp/function/auth.dart';
import 'package:nocako_chatapp/function/helper.dart';
import 'package:nocako_chatapp/function/method.dart';
import 'package:nocako_chatapp/views/sign_up.dart';
import 'main_screen.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> with TickerProviderStateMixin{

  bool isLoading = false;

  Authentication authentication = new Authentication();
  UserMethod userMethod = new UserMethod();

  final formKey = GlobalKey<FormState>();
  TextEditingController emailTextController = new TextEditingController();
  TextEditingController passwordTextController = new TextEditingController();

  static String themeName = "";
  ColorTheme theme = getTheme("Default");

  getThemeFromPreferences() async{
    themeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    theme = getTheme(themeName);
    setState((){});
  }

  signInValidator() async{
    if(formKey.currentState!.validate()){
      setState(() {
        isLoading = true;
      });
      await authentication.signInWithEmailAndPassword(emailTextController.text, passwordTextController.text).then((value) async{
        if(value!=null){
          QuerySnapshot userInfo = await userMethod.getUserByUserEmail(emailTextController.text);
          HelperFunction.saveUserLoggedInSharedPreference(true);
          HelperFunction.saveUserNameSharedPreference(userInfo.docs[0]['name']);
          HelperFunction.saveUserEmailSharedPreference(emailTextController.text);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
        }
        else{
          setState(() {
            isLoading = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text('User not found', textAlign: TextAlign.center),
                behavior: SnackBarBehavior.floating,
                elevation: 0,
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)
                ),
                width: defaultWidth(context)/2,
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
          color: theme.backgroundColor,
          child: SingleChildScrollView(
            child: Container(
              width: defaultWidth(context),
              height: defaultHeight(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: defaultHeight(context)/50),
                    height: defaultHeight(context)/2,
                    width: defaultWidth(context),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(theme.signWallpaper),
                          fit: BoxFit.cover
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back,', style: TextStyle(
                            color: theme.text1Color,
                            fontSize: defaultHeight(context)/25
                        )),
                        Text('Sign In', style: TextStyle(
                            color: theme.text1Color,
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
                                    color: theme.text2Color
                                ),
                                validator: (val){
                                  return RegExp(regexSource).hasMatch(val!) ? null : "Invalid email";
                                },
                                controller: emailTextController,
                                decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: theme.borderColor)
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: theme.buttonColor)
                                    ),
                                    hintText: 'Email', hintStyle: TextStyle(color: theme.text2Color)
                                ),
                              ),
                              TextFormField(
                                style: TextStyle(
                                    color: theme.text2Color
                                ),
                                validator: (val){
                                  return val!.isEmpty || val.length<6 ? "Password too short (min 6 character)" : null;
                                },
                                controller: passwordTextController,
                                decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: theme.borderColor)
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: theme.buttonColor)
                                    ),
                                    hintText: 'Password', hintStyle: TextStyle(color: theme.text2Color)
                                ),
                                obscureText: true,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: defaultHeight(context)/30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: (){},
                              child: Text('Forgot Password?', textAlign: TextAlign.end, style: TextStyle(color: theme.text2Color)),
                            ),
                          ],
                        ),
                        SizedBox(height: defaultHeight(context)/30),
                        ElevatedButton(
                            onPressed: () => signInValidator(),
                            style: ElevatedButton.styleFrom(
                              primary: theme.buttonColor,
                              textStyle: TextStyle(fontSize: defaultHeight(context)/40),
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0),),
                              minimumSize: Size(defaultWidth(context)/1.5, defaultHeight(context)/20),
                            ),
                            child: Text('Sign In', style: TextStyle(color: theme.text1Color))
                        ),
                        SizedBox(height: defaultHeight(context)/30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Don\'t have account?', style: TextStyle(color: theme.text2Color)),
                            InkWell(
                                onTap: (){
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignUp()));
                                },
                                child: Text(' Register Now',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: theme.buttonColor
                                  ),
                                )
                            ),
                          ],
                        ),
                        SizedBox(height: defaultHeight(context)/10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        tablet: Container(
          width: defaultWidth(context),
          height: defaultHeight(context),
          color: theme.backgroundColor,
          child: SingleChildScrollView(
            child: Container(
              width: defaultWidth(context),
              height: defaultHeight(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: defaultHeight(context)/50),
                    height: defaultHeight(context)/2,
                    width: defaultWidth(context),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(theme.signWallpaper),
                          fit: BoxFit.cover
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back,', style: TextStyle(
                            color: theme.text1Color,
                            fontSize: defaultHeight(context)/25
                        )),
                        Text('Sign In', style: TextStyle(
                            color: theme.text1Color,
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
                                    color: theme.text2Color
                                ),
                                validator: (val){
                                  return RegExp(regexSource).hasMatch(val!) ? null : "Invalid email";
                                },
                                controller: emailTextController,
                                decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: theme.borderColor)
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: theme.buttonColor)
                                    ),
                                    hintText: 'Email', hintStyle: TextStyle(color: theme.text2Color)
                                ),
                              ),
                              TextFormField(
                                style: TextStyle(
                                    color: theme.text2Color
                                ),
                                validator: (val){
                                  return val!.isEmpty || val.length<6 ? "Password too short (min 6 character)" : null;
                                },
                                controller: passwordTextController,
                                decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: theme.borderColor)
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: theme.buttonColor)
                                    ),
                                    hintText: 'Password', hintStyle: TextStyle(color: theme.text2Color)
                                ),
                                obscureText: true,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: defaultHeight(context)/30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: (){},
                              child: Text('Forgot Password?', textAlign: TextAlign.end, style: TextStyle(color: theme.text2Color)),
                            ),
                          ],
                        ),
                        SizedBox(height: defaultHeight(context)/30),
                        ElevatedButton(
                            onPressed: () => signInValidator(),
                            style: ElevatedButton.styleFrom(
                              primary: theme.buttonColor,
                              textStyle: TextStyle(fontSize: defaultHeight(context)/40),
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0),),
                              minimumSize: Size(defaultWidth(context)/1.5, defaultHeight(context)/20),
                            ),
                            child: Text('Sign In', style: TextStyle(color: theme.text1Color))
                        ),
                        SizedBox(height: defaultHeight(context)/30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Don\'t have account?', style: TextStyle(color: theme.text2Color)),
                            InkWell(
                                onTap: (){
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignUp()));
                                },
                                child: Text(' Register Now',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: theme.buttonColor
                                  ),
                                )
                            ),
                          ],
                        ),
                        SizedBox(height: defaultHeight(context)/10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        desktop: Container(
          width: defaultWidth(context),
          height: defaultHeight(context),
          color: theme.backgroundColor,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: defaultHeight(context)/50),
                height: defaultHeight(context),
                width: defaultWidth(context)/2,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(theme.signWebWallpaper),
                    fit: BoxFit.cover
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image(
                      image: AssetImage('assets/logo.png'),
                      width: defaultHeight(context)/3,
                      height: defaultHeight(context)/3,
                    ),
                    SizedBox(height: defaultHeight(context)/20),
                    Text('Nocako', style: TextStyle(
                      color: theme.text1Color,
                      fontSize: defaultHeight(context)/15
                    )),
                    Text('Chat App', style: TextStyle(
                      color: theme.text1Color,
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
                        Text('Welcome back,', style: TextStyle(
                          color: theme.text2Color,
                          fontSize: defaultHeight(context)/15
                        )),
                        Text('Sign In', style: TextStyle(
                          color: theme.text2Color,
                          fontSize: defaultHeight(context)/10
                        )),
                        SizedBox(height: defaultHeight(context)/3.5),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                style: TextStyle(
                                    color: theme.text2Color
                                ),
                                validator: (val){
                                  return RegExp(regexSource).hasMatch(val!) ? null : "Invalid email";
                                },
                                controller: emailTextController,
                                decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: theme.borderColor)
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: theme.buttonColor)
                                    ),
                                    hintText: 'Email', hintStyle: TextStyle(color: theme.text2Color)
                                ),
                              ),
                              TextFormField(
                                style: TextStyle(
                                    color: theme.text2Color
                                ),
                                validator: (val){
                                  return val!.isEmpty || val.length<6 ? "Password too short (min 6 character)" : null;
                                },
                                controller: passwordTextController,
                                decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: theme.borderColor)
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: theme.buttonColor)
                                    ),
                                    hintText: 'Password', hintStyle: TextStyle(color: theme.text2Color)
                                ),
                                obscureText: true,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: defaultHeight(context)/30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: (){},
                              child: Text('Forgot Password?', textAlign: TextAlign.end, style: TextStyle(color: theme.text2Color)),
                            ),
                          ],
                        ),
                        SizedBox(height: defaultHeight(context)/30),
                        ElevatedButton(
                            onPressed: () => signInValidator(),
                            style: ElevatedButton.styleFrom(
                              primary: theme.buttonColor,
                              textStyle: TextStyle(fontSize: defaultHeight(context)/40),
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0),),
                              fixedSize: Size(defaultWidth(context)/5, defaultHeight(context)/20),
                            ),
                            child: Text('Sign In', style: TextStyle(color: theme.text1Color))
                        ),
                        SizedBox(height: defaultHeight(context)/30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Don\'t have account?', style: TextStyle(color: theme.text2Color)),
                            InkWell(
                                onTap: (){
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignUp()));
                                },
                                child: Text(' Register Now',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: theme.buttonColor
                                  ),
                                )
                            ),
                          ],
                        ),
                        SizedBox(height: defaultHeight(context)/10),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}
