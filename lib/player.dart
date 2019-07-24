import 'package:flutter/material.dart';

class Player{

  Player(this.name,this.color);

  final String name;
  final Color color;

  int drinks = 0;
  int drunk = 0;
  int raises = 0;

  List<Widget> getPlayerInfo(double pieceSize){
      List<Widget> info = [
        Icon(Icons.brightness_1,color: color, size: pieceSize),
        Text('  $name'),
        Text('  juotu:$drunk'),
        Text('  sakot:$drinks   '),
      ];

      for(int i = 0; i < raises; i++){
        info.add(Icon(Icons.star, color: Colors.amber, size: pieceSize/1.5));
      }

      return info;
  }

}
