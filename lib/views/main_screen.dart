import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nocako_chatapp/components/const.dart';
import 'package:nocako_chatapp/components/responsive.dart';
import 'package:nocako_chatapp/components/theme_data.dart';
import 'package:nocako_chatapp/components/components.dart';
import 'package:nocako_chatapp/function/auth.dart';
import 'package:nocako_chatapp/function/helper.dart';
import 'package:nocako_chatapp/function/method.dart';
import 'package:nocako_chatapp/views/chat_screen.dart';
import 'package:nocako_chatapp/views/nav_drawer.dart';
import 'package:nocako_chatapp/views/photo_screen.dart';
import 'package:nocako_chatapp/views/search_screen.dart';
import 'package:nocako_chatapp/views/sign_in.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver{

  String getId = '';
  String getImgUrl = '';
  String getTokenId = '';
  Stream<QuerySnapshot> getMessagesStream = Stream.empty();

  Authentication authentication = new Authentication();
  Stream<QuerySnapshot> chatRoomStream = Stream.empty();

  bool isChatRoomScreen = true;
  bool isDrawer = false;
  bool isSearchScreen = false;
  bool isThemeScreen = false;
  bool isProfileScreen = false;

  getUserInfo() async{
    Constants.myId = (await HelperFunction.getUserIdSharedPreference())!;
    Constants.myName = (await HelperFunction.getUserNameSharedPreference())!;
    Constants.myEmail = (await HelperFunction.getUserEmailSharedPreference())!;
    Constants.myProfileImage = (await HelperFunction.getUserProfileImageSharedPreference())!;
    chatRoomStream = await UserMethod().getChatRooms(Constants.myId);
    await UserMethod().updateStatus(Constants.myId, 'online');
    setState(() {});
  }

  getThemeFromPreferences() async{
    Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    Constants.myTheme = getTheme(Constants.myThemeName);
    setState(() {});
  }

  getProfileImage() async{
    Constants.myProfileImage = (await HelperFunction.getUserProfileImageSharedPreference())!;
    setState(() {});
  }

  Widget sideChatScreen(){
    if(getId == ''){
      return Container(
        color: Constants.myTheme.backgroundColor,
        height: defaultHeight(context),
      );
    }
    else{
      return ChatScreen(
        chatRoomId: getId,
        chatRoomStream: getMessagesStream,
        chatProfileImgUrl: getImgUrl,
        tokenId: getTokenId,
      );
    }
  }

  @override
  void initState() {
    getUserInfo();
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async{
    super.didChangeAppLifecycleState(state);
    if(state == AppLifecycleState.resumed){
      await UserMethod().updateStatus(Constants.myId, 'online');
      setState(() {});
    }
    else{
      await UserMethod().updateStatus(Constants.myId, 'offline');
      setState(() {});
    }
  }

  UserMethod userMethod = new UserMethod();
  SearchMethod searchMethod = new SearchMethod();
  var queryResultSet = [];
  var tempSearchStore =[];

  // ignore: non_constant_identifier_names
  Searching(String value){
    if(value.length == 0){
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }

    var keyword = value.substring(0,1) + value.substring(1);

    if(queryResultSet.length == 0 && value.length == 1){
      userMethod.getUserByUsername(value).then((QuerySnapshot snapshot){
        for (var message in snapshot.docs) {
          setState(() {
            queryResultSet.add(message.data());
          });
        }
      });
    }
    else{
      tempSearchStore =[];
      queryResultSet.forEach((element) {
        if(element['name'].startsWith(keyword)){
          setState(() {
            tempSearchStore.add(element);
          });
        }
      });
    }
  }

  // ignore: non_constant_identifier_names
  Widget SearchScreenWeb(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.myTheme.primaryColor,
        iconTheme: IconThemeData(color: Constants.myTheme.text1Color),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Visibility(
              visible: Responsive.isDesktop(context),
              child: InkWell(
                onTap: (){
                  setState(() {
                    isDrawer = true;
                    isSearchScreen = false;
                  });
                },
                child: Icon(
                  Icons.close,
                ),
              ),
            ),
            SizedBox(width: Responsive.isDesktop(context) ? defaultWidth(context)/80 : 0),
            Text('Cari', style: TextStyle(color: Constants.myTheme.text1Color)),
          ]
        ),
        backwardsCompatibility: false,
        systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
      ),
      body: Container(
        color: Constants.myTheme.backgroundColor,
        padding: EdgeInsets.symmetric(vertical: defaultHeight(context)/40, horizontal: defaultWidth(context)/80),
        child: Column(
          children: [
            Container(
              child: TextField(
                style: TextStyle(color: Constants.myTheme.text2Color),
                onChanged: (val){
                  Searching(val);
                },
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Constants.myTheme.borderColor)
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Constants.myTheme.buttonColor)
                  ),
                  hintText: 'Cari nama pengguna', hintStyle: TextStyle(color: Constants.myTheme.text2Color)
                ),
                enabled: true,
              ),
            ),
            SizedBox(height: defaultHeight(context)/30),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: [
                      tempSearchStore.length == 0 && queryResultSet.length == 0 ?
                      Container(
                        height: defaultHeight(context)/1.5,
                        child: Center(
                          child: Text('Cari teman untuk memulai percakapan',
                            style: TextStyle(
                              color: Constants.myTheme.text2Color
                            )
                          )
                        )
                      )
                          :
                      tempSearchStore.length == 0 && queryResultSet.length != 0 ?
                      Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: queryResultSet.length,
                          itemBuilder: (context, index){
                            return UserTile(
                              userId: queryResultSet[index]['id'],
                              username: queryResultSet[index]['name'],
                              email: queryResultSet[index]['email'],
                              profileImg: queryResultSet[index]['profileImg'],
                              tokenId: queryResultSet[index]['tokenId'],
                              searchMethod: searchMethod,
                              getChatId: (id){
                                setState(() {
                                  getId = id;
                                });
                              },
                              getChatStream: (stream){
                                setState(() {
                                  getMessagesStream = stream;
                                });
                              },
                              getImgUrl: (url){
                                setState(() {
                                  getImgUrl = url;
                                });
                              },
                              getTokenId: (token){
                                setState(() {
                                  getTokenId = token;
                                });
                              },
                            );
                          }
                        ),
                      )
                          :
                      Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: tempSearchStore.length,
                          itemBuilder: (context, index){
                            return UserTile(
                              userId: tempSearchStore[index]['id'],
                              username: tempSearchStore[index]['name'],
                              email: tempSearchStore[index]['email'],
                              profileImg: tempSearchStore[index]['profileImg'],
                              tokenId: tempSearchStore[index]['tokenId'],
                              searchMethod: searchMethod,
                              getChatId: (id){
                                setState(() {
                                  getId = id;
                                });
                              },
                              getChatStream: (stream){
                                setState(() {
                                  getMessagesStream = stream;
                                });
                              },
                              getImgUrl: (url){
                                setState(() {
                                  getImgUrl = url;
                                });
                              },
                              getTokenId: (token){
                                setState(() {
                                  getTokenId = token;
                                });
                              },
                            );
                          }
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget ProfileScreenWeb(){
    bool isLoading = false;
    TextEditingController usernameTextController = new TextEditingController();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Visibility(
              visible: Responsive.isDesktop(context),
              child: InkWell(
                onTap: (){
                  setState(() {
                    isDrawer = true;
                    isProfileScreen = false;
                  });
                },
                child: Icon(
                  Icons.close,
                ),
              ),
            ),
            SizedBox(width: Responsive.isDesktop(context) ? defaultWidth(context)/80 : 0),
            Text('Profil', style: TextStyle(
              color: Constants.myTheme.text1Color
            )),
          ],
        ),
        backgroundColor: Constants.myTheme.primaryColor,
        iconTheme: IconThemeData(color: Constants.myTheme.text1Color),
        backwardsCompatibility: false,
        systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
      ),
      body: Container(
        height: defaultHeight(context),
        width: defaultWidth(context),
        color: Constants.myTheme.backgroundColor,
        padding: EdgeInsets.symmetric(vertical: defaultHeight(context)/40, horizontal: defaultWidth(context)/80),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                if(Constants.myProfileImage != "")
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoScreen(
                    title: 'Foto Profil',
                    imageUrl: Constants.myProfileImage,
                  )));
              },
              child: Container(
                  width: defaultHeight(context)/5,
                  height: defaultHeight(context)/5,
                  child: CircleAvatar(
                    maxRadius: 50,
                    minRadius: 40,
                    backgroundColor: Colors.transparent,
                    child: ClipOval(
                      child: Constants.myProfileImage == "" ?
                      Icon(
                          Icons.account_circle,
                          color: Constants.myTheme.buttonColor,
                          size: defaultHeight(context)/5
                      )
                          :
                      isLoading ?
                      CircularProgressIndicator(
                        backgroundColor: Colors.transparent,
                        color: Constants.myTheme.buttonColor,
                      )
                          :
                      CachedNetworkImage(
                        imageUrl: Constants.myProfileImage,
                        progressIndicatorBuilder: (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                              backgroundColor: Colors.transparent,
                              color: Constants.myTheme.buttonColor,
                              value: downloadProgress.progress,
                            ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        fit: BoxFit.cover,
                        width: defaultHeight(context)/5,
                        height: defaultHeight(context)/5,
                      ),
                    ),
                  )
              ),
            ),
            SizedBox(height: defaultHeight(context)/40),
            InkWell(
              onTap: () async{
                showMaterialModalBottomSheet(
                    backgroundColor: Constants.myTheme.backgroundColor,
                    context: context,
                    builder: (context){
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text(
                              'Ganti foto profil',
                              style: TextStyle(
                                  color: Constants.myTheme.text2Color
                              ),
                            ),
                            onTap: () async{
                              isLoading = true;
                              XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
                              Navigator.pop(context);
                              String path = await StorageMethod().uploadProfileImage(Constants.myId, image!);
                              await UserMethod().updateProfileImage(Constants.myId, path);
                              await HelperFunction.saveUserProfileImageSharedPreference(path);
                              setState(() {
                                Constants.myProfileImage = path;
                                isLoading = false;
                              });
                            },
                          ),
                          ListTile(
                            title: Text(
                              'Hapus foto profil',
                              style: TextStyle(
                                  color: Constants.myTheme.text2Color
                              ),
                            ),
                            onTap: () async{
                              await UserMethod().updateProfileImage(Constants.myId, "");
                              await HelperFunction.saveUserProfileImageSharedPreference("");
                              setState(() {
                                Constants.myProfileImage = "";
                              });
                              Navigator.pop(context);
                            },
                          )
                        ],
                      );
                    }
                );
              },
              child: Text('Edit foto', style: TextStyle(
                color: Constants.myTheme.buttonColor,
                fontSize: defaultHeight(context)/50,
              )),
            ),
            SizedBox(height: defaultHeight(context)/20),
            Container(
              width: defaultWidth(context)/1.2,
              child: ListTile(
                leading: Icon(Icons.bookmark, color: Constants.myTheme.text2Color, size: defaultHeight(context)/20),
                title: Text(Constants.myId, style: TextStyle(
                    color: Constants.myTheme.text2Color,
                    fontSize: defaultHeight(context)/45
                )),
              ),
            ),
            Container(
              width: defaultWidth(context)/1.2,
              child: ListTile(
                leading: Icon(Icons.account_circle, color: Constants.myTheme.text2Color, size: defaultHeight(context)/20),
                title: Text(Constants.myName, style: TextStyle(
                    color: Constants.myTheme.text2Color,
                    fontSize: defaultHeight(context)/45
                )),
                trailing: InkWell(
                    onTap: () async{
                      showDialog(
                          context: context,
                          builder: (context){
                            return AlertDialog(
                              backgroundColor: Constants.myTheme.backgroundColor,
                              buttonPadding: EdgeInsets.only(right: defaultWidth(context)/10),
                              title: Text(
                                'Masukkan Nama Baru',
                                style: TextStyle(
                                    color: Constants.myTheme.text2Color
                                ),
                              ),
                              content: TextField(
                                controller: usernameTextController,
                                style: TextStyle(
                                    color: Constants.myTheme.text2Color
                                ),
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Constants.myTheme.borderColor)
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Constants.myTheme.buttonColor)
                                  ),
                                ),
                              ),
                              actions: [
                                InkWell(
                                  child: Text(
                                    'Batal',
                                    style: TextStyle(
                                        color: Constants.myTheme.text2Color
                                    ),
                                  ),
                                  onTap: () => Navigator.pop(context),
                                ),
                                InkWell(
                                  child: Text(
                                    'Ubah',
                                    style: TextStyle(
                                        color: Constants.myTheme.buttonColor
                                    ),
                                  ),
                                  onTap: () async{
                                    UserMethod().updateUserName(Constants.myId, usernameTextController.text);
                                    HelperFunction.saveUserNameSharedPreference(usernameTextController.text);
                                    setState(() {
                                      Constants.myName = usernameTextController.text;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          }
                      );
                    },
                    child: Icon(
                      Icons.create,
                      color: Constants.myTheme.buttonColor
                    )
                ),
              ),
            ),
            Container(
              width: defaultWidth(context)/1.2,
              child: ListTile(
                leading: Icon(Icons.mail, color: Constants.myTheme.text2Color, size: defaultHeight(context)/20),
                title: Text(Constants.myEmail, style: TextStyle(
                  color: Constants.myTheme.text2Color,
                  fontSize: defaultHeight(context)/45
                )),
              ),
            ),
          ],
        ),
      )
    );
  }

  // ignore: non_constant_identifier_names
  Widget ThemeSettingWeb(){
    List<String> themeList = ["Default", "Gelap", "Lofi", "Neon"];
    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Visibility(
              visible: Responsive.isDesktop(context),
              child: InkWell(
                onTap: (){
                  setState(() {
                    isDrawer = true;
                    isThemeScreen = false;
                  });
                },
                child: Icon(
                  Icons.close,
                ),
              ),
            ),
            SizedBox(width: Responsive.isDesktop(context) ? defaultWidth(context)/80 : 0),
            Text(
              'Tema',
              style: TextStyle(
                color: Constants.myTheme.text1Color
              )
            ),
          ],
        ),
        backgroundColor: Constants.myTheme.primaryColor,
        iconTheme: IconThemeData(color: Constants.myTheme.text1Color),
        backwardsCompatibility: false,
        systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
      ),
      body: Container(
        height: defaultHeight(context),
        width: defaultWidth(context),
        color: Constants.myTheme.backgroundColor,
        child: ListView.builder(
            itemCount: themeList.length,
            shrinkWrap: true,
            itemBuilder: (context, index){
              return ListTile(
                onTap: () async{
                  setState((){
                    ThemeGetterAndSetter.setThemeSharedPreferences(themeList[index]);
                  });
                  Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
                  Constants.myTheme = getTheme(Constants.myThemeName);
                },
                trailing: Radio(
                  value: themeList[index],
                  groupValue: Constants.myThemeName == "" ? 'Default' : Constants.myThemeName,
                  onChanged: (val) async{
                    setState((){
                      ThemeGetterAndSetter.setThemeSharedPreferences(themeList[index]);
                    });
                    Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
                    Constants.myTheme = getTheme(Constants.myThemeName);
                  },
                  activeColor: Constants.myTheme.buttonColor,
                ),
                title: Text(themeList[index],
                  style: TextStyle(
                      color: Constants.myTheme.text2Color
                  ),
                ),
              );
            }
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget NavDrawerWeb(){
    Authentication authentication = new Authentication();
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: (){
            setState(() {
              isDrawer = false;
              isChatRoomScreen = true;
            });
          },
          child: Icon(
            Icons.close,
          ),
        ),
        backgroundColor: Constants.myTheme.primaryColor,
        iconTheme: IconThemeData(color: Constants.myTheme.text1Color),
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.only(left: defaultHeight(context) / 70, right: defaultHeight(context) / 70),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              Constants.myTheme.secondaryColor,
              Constants.myTheme.primaryColor,
            ],
          ),
        ),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: defaultHeight(context)/50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: defaultHeight(context)/40),
                  Container(
                    width: defaultHeight(context)/7,
                    height: defaultHeight(context)/7,
                    child: CircleAvatar(
                      maxRadius: 50,
                      minRadius: 40,
                      backgroundColor: Colors.transparent,
                      child: ClipOval(
                        child: Constants.myProfileImage == "" ?
                        Icon(
                          Icons.account_circle,
                          color: Constants.myTheme.buttonColor == Constants.myTheme.primaryColor ?
                          Colors.white : Constants.myTheme.buttonColor,
                          size: defaultHeight(context)/7
                        )
                            :
                        CachedNetworkImage(
                          imageUrl: Constants.myProfileImage,
                          placeholder: (context, url) => Icon(
                            Icons.account_circle,
                            color: Constants.myTheme.buttonColor == Constants.myTheme.primaryColor ?
                            Colors.white : Constants.myTheme.buttonColor,
                            size: defaultHeight(context)/7
                          ),
                          fit: BoxFit.cover,
                          width: defaultHeight(context)/7,
                          height: defaultHeight(context)/7,
                        ),
                      )
                    ),
                  ),
                  SizedBox(height: defaultHeight(context)/45),
                  Row(
                    children: [
                      SizedBox(width: defaultWidth(context)/100),
                      Text(
                        Constants.myName, style: TextStyle(
                          color: Constants.myTheme.text1Color,
                          fontSize: defaultHeight(context) / 40
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: defaultWidth(context)/100),
                      Text(Constants.myEmail, style: TextStyle(
                          color: Constants.myTheme.text1Color,
                          fontSize: defaultHeight(context) / 40
                        ),
                      ),
                    ],
                  )
                ],
              )
            ),
            SizedBox(
              height: defaultHeight(context) / 20,
            ),
            ListTile(
              leading: Icon(Icons.search, color: Constants.myTheme.text1Color, size:defaultHeight(context) / 20),
              title: Text(
                'Cari Teman',
                style: TextStyle(
                  color: Constants.myTheme.text1Color,
                  fontSize: defaultHeight(context) / 40
                ),
              ),
              onTap: (){
                setState(() {
                  isSearchScreen = true;
                  isDrawer = false;
                  isChatRoomScreen = false;
                });
              },
            ),
            SizedBox(
              height: defaultHeight(context) / 80,
            ),
            ListTile(
              leading: Icon(Icons.account_circle, color: Constants.myTheme.text1Color, size:defaultHeight(context) / 20),
              title: Text(
                'Profil',
                style: TextStyle(
                  color: Constants.myTheme.text1Color,
                  fontSize: defaultHeight(context) / 40
                ),
              ),
              onTap: (){
                setState(() {
                  isProfileScreen = true;
                  isDrawer = false;
                  isChatRoomScreen = false;
                });
              },
            ),
            SizedBox(
              height: defaultHeight(context) / 80,
            ),
            ListTile(
              leading: Icon(Icons.brush, color: Constants.myTheme.text1Color, size:defaultHeight(context) / 20),
              title: Text('Tema', style: TextStyle(
                  color: Constants.myTheme.text1Color,
                  fontSize: defaultHeight(context) / 40
                ),
              ),
              onTap: (){
                setState(() {
                  isThemeScreen = true;
                  isDrawer = false;
                  isChatRoomScreen = false;
                });
              },
            ),
            SizedBox(
              height: defaultHeight(context) / 80,
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Constants.myTheme.text1Color, size:defaultHeight(context) / 20),
              title: Text('Keluar', style: TextStyle(
                  color: Constants.myTheme.text1Color,
                  fontSize: defaultHeight(context) / 40
                ),
              ),
              onTap: () async{
                authentication.signOut();
                await UserMethod().updateStatus(Constants.myId, 'offline');
                await UserMethod().updateToken(Constants.myId, '');
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
              }
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    getProfileImage();
    getThemeFromPreferences();
    return Responsive(
      mobile: Scaffold(
        drawer: NavDrawer(),
        onDrawerChanged: (bool isOpened)=>{
          getThemeFromPreferences()
        },
        appBar: AppBar(
          title: Text('Nocako', style: TextStyle(
            color: Constants.myTheme.text1Color
          )),
          backgroundColor: Constants.myTheme.primaryColor,
          iconTheme: IconThemeData(color: Constants.myTheme.text1Color),
          backwardsCompatibility: false,
          systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
        ),
        body: Stack(
          children: [
            Container(
              width: defaultWidth(context),
              height: defaultHeight(context),
              color: Constants.myTheme.backgroundColor,
            ),
            chatRoomStream != Stream.empty() ?
            ChatRoomList(
              chatRoomStream: chatRoomStream,
              getChatIdFromList: (id){
                setState(() {
                  getId = id;
                });
              },
              getStreamFromList: (stream){
                setState(() {
                  getMessagesStream = stream;
                });
              },
              getImgUrlFromList: (url){
                setState(() {
                  getImgUrl = url;
                });
              },
              getTokenIdFromList: (token){
                setState(() {
                  getTokenId = token;
                });
              },
            )
                :
            Container(
              child: Text('kosong'),
            )
          ]
        ),
        floatingActionButton: Container(
          margin: EdgeInsets.only(right: defaultWidth(context)/30, bottom: defaultHeight(context)/60),
          width: defaultWidth(context)/5,
          height: defaultHeight(context)/11,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Search()));
            },
            child: Icon(Icons.chat, size: defaultHeight(context)/25, color: Constants.myTheme.text1Color),
            backgroundColor: Constants.myTheme.buttonColor,
          ),
        ),
      ),
      desktop: Row(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                Visibility(
                  visible: isSearchScreen,
                  child: SearchScreenWeb(),
                ),
                Visibility(
                  visible: isProfileScreen,
                  child: ProfileScreenWeb(),
                ),
                Visibility(
                  visible: isThemeScreen,
                  child: ThemeSettingWeb(),
                ),
                Visibility(
                  visible: isDrawer,
                  child: NavDrawerWeb(),
                ),
                Visibility(
                  visible: isChatRoomScreen,
                  child: Scaffold(
                    drawer: Responsive.isMobile(context) ? NavDrawer() : null,
                    onDrawerChanged: (bool isOpened)=>{
                      getThemeFromPreferences()
                    },
                    appBar: AppBar(
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Visibility(
                            visible: Responsive.isDesktop(context),
                            child: InkWell(
                              onTap: (){
                                setState(() {
                                  isDrawer = true;
                                  isChatRoomScreen = false;
                                });
                              },
                              child: Icon(
                                Icons.menu,
                              ),
                            ),
                          ),
                          SizedBox(width: Responsive.isDesktop(context) ? defaultWidth(context)/80 : 0),
                          Text('Nocako', style: TextStyle(
                            color: Constants.myTheme.text1Color
                          )),
                        ],
                      ),
                      backgroundColor: Constants.myTheme.primaryColor,
                      iconTheme: IconThemeData(color: Constants.myTheme.text1Color),
                    ),
                    body: Stack(
                      children: [
                        Container(
                          width: defaultWidth(context),
                          height: defaultHeight(context),
                          color: Constants.myTheme.backgroundColor,
                        ),
                        ChatRoomList(
                          chatRoomStream: chatRoomStream,
                          getChatIdFromList: (id){
                            setState(() {
                              getId = id;
                            });
                          },
                          getStreamFromList: (stream){
                            setState(() {
                              getMessagesStream = stream;
                            });
                          },
                          getImgUrlFromList: (url){
                            setState(() {
                              getImgUrl = url;
                            });
                          },
                          getTokenIdFromList: (token){
                            setState(() {
                              getTokenId = token;
                            });
                          },
                        )
                      ]
                    ),
                    floatingActionButton: Visibility(
                      visible: Responsive.isMobile(context),
                      child: Container(
                        margin: EdgeInsets.only(left: defaultWidth(context)/5),
                        width: defaultWidth(context)/5,
                        height: defaultHeight(context)/11,
                        child: FloatingActionButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Search()));
                          },
                          child: Icon(Icons.chat, size: defaultHeight(context)/25, color: Constants.myTheme.text1Color),
                          backgroundColor: Constants.myTheme.buttonColor,
                        ),
                      ),
                    ),
                    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: sideChatScreen()
          ),
        ],
      )
    );
  }
}

