import 'package:flutter/material.dart';

class PlayerList{
  List<Player> players = List(4);
}

class Player{

  Player(this.name,this.color, this.players);

  final String name;
  final Color color;
  final int players;

  int drinks = 0;
  int drunk = 0;
  int raises = 0;

  bool winner = false;
  bool moralWinner = false;

  List<Widget> getPlayerInfo(double pieceSize){
      List<Widget> info = [
        Icon(Icons.brightness_1,color: color, size: pieceSize * 1.5),
        Text('  $name',
          style: TextStyle(
            fontSize: pieceSize / 1.4 - (name.length / 6 ) * (name.length / 6),
          ),
        ),
        Text('  juotu:$drunk',
          style: TextStyle(
            fontSize: pieceSize / 1.5,
          ),
        ),
        Text('  sakot:$drinks  ',
          style: TextStyle(
            fontSize: pieceSize / 1.5,
          ),
        ),
      ];

      for(int i = 0; i < raises; i++){
        info.add(Icon(Icons.star, color: Colors.amber, size: pieceSize/1.5));
      }

      return info;
  }

}
