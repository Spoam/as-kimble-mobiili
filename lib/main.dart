import 'package:flutter/material.dart';
import 'package:kimble/game.dart';
import 'package:kimble/winScreen.dart';
import 'package:kimble/playerSelect.dart';

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

    return Scaffold(
      appBar: AppBar(
        title:Text('Kimble'),
      ),
      body:Center(

        child:Container(
          color: Colors.blue,
          child:MaterialButton(
            onPressed:(){
              Navigator.of(context).pushNamed('/playerselect');
              },
            child:Text('Uusi peli'),
        ),

      ),
    )
    );

  }
}


