import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kimble/gameUI.dart';
import 'package:kimble/winScreen.dart';
import 'package:kimble/playerSelect.dart';
import 'package:kimble/lobby.dart';
import 'package:kimble/lobbyBrowser.dart';
import 'package:package_info/package_info.dart';
import 'settings.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'globals.dart' as G;

void main() {

  runApp(
    EasyLocalization(
        supportedLocales: [Locale('en', 'US'), Locale('fi', 'FI')],
        path: 'assets/translations', // <-- change patch to your
        fallbackLocale: Locale('en', 'US'),
        preloaderColor: Colors.white10,
        child: MyApp()
    ),
  );
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {



    //route names
    return MaterialApp(
      title: 'AS Kimble',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: MainMenu(title: 'Kimblen päävalikko'),
      routes: <String, WidgetBuilder> {
        '/playerselect' : (BuildContext context) => PlayerSelectScreen(),
        '/playerselect/game': (BuildContext context) => GameWindow(title: 'page A'),
        '/playerselect/game/end':(BuildContext context) => WinScreen(),
        '/join/lobby' : (BuildContext context) => HostGame(),
        '/join' : (BuildContext context) => JoinGame(),
        '/settings' : (BuildContext context) => Settings(),
        '/join/browse' : (BuildContext context) => LobbyBrowser()
      },
    );
  }
}

class MainMenu extends StatefulWidget {
  MainMenu({Key key, this.title}) : super(key: key);
  final String title;


  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {

  String newest = "version not found";

  AudioCache sound = AudioCache(prefix: 'sound/');

  @override
  void initState(){
    super.initState();
    sound.load('button.mp3');
    sound.disableLog();
  }

  Future<String> getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    G.version = packageInfo.version;
    return packageInfo.version;

    // Other data you can get:
    //
    // 	String appName = packageInfo.appName;
    // 	String packageName = packageInfo.packageName;
    //	String buildNumber = packageInfo.buildNumber;
  }

  Future<String> getUUID() async {
    G.UUID = await PlatformDeviceId.getDeviceId;
    Firestore.instance.collection("Users").document(G.UUID).setData({'Lobby' : null});
  }

  String _saveNewest(DocumentSnapshot data){
    newest = data["newest"];
    return newest;
  }

  bool oldVersion = false;

  @override
  Widget build(BuildContext context){

    double width = MediaQuery.of(context).size.width - 20;

    getVersionNumber();
    getUUID();

    return Scaffold(
      appBar: AppBar(
        title:Text('Kimble'),
      ),
      body:ListView(
        children: [
          FutureBuilder(
            future: getVersionNumber(),
            builder: (BuildContext context, AsyncSnapshot snapshot) =>
              Text("version " + (snapshot.hasData ? "${snapshot.data}" : "?.?.?")),),
          FutureBuilder(
            future: Firestore.instance.collection("info").document("version").get(),
            builder: (BuildContext context, AsyncSnapshot snapshot) =>
              Text("newest " + (snapshot.hasData ? "${_saveNewest(snapshot.data)}" : "?.?.?")),
          ),
          oldVersion ? Container(
            width: width,
            color: Colors.white,
            child: Text("ERROR. APP VERSION TOO OLD FOR ONLINE PLAY",
              style: TextStyle(
                color: Colors.red,
                fontSize: 20,
              ),
            ),
          ) : Container(),
          Container(
            width: width / 3,
            margin: const EdgeInsets.fromLTRB(10,10,10,10),
            decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow:[
                  BoxShadow(
                      color: Colors.black54,
                      offset: Offset(1,1),
                      blurRadius: 0.5,
                      spreadRadius: 0.5
                  ),]
            ),
            child:MaterialButton(
            onPressed:(){
              sound.play("button.mp3");
              Navigator.of(context).pushNamed('/playerselect');
              },
              child:Text('start_local').tr(),
            ),


          ),
          Container(
            width: width / 3,
            margin: const EdgeInsets.fromLTRB(10,10,10,10),
            decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow:[
                  BoxShadow(
                      color: Colors.black54,
                      offset: Offset(1,1),
                      blurRadius: 0.5,
                      spreadRadius: 0.5
                  ),]
            ),
            child:MaterialButton(
              onPressed:(){
                sound.play("button.mp3");
                setState(() {

                });
                if(double.parse(G.version.substring(0,3)) >= double.parse(newest.substring(0,3))){
                  Navigator.of(context).pushNamed('/join');
                }else{
                  oldVersion = true;
                }

              },
              child:Text('start_online').tr(),
              ),
            ),
            Container(
            width: width / 3,
              margin: const EdgeInsets.fromLTRB(10,10,10,10),
              decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow:[
              BoxShadow(
                color: Colors.black54,
                offset: Offset(1,1),
                blurRadius: 0.5,
                spreadRadius: 0.5
                ),]
              ),
              child:MaterialButton(
              onPressed:(){
                sound.play("button.mp3");
                Navigator.of(context).pushNamed('/settings');
              }
              ,
               child:Text('settings'.tr()),
              ),
            ),
          Container(
            width: width / 3,
            margin: const EdgeInsets.fromLTRB(10,10,10,10),
            decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow:[
                  BoxShadow(
                      color: Colors.black54,
                      offset: Offset(1,1),
                      blurRadius: 0.5,
                      spreadRadius: 0.5
                  ),]
            ),
            child:MaterialButton(
              onPressed:(){
                sound.play("button.mp3");
                setState(() {
                  context.locale = context.locale == Locale('fi','FI') ? Locale('en', 'US') : Locale('fi', 'FI');
                });
                print(context.locale.toString());
              }
              ,
              child:Text('switch_locale').tr(),
            ),
          ),
      ]),
    );

  }
}


