import 'package:flutter/material.dart';

class PieceData {

  PieceData(this.startPos,this.color,this.homePos);
  final Color color;
  int steps = 0;
  int pos = -1;
  final int startPos;
  final List<double> homePos;
  bool atHome = true;
  bool isMine = false;
  int multiplier = 1;
  bool isInDouble = false;
  bool atGoal = false;
  List<int> doubleMembers = [];

  void reset(){
    steps = 0;
    pos = -1;
    atHome = true;
    isMine = false;
    multiplier = 1;
    isInDouble = false;
    atGoal = false;
    doubleMembers.clear();
  }

}