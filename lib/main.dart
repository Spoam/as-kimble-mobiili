import 'package:flutter/material.dart';
import 'package:kimble/game.dart';

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
        '/game': (BuildContext context) => GameWindow(title: 'page A'),
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

        child:FloatingActionButton(
            onPressed:(){
              Navigator.of(context).pushNamed('/game');
              },
            child:Text('Aloita peli'),
        ),

      ),

    );

  }
}

