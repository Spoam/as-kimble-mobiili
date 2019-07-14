import 'package:flutter/material.dart';

class PieceData {

  PieceData(this.pos,this.color);
  Color color;
  int steps = 0;
  int pos;
  bool atHome = true;
  bool isMine = false;

}