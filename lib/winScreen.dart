import 'package:flutter/material.dart';
import 'package:kimble/player.dart';

class WinScreen extends StatelessWidget{

  @override
  Widget build(BuildContext context){

    List<Player> players = ModalRoute.of(context).settings.arguments;


    return Scaffold(
      appBar: AppBar(
        title:Text('Kimble'),
      ),
      body:Center(

        child:FloatingActionButton(
          onPressed:(){
            Navigator.pop(context);
          },
          child:Text('back'),
        ),

      ),

    );

  }

}
