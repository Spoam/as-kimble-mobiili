import 'package:flutter/material.dart';

class PieceData {

  PieceData(this.pos,this.startPos,this.color,this.homePos);
  final Color color;
  int steps = 0;
  int pos;
  final int startPos;
  final List<double> homePos;
  bool atHome = true;
  bool isMine = false;
  int multiplier = 1;
  bool isInDouble = false;
  List<int> doubleMembers = [];

  void reset(){
    steps = 0;
    pos = startPos;
    atHome = true;
    isMine = false;
    multiplier = 1;
    isInDouble = false;
    doubleMembers.clear();
  }

}