import 'package:flutter/material.dart';
import 'package:kimble/dice.dart';
import 'package:kimble/piece.dart';

class GameWindow extends StatefulWidget {
  GameWindow({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _GameWindowState createState() => _GameWindowState();

}

class _GameWindowState extends State<GameWindow>{

  List<Positioned> pieces = new List(16);

  Positioned _placePiece(double x, double y,Color col){
    return Positioned(
      top: y,
      left: x,
      child:Piece(col),

    );
  }

  void _initPieces(double width, double height){
    double topMargin = 32;
    double sideMargin = 10;
    double pieceSize = 20;

    for(int i = 0; i < 16; i++){
      if(i / 4 < 1){
        pieces[i] = _placePiece(sideMargin, width / 2 - pieceSize + pieceSize*i,Colors.red);
      }else if(i / 4 < 2){
        pieces[i] = _placePiece(width / 2 - 3*pieceSize + pieceSize * (i-3), topMargin, Colors.indigo);
      }else if(i / 4 < 3){
        pieces[i] = _placePiece(width - pieceSize - sideMargin, width / 2 - 2*pieceSize + pieceSize*(i - 7), Colors.green);
      }else if(i / 4 < 4){
        pieces[i] = _placePiece(width / 2 - pieceSize*3 + pieceSize*(i-11), width, Colors.yellow);
      }
    }
  }

  Widget build(BuildContext context){

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    _initPieces(width, height);
    return Stack(
          children:pieces
    );
  }
}
