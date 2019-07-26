import 'package:flutter/material.dart';
import 'package:kimble/player.dart';

class WinScreen extends StatelessWidget{

  List<Player> players;


  @override
  Widget build(BuildContext context){

    players = ModalRoute.of(context).settings.arguments;

    double width = MediaQuery.of(context).size.width;

    double pieceSize = width / 13;

    return Scaffold(
      appBar: AppBar(
        title:Text('Tulokset'),
      ),
      body:ListView(
        children:[
          Container(
            margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                Row(children: players[0].getPlayerInfo(pieceSize)),
                players[0].winner ? Icon(Icons.stars, size: pieceSize, color: Colors.amberAccent) : Container(),
                players[0].moralWinner ? Icon(Icons.delete, size: pieceSize, color: Colors.white30) : Container(),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                Row(children: players[1].getPlayerInfo(pieceSize)),
                players[1].winner ? Icon(Icons.stars, size: pieceSize, color: Colors.amberAccent) : Container(),
                players[1].moralWinner ? Icon(Icons.delete, size: pieceSize, color: Colors.white30) : Container(),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                Row(children: players[2].getPlayerInfo(pieceSize)),
                players[2].winner ? Icon(Icons.stars, size: pieceSize, color: Colors.amberAccent) : Container(),
                players[2].moralWinner ? Icon(Icons.delete, size: pieceSize, color: Colors.white30) : Container(),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                Row(children: players[3].getPlayerInfo(pieceSize)),
                players[3].winner ? Icon(Icons.stars, size: pieceSize, color: Colors.amberAccent) : Container(),
                players[3].moralWinner ? Icon(Icons.delete, size: pieceSize, color: Colors.white30) : Container(),
              ],
            ),
          ),
          FloatingActionButton(
          onPressed:(){
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
          child:Text('päävalikkoon'),
          ),
        ],
      ),

    );

  }

}
