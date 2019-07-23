import 'package:flutter/material.dart';

class Player{

  Player(this.name,this.color);

  final String name;
  final Color color;

  int drinks = 0;
  int drunk = 0;

  List<Widget> getPlayerInfo(double pieceSize){

      return <Widget>[
        Icon(Icons.brightness_1,color: color, size: pieceSize),
        Text('  $name'),
        Text('  juotu:$drunk'),
        Text('  sakot:$drinks'),
      ];
  }

}
