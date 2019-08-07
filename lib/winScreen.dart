import 'package:flutter/material.dart';
import 'package:kimble/player.dart';

class WinScreen extends StatefulWidget{

  _WinState createState() => _WinState();
}

class _WinState extends State<WinScreen>{

  List<Player> players;

  void _findMoralWinner(){

    players.sort((playerA,playerB) => (playerB.drunk/playerB.players).compareTo(playerA.drunk/playerA.players));

    var drinks = players.where((player) => player.drunk/player.players == players[0].drunk/players[0].players);

    drinks.forEach((player) => player.moralWinner = true);

  }

  Widget _buildResultBar(int index, double size){

    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:[
          Row(children: players[index].getPlayerInfo(size)),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              players[index].winner ? Icon(Icons.stars, size: size, color: Colors.amberAccent) : Container(),
              players[index].moralWinner ? Icon(Icons.delete, size: size, color: Colors.black38) : Container(),
            ]
          )

        ],
      ),
    );
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
          _buildResultBar(0, pieceSize),
          _buildResultBar(1, pieceSize),
          _buildResultBar(2, pieceSize),
          _buildResultBar(3, pieceSize),

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
