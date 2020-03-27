import 'package:flutter/material.dart';
import 'package:kimble/player.dart';

class Turn{

  Turn(List<Player> players){
    this._playerCount = players.length;
    for(int i = 0; i < _playerCount; i++){
      playerColors.add(players[i].color);
    }
    _current = playerColors[0];
  }
  int _turnCount = 0;

  int _playerCount;

  Color _current;

  List<Color> playerColors = [];

  Color getCurrent() {return _current;}

  int getTurnCount() {return _turnCount;}

  int getPlayerCount() {return _playerCount;}

  void nextTurn(){
    _turnCount++;
    _current = playerColors[_turnCount % _playerCount];
  }

  int getColorId(Color color){
    for(int i = 0; i < _playerCount; i++){
      if(playerColors[i] == color) return i;
    }
    return -1;
  }
}

class TurnData{

  final int turn;
  final String colorStr;
  final int diceVal;
  final int pieceId;

  TurnData(this.turn, this.colorStr, this.diceVal, this.pieceId);
}
