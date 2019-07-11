import 'package:flutter/material.dart';

class Piece extends StatefulWidget {

  Piece(this.col);
  final Color col;

    _PieceState createState() => _PieceState(col);
  }

  class _PieceState extends State<Piece> {
    _PieceState(this.col);
    final Color col;
    int steps = 0;
    bool  atHome = true;
    bool isMine = false;


    Widget build(BuildContext context){
      return Icon(Icons.brightness_1,
        color: col);
    }

  }