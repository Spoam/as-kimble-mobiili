import 'package:kimble/piece.dart';
import 'package:kimble/player.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kimble/turnManager.dart';
import 'package:audioplayers/audio_cache.dart';
import 'globals.dart' as G;

const int skipTurn = -1;
const int raise = -2;

class GameLogic{
  GameLogic(this.players, this.placePiece, this.cache){
    turn = Turn(players);
  }

  AudioCache cache;
  
  Function placePiece;

  List<PieceData> pieceData = new List(16);

  List<Player> players;

  int diceVal = 1;

  Random rand = Random(DateTime.now().microsecond);

  bool _diceRolled = false;

  int attempts = 0;

  List<bool> _legalMoves = [false, false, false, false];
  List<bool> canDouble = [false, false, false, false];

  int selectedPiece;

  bool canRaise = false;

  Turn turn;
  
  int randomNaks(){

    List<int> possibleVals = [1, 2, 3, 4, 5, 6];
    
    int roll = rand.nextInt(1000);

    //probability of  rolling opposite side.
    //20,7% according to tactic. nearly 30% according to another study. set to 22% for now
    if(roll < 220){
      return  7 - diceVal;
    }
    //probability for rolling same number is around 10%
    if(roll > 900){
      return diceVal;
    }
    possibleVals.removeWhere((a) => a  == (7 - diceVal));
    possibleVals.removeWhere((a) => a  == diceVal);

    return possibleVals[rand.nextInt(4)];
    
  }
  
  void rollDice(){
    if (!_diceRolled) {
      diceVal = randomNaks();
      attempts++;

      _diceRolled = false;

      if (diceVal != 6 && attempts < 3) {
        if(_checkLegalMoves(1)) _diceRolled = true;
        if(_checkLegalMoves(2)) _diceRolled = true;
        if(_checkLegalMoves(3)) _diceRolled = true;
        if(_checkLegalMoves(4)) _diceRolled = true;
        if(_checkLegalMoves(5)) _diceRolled = true;
        canRaise = false;
      } else {
        _diceRolled = true;
      }
      if(diceVal == 6)_checkRaise();
      _checkLegalMoves(diceVal);

      //set selected piece to first movable
      //done in gameUI now

    } else {
      //only on run on debug mode
      assert(() {
        diceVal = rand.nextInt(6) + 1;
        _diceRolled = true;
        _checkLegalMoves(diceVal);
      }());
    }
  }

  bool _double(int n) {
    int index = _getPieceAt(pieceData[n].startPos + 1);
    if (index != null) {
      if (pieceData[n].color == pieceData[index].color) {
        pieceData[index].multiplier++;
        if(pieceData[index].multiplier == 3 && G.soundSettings["triple"]) cache.play("triple3.mp3");
        pieceData[index].doubleMembers.add(n);
        pieceData[n].isInDouble = true;
        pieceData[n].atHome = false;
        pieceData[n].steps  = -1;
        pieceData[n].pos = -1;

        placePiece(0.0,0.0, pieceData[index].pos, index, pieceData[index].color, pieceData[index].multiplier, 0);
        placePiece(pieceData[n].homePos[0], pieceData[n].homePos[1], -1, n ,Colors.lightBlueAccent, 1, 0);

        return true;
      }
    }
    return false;
  }

  void _movePiece(int n, int diceVal) {

    //not sure if this is necessary
    canRaise = false;

    int move = 0;
    if (pieceData[n].atHome == true && diceVal == 6) {
      pieceData[n].pos = pieceData[n].startPos;
      move = 1;
      pieceData[n].atHome = false;
      if (_double(n)) return;
    } else {
      move = diceVal;
    }

    //entering goal
    if (pieceData[n].steps + move > 28) {
      if (pieceData[n].atGoal) {
        pieceData[n].multiplier = 1;
      }else {
        for(int i = 0; i < pieceData[n].doubleMembers.length; i++){
          int id = pieceData[n].doubleMembers[i];
          pieceData[id].pos = 28 + turn.getColorId(turn.getCurrent()) * turn.getPlayerCount();
          pieceData[id].steps = 29;
          pieceData[id].isInDouble = false;
          placePiece(0.0,0.0, pieceData[id].pos, id, pieceData[n].color, 1, 150 * move);
        }
        pieceData[n].atGoal = true;
        pieceData[n].doubleMembers.clear();
      }
    }

    if(!pieceData[n].atGoal){
      //if true this piece got eaten
      if (_checkEat(pieceData[n].pos + move, n)) return;
    }

    pieceData[n].steps += move;
    pieceData[n].pos += move;


    pieceData[n].steps == 1 ? pieceData[n].isMine = true : pieceData[n].isMine = false;
    //loop board
    if (pieceData[n].pos > 27 && !pieceData[n].atGoal) pieceData[n].pos -= 28;

    if (pieceData[n].atGoal) {
      pieceData[n].pos = pieceData[n].steps + turn.getPlayerCount() * turn.getColorId(turn.getCurrent()) - 1;
      checkWin(pieceData[n].color);
    }
    placePiece(0.0,0.0, pieceData[n].pos, n, pieceData[n].color, pieceData[n].multiplier, 150 * move);
  }

  bool _checkLegalMoves(diceVal) {
    List<PieceData> data = [];
    List<List<int>> pieces = findPiece(turn.getCurrent());
    data.add(pieceData[pieces[0][1]]);
    data.add(pieceData[pieces[1][1]]);
    data.add(pieceData[pieces[2][1]]);
    data.add(pieceData[pieces[3][1]]);

    _legalMoves.setAll(0, [true, true, true, true]);
    canDouble.setAll(0, [false, false, false, false]);

    //print('checking moves...');

    if (diceVal != 6) {
      for (int i = 0; i < 4; i++) {
        if (data[i].atHome) {
          _legalMoves[i] = false;
          //print('piece $i can\'t move because it\'s at home ');
        }
        if (data[i].isInDouble){
          //print('piece $i can\'t move because it\'s in double');
          _legalMoves[i] = false;
        }
      }

      //test for a friendly piece in the same spot
      for (int i = 0; i < 4; i++) {
        int nextPos = data[i].pos + diceVal;
        if (nextPos > 27) nextPos -= 28;
        var samePos = data.where((piece) => piece.pos == nextPos);
        if (samePos.isNotEmpty){
          //print('piece $i can\'t move because another piece is blocking it ');
          _legalMoves[i] = false;
        }
      }
      //when dice value is 6
    } else {

      for (int i = 0; i < 4; i++) {
        if (data[i].atHome){
          if(data.where((piece) => piece.steps == 1).isNotEmpty) canDouble[i] = true;
          _legalMoves[i] = true;
        }
        if (data[i].isInDouble){
          //print('piece $i can\'t move because it\'s in double ');
          _legalMoves[i] = false;
        }
      }
    }

    for (int i = 0; i < 4; i++) {
      if (data[i].steps + diceVal > 28) {
        if(data[i].steps + diceVal <= 32){
          var samePos = data.where((piece) => piece.pos ==  data[i].steps + diceVal + turn.getColorId(turn.getCurrent()) * turn.getPlayerCount() - 1);
          if (samePos.isNotEmpty) {
            //print('piece $i can\'t move because another piece blocks it at goal');
            _legalMoves[i] = false;
          }else{
            _legalMoves[i] = true;
          }
        }else{
          //print('piece $i can\'t move because it\'s at end of goal');
          _legalMoves[i] = false;
        }
      }
    }
    return _legalMoves.contains(true);
  }

  void _checkRaise(){

    canRaise = true;


    //print('checking raise...$cur');
    //cant' raise if raising player has any pieces at home
    List<List<int>> curPieces = findPiece(turn.getCurrent());
    for(int i = 0; i < curPieces.length; i++){
      if(pieceData[curPieces[i][1]].atHome){
        canRaise = false;
        //print('cant raise because home is not empty');
      }
    }


    var otherRaises = players.where((player) => player.raises < getPlayerByColor(turn.getCurrent()).raises);
    if(otherRaises.isNotEmpty) canRaise = false;


    /*bool redGoal = false;
    bool blueGoal = false;
    bool greenGoal = false;
    bool yellowGoal = false;


    for(int i = 0; i < 16; i++){
      PieceData p = pieceData[i];
      if(p.color == Colors.red && p.steps > 28) redGoal = true;
      if(p.color == Colors.indigo && p.steps > 28) blueGoal = true;
      if(p.color == Colors.green && p.steps > 28) greenGoal = true;
      if(p.color == Colors.yellow && p.steps > 28) yellowGoal = true;
    }
    */

    players.forEach((player) => {
      if(piecesInGoal(player.color) < 1) canRaise = false
    });

    /*if(!redGoal || !blueGoal || !yellowGoal || !greenGoal){
      canRaise = false;
      //print('cant raise because some players havent reached goal yet');
    }*/
  }

  void raise(){

    players.forEach((player){
      List<List<int>> pieces = findPiece(player.color);

      for(int i = 0; i < 4; i++){
        int index = pieces[i][1];
        if(pieceData[index].pos > 27){
          //eating piece with zero multiplayer just sends it home
          _eatPiece(index, 0);
          if(player.color == turn.getCurrent()){
            _movePiece(index, 6);
          }
          break;
        }
      }

    });

    /*
    int i = 0;
    while(i < 16){
      if(pieceData[i].pos > 27){

        //eating a piece with zero as second parameter gives no drinks
        _eatPiece(i, 0);
        if(pieceData[i].color == getPlayerByColor(turn.getCurrent()).color){
          _movePiece(i, 6);
        }
        //skip over rest of the pieces of same color
        i += 4 - i % 4;
      }else{
        i++;
      }
    }*/
    getPlayerByColor(turn.getCurrent()).raises++;
    //when raise round is over set accept raise to false for every one
    if(players.every((p) => p.raises == players[0].raises) && players[0].raises > 1){
      players.forEach((p) =>  p.acceptRaise = false);
    }
    canRaise = false;
    handleTurn(null, -1);
  }

  int _getPieceAt(int pos){
    for(int i = 0; i < 16; i++){
      if(pieceData[i].pos == pos) return i;
    }
    return null;
  }

  bool _checkEat(int pos, int n){

    if(pos >= 28) pos -= 28;
    int index = _getPieceAt(pos);
    if(index != null){
      print('eating piece $index at $pos');
      if(pieceData[index].isMine){
        if(G.soundSettings["mine"])cache.play('mine2.mp3');
        _eatPiece(n, pieceData[index].multiplier);
        return true;
      }else{
        if(G.soundSettings["eat"]) cache.play('eat1.mp3');
        _eatPiece(index, pieceData[n].multiplier);
      }
    }
    return false;
  }

  void _eatPiece(int index, int eaterMultiplier){
    if(pieceData[index].doubleMembers.length > 0){

      for(int i = 0; i < pieceData[index].doubleMembers.length; i++){
        int pieceId = pieceData[index].doubleMembers[i];
        pieceData[pieceId].reset();
        placePiece(pieceData[pieceId].homePos[0], pieceData[pieceId].homePos[1], -1, pieceId, pieceData[pieceId].color, pieceData[pieceId].multiplier, 400);
      }
    }

    Player player = getPlayerByColor(pieceData[index].color);
    player.drinks += eaterMultiplier * pieceData[index].multiplier * player.players;

    pieceData[index].reset();
    placePiece(pieceData[index].homePos[0], pieceData[index].homePos[1], -1, index, pieceData[index].color,pieceData[index].multiplier, 400);
  }

  void handleTurn(int idx, diceRoll){



    if(diceRoll == -1) diceRoll = diceVal;
    //move piece null == skip turn
    if(idx != null) _movePiece(idx, diceRoll);
    //6 = new turn
    if(diceRoll != 6){

      turn.nextTurn();
      attempts = 0;
      canRaise = false;
    }


    _diceRolled = false;

    //cosmetic. hides piece selection before dice is rolled
    _legalMoves.setAll(0, [false, false, false, false]);

  }

  List<List<int>> findPiece(Color col){

    List<List<int>> order = new List(turn.getPlayerCount());
    int n = 0;
    for(int i = turn.getColorId(col) * turn.getPlayerCount(); i < turn.getColorId(col) * turn.getPlayerCount() + turn.getPlayerCount(); i++){
      order[n] = [pieceData[i].steps,i];
      n++;
    }
    order.sort((a,b) => a[0].compareTo(b[0]));
    return order;
  }

  int piecesInGoal(Color color){
    List<int> piecesInGoal = [];

    bool onlyPiece = false;

    for(int i = 0; i < 16; i++){
      if(pieceData[i].steps > 28 && pieceData[i].color == color){

        if(piecesInGoal.isEmpty){
          piecesInGoal.add(i);
        }else{
          for(int j = 0; j < piecesInGoal.length; j++){

            if(pieceData[i].pos == pieceData[piecesInGoal[j]].pos){
              onlyPiece = false;
            }else{
              onlyPiece = true;
            }
          }
          if(onlyPiece) piecesInGoal.add(i);
        }
      }
    }
    return piecesInGoal.length;
  }

  bool checkWin(Color color){

    Player player = getPlayerByColor(color);
    if(player.drunk >= player.drinks && piecesInGoal(color) == 4){
      player.winner = true;
      return true;
    }
    return false;
  }

  Player getPlayerByColor(color){
    return players[turn.getColorId(color)];
  }

  Text getStatusText(int index){

    var pieces = findPiece(turn.getCurrent());
    PieceData piece = pieceData[pieces[index][1]];

    switch(index){
      case 0:
        return canDouble[0] ? _multiplierCount(piece) : piece.atHome ? Text('Uusi') :Text('Vika');
      case 1:
        return canDouble[1] ? _multiplierCount(piece) : piece.atHome ? Text('Uusi') :Text('Kolmas');
      case 2:
        return canDouble[2] ? _multiplierCount(piece) : piece.atHome ? Text('Uusi') :Text('Toka');
      case 3:
        return canDouble[3] ? _multiplierCount(piece) : piece.atHome ? Text('Uusi') :Text('Kärki');
      default:
        return Text('väärä indeksi idiootti');
    }
  }

  Text _multiplierCount(PieceData piece){

    int index = _getPieceAt(piece.startPos + 1);

    switch(pieceData[index].doubleMembers.length){
      case 0:
        return Text("Tupla");
      case 1:
        return Text("Tripla");
      case 2:
        return Text("Quatro");
      default:
        return Text("mitä vittua");
    }
  }

  bool getDiceStatus() {return _diceRolled;}

  List<bool> getLegalMoves(){return _legalMoves;}

  bool isWinner(){
    for(int i = 0; i < players.length; i++){
      if(players[i].winner) return true;
    }
    return false;
  }
}