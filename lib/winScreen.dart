import 'package:flutter/material.dart';
import 'package:kimble/player.dart';

class WinScreen extends StatefulWidget{

  _WinState createState() => _WinState();
}

class _WinState extends State<WinScreen>{

  List<Player> players;

  void _findMoralWinner(){

    players.sort((playerA,playerB) => playerB.drunk.compareTo(playerA.drunk));

    var drinks = players.where((player) => player.drunk == players[0].drunk);

    drinks.forEach((player) => player.moralWinner = true);

  }

  @override
  Widget build(BuildContext context){

    players = ModalRoute.of(context).settings.arguments;

    _findMoralWinner();

    double width = MediaQuery.of(context).size.width;

    double pieceSize = width / 13;

    return Scaffold(
      backgroundColor: Colors.white30,
      appBar: AppBar(
        title:Text('Tulokset'),
      ),
      body:ListView(
        children:[
          Container(
            margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                Row(children: players[0].getPlayerInfo(pieceSize)),
                players[0].winner ? Icon(Icons.stars, size: pieceSize, color: Colors.amberAccent) : Container(),
                players[0].moralWinner ? Icon(Icons.delete, size: pieceSize, color: Colors.black38) : Container(),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                Row(children: players[1].getPlayerInfo(pieceSize)),
                players[1].winner ? Icon(Icons.stars, size: pieceSize, color: Colors.amberAccent) : Container(),
                players[1].moralWinner ? Icon(Icons.delete, size: pieceSize, color: Colors.black38) : Container(),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                Row(children: players[2].getPlayerInfo(pieceSize)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                    players[2].winner ? Icon(Icons.stars, size: pieceSize, color: Colors.amberAccent) : Container(),
                    players[2].moralWinner ? Icon(Icons.delete, size: pieceSize, color: Colors.black38) : Container(),
                ]),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                Row(children: players[3].getPlayerInfo(pieceSize)),
                Column(children:[
                  players[3].winner ? Icon(Icons.stars, size: pieceSize * 1.5, color: Colors.amberAccent) : Container(),
                  players[3].moralWinner ? Icon(Icons.delete, size: pieceSize * 1.5, color: Colors.black38) : Container(),
                ],)
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
