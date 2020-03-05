import 'package:flutter/material.dart';
import 'package:kimble/gameUI.dart';
import 'package:kimble/winScreen.dart';
import 'package:kimble/playerSelect.dart';
import 'package:kimble/lobby.dart';

void main() => runApp(MyApp());

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
      home: MainMenu(title: 'Kimblen päävalikko'),
      routes: <String, WidgetBuilder> {
        '/playerselect' : (BuildContext context) => PlayerSelectScreen(),
        '/playerselect/game': (BuildContext context) => GameWindow(title: 'page A'),
        '/playerselect/game/end':(BuildContext context) => WinScreen(),
        '/join/lobby' : (BuildContext context) => HostGame(),
        '/join' : (BuildContext context) => JoinGame(),
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

  @override
  Widget build(BuildContext context){

    double width = MediaQuery.of(context).size.width - 20;


    return Scaffold(
      appBar: AppBar(
        title:Text('Kimble'),
      ),
      body:ListView(
        children: [
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
              Navigator.of(context).pushNamed('/playerselect');
              },
              child:Text('Local'),
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
                Navigator.of(context).pushNamed('/join');
              },
              child:Text('Online'),
            ),


          ),
      ]),
    );

  }
}


