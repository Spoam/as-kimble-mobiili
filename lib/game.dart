import 'package:flutter/material.dart';
import 'package:kimble/dice.dart';

class GameWindow extends StatefulWidget {
  GameWindow({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _GameWindowState createState() => _GameWindowState();

}

class _GameWindowState extends State<GameWindow>{
  Widget build(BuildContext context){
    return Scaffold(
        body:Center(
          child: Die(),
        )
    );
  }
}
