import 'package:flutter/material.dart';
import 'package:kimble/piece.dart';
import 'dart:math';
import 'dart:core';
import 'package:kimble/player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';

enum Turn{
  RED,
  BLUE,
  GREEN,
  YELLOW,

}

class GameWindow extends StatefulWidget {
  GameWindow({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _GameWindowState createState() => _GameWindowState();

}

class _GameWindowState extends State<GameWindow> {

  List<Positioned> pieceIcons = new List(16);
  List<PieceData> pieceData = new List(16);
  List<List<double>> board = new List(28 + 16);
  List<Positioned> boardIcons = new List(44);

  Player PlayerRed;
  Player PlayerBlue;
  Player PlayerGreen;
  Player PlayerYellow;

  AudioCache sound = AudioCache(prefix: 'sound/');

  Turn cur = Turn.RED;


  void _initBoard(double width) {
    for (int i = 0; i < 28; i++) {
      //x = sin(i),y = cos(i) => ympyrä
      board[i] = [width / 2 + width / 2.5 * cos(i / (28 / (2 * pi))), width / 2 + width / 2.5 * sin(i / (28 / (2 * pi)))];
    }
    for (int i = 0; i < 16; i++) {
      if (i / 4 < 1) {
        board[i + 28] = [width / 4 + (pieceSize / sqrt(2)) * i, width / 4 + (pieceSize / sqrt(2)) * i];
      } else if (i / 4 < 2) {
        board[i + 28] = [width - width / 4 - (pieceSize / sqrt(2)) * (i - 4), width / 4 + (pieceSize / sqrt(2)) * (i - 4)];
      } else if (i / 4 < 3) {
        board[i + 28] = [width - width / 4 - (pieceSize / sqrt(2)) * (i - 8), width - width / 4 - (pieceSize / sqrt(2)) * (i - 8)];
      } else if (i / 4 < 4) {
        board[i + 28] = [width / 4 + (pieceSize / sqrt(2)) * (i - 12), width - width / 4 - (pieceSize / sqrt(2)) * (i - 12)];
      }
    }
  }

  void _createBoardIcons() {
    Color color = Colors.grey;
    for (int i = 0; i < 44; i++) {
      if (i >= 28) {
        if ((i - 28) / 4 < 1) {
          color = Colors.red;
        } else if ((i - 28) / 4 < 2) {
          color = Colors.indigo;
        } else if ((i - 28) / 4 < 3) {
          color = Colors.green;
        } else if ((i - 28) / 4 < 4) {
          color = Colors.yellow;
        }
      }

      boardIcons[i] = Positioned(
        top: board[i][1],
        left: board[i][0],
        child: Row(children:
        [
          //Text('$i'),
          Icon(Icons.gps_not_fixed,
              color: color,
              size: pieceSize),
        ]),
      );
    }
  }


  void _rollDice(){
    if (!diceRolled) {
      diceVal = rand.nextInt(6) + 1;
      attempts++;

      diceRolled = false;

      if (diceVal != 6 && attempts < 3) {
        if(_checkLegalMoves(1)) diceRolled = true;
        if(_checkLegalMoves(2)) diceRolled = true;
        if(_checkLegalMoves(3)) diceRolled = true;
        if(_checkLegalMoves(4)) diceRolled = true;
        if(_checkLegalMoves(5)) diceRolled = true;
        canRaise = false;
      } else {
        diceRolled = true;
      }
      if(diceVal == 6)_checkRaise();
      _checkLegalMoves(diceVal);

      //set selected piece to first movable
      int idx = legalMoves.reversed.toList().indexOf(true);
      if(idx != -1){
        _handleRadioValueChange(3 - idx);
      }else if(diceRolled){
        _handleTurn(null);
      }

    } else { //DEBUG poist tää
      diceVal = rand.nextInt(6) + 1;
      diceRolled = true;
      _checkLegalMoves(diceVal);

      int idx = legalMoves.indexOf(true);
      if(idx != -1){
        _handleRadioValueChange(idx);
      }else{
        selectedPiece = null;
      }
    }
  }

  int diceVal = 1;

  Random rand = Random(DateTime.now().microsecond);

  bool diceRolled = false;

  void _longPressEnd(LongPressEndDetails details) {
    sound.play('naks-up-1.mp3');
    _rollDice();
  }

  void _tapUp(TapUpDetails details) {
    sound.play('naks-up-1.mp3');
  }

  void _longPress(){
    sound.play('naks-down1.mp3');
  }

  int attempts = 0;

  GestureDetector _dice() {

    return GestureDetector(
        onLongPressEnd: _longPressEnd,
        onTapUp: _tapUp,
        onLongPress: _longPress,
        onTap: () {

          sound.play('naks-down1.mp3');

          setState(() {
            _rollDice();
          });
        },
        child: Container(
            width: pieceSize * 1.5,
            height: pieceSize * 1.5,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                image: DecorationImage(
                  image: AssetImage("res/textures/pips$diceVal.png"),
                  fit: BoxFit.fill,
                )
            )
        )
    );
  }

  Widget _placePiece(double x, double y, Color col, int multiplier,) {

    return Positioned(
      top: y,
      left: x,
      child: (multiplier > 1) ? Icon(
        Icons.add_circle, color: col, size: pieceSize,) : Icon(
          Icons.brightness_1, color: col, size: pieceSize),
    );
  }


  void _initPieces(double width) {
    double rowCenter = pieceSize / sqrt(2) * 2 - pieceSize / sqrt(2) / 2;

    for (int i = 0; i < 16; i++) {
      if (i / 4 < 1) {
        double x = (width / 6) - rowCenter + (pieceSize / sqrt(2)) * i;
        double y = (width / 6) + rowCenter - (pieceSize / sqrt(2)) * i;

        pieceIcons[i] = _placePiece(x, y, Colors.red, 1);
        pieceData[i] = PieceData(17, Colors.red, [x, y]);
      } else if (i / 4 < 2) {
        double x = (width - (width / 6)) - rowCenter + (pieceSize / sqrt(2)) * (i - 4);
        double y = (width / 6) - rowCenter + (pieceSize / sqrt(2)) * (i - 4);

        pieceIcons[i] = _placePiece(x, y, Colors.indigo, 1);
        pieceData[i] = PieceData(24, Colors.indigo, [x, y]);
      } else if (i / 4 < 3) {
        double x = (width - (width / 6)) - rowCenter + (pieceSize / sqrt(2)) * (i - 8);
        double y = (width - (width / 6)) + rowCenter - (pieceSize / sqrt(2)) * (i - 8);

        pieceIcons[i] = _placePiece(x, y, Colors.green, 1);
        pieceData[i] = PieceData(3, Colors.green, [x, y]);
      } else if (i / 4 < 4) {
        double x = (width / 6) - rowCenter + (pieceSize / sqrt(2)) * (i - 12);
        double y = (width - (width / 6)) - rowCenter + (pieceSize / sqrt(2)) * (i - 12);

        pieceIcons[i] = _placePiece(x, y, Colors.yellow, 1);
        pieceData[i] = PieceData(10, Colors.yellow, [x, y]);
      }
    }
  }

  bool _double(int n) {
    int index = _getPieceAt(pieceData[n].startPos + 1);
    if (index != null) {
      if (pieceData[n].color == pieceData[index].color) {
        pieceData[index].multiplier++;
        pieceData[index].doubleMembers.add(n);
        pieceData[n].isInDouble = true;
        pieceData[n].atHome = false;
        pieceData[n].steps  = -1;
        pieceData[n].pos = -1;

        pieceIcons[index] = _placePiece(board[pieceData[index].pos][0], board[pieceData[index].pos][1], pieceData[index].color, pieceData[index].multiplier);
        pieceIcons[n] = _placePiece(30, 30,Colors.lightBlueAccent, 1);

        return true;
      }
    }
    return false;
  }

  void _movePiece(int n, int diceVal) {
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
          pieceData[id].pos = 28 + cur.index * 4;
          pieceData[id].steps = 29;
          pieceData[id].isInDouble = false;
          pieceIcons[id] = _placePiece(board[pieceData[id].pos][0], board[pieceData[id].pos][1], pieceData[n].color, 1);
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
      pieceData[n].pos = pieceData[n].steps + 4 * cur.index - 1;
      _checkWin(pieceData[n].color);
    }
    pieceIcons[n] = _placePiece(board[pieceData[n].pos][0], board[pieceData[n].pos][1], pieceData[n].color, pieceData[n].multiplier);
  }

  List<bool> legalMoves = [false, false, false, false];
  List<bool> canDouble = [false, false, false, false];

  bool _checkLegalMoves(diceVal) {
    List<PieceData> data = [];
    List<List<int>> pieces = _findPiece(cur);
    data.add(pieceData[pieces[0][1]]);
    data.add(pieceData[pieces[1][1]]);
    data.add(pieceData[pieces[2][1]]);
    data.add(pieceData[pieces[3][1]]);

    legalMoves.setAll(0, [true, true, true, true]);
    canDouble.setAll(0, [false, false, false, false]);

    //print('checking moves...');

    if (diceVal != 6) {
      for (int i = 0; i < 4; i++) {
        if (data[i].atHome) {
          legalMoves[i] = false;
          //print('piece $i can\'t move because it\'s at home ');
        }
          if (data[i].isInDouble){
          //print('piece $i can\'t move because it\'s in double');
          legalMoves[i] = false;
        }
      }

      //test for a friendly piece in the same spot
      for (int i = 0; i < 4; i++) {
        int nextPos = data[i].pos + diceVal;
        if (nextPos > 27) nextPos -= 28;
        var samePos = data.where((piece) => piece.pos == nextPos);
        if (samePos.isNotEmpty){
          //print('piece $i can\'t move because another piece is blocking it ');
          legalMoves[i] = false;
        }
      }
      //when dice value is 6
    } else {

      for (int i = 0; i < 4; i++) {
        if (data[i].atHome){
          if(data.where((piece) => piece.steps == 1).isNotEmpty) canDouble[i] = true;
          legalMoves[i] = true;
        }
        if (data[i].isInDouble){
          //print('piece $i can\'t move because it\'s in double ');
          legalMoves[i] = false;
        }
      }
    }

    for (int i = 0; i < 4; i++) {
      if (data[i].steps + diceVal > 28) {
        if(data[i].steps + diceVal <= 32){
          var samePos = data.where((piece) => piece.pos ==  data[i].steps + diceVal + cur.index * 4 - 1);
          if (samePos.isNotEmpty) {
            //print('piece $i can\'t move because another piece blocks it at goal');
            legalMoves[i] = false;
          }else{
            legalMoves[i] = true;
          }
        }else{
          //print('piece $i can\'t move because it\'s at end of goal');
          legalMoves[i] = false;
        }
      }
    }
    return legalMoves.contains(true);
  }


  bool _checkRaise(){

    canRaise = true;


    //print('checking raise...$cur');
   //cant' raise if raising player has any pieces at home
    List<List<int>> curPieces = _findPiece(cur);
    for(int i = 0; i < curPieces.length; i++){
      if(pieceData[curPieces[i][1]].atHome){
        canRaise = false;
        //print('cant raise because home is not empty');
      }
    }

    bool redGoal = false;
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

    if(!redGoal || !blueGoal || !yellowGoal || !greenGoal){
      canRaise = false;
      print('cant raise because some players havent reached goal yet');
    }

    print('canRaise:$canRaise');
  }

  void raise(){

    int i = 0;
    while(i < 16){
       if(pieceData[i].pos > 27){

         //eating a piece with zero as second parameter gives no drinks
         _eatPiece(i, 0);
         if(pieceData[i].color == getCurrentPlayer().color){
           _movePiece(i, 6);
         }
         //skip over rest of the pieces of same color
         i += 4 - i % 4;
       }else{
         i++;
       }
    }
    getCurrentPlayer().raises++;
    canRaise = false;
  }

  //täst enumist on enmmän haittaa ku hyötyä
  Player getCurrentPlayer(){
    switch(cur){
      case Turn.RED:
        return getPlayerByColor(Colors.red);
      case Turn.BLUE:
        return getPlayerByColor(Colors.indigo);
      case Turn.GREEN:
        return getPlayerByColor(Colors.green);
      case Turn.YELLOW:
        return getPlayerByColor(Colors.yellow);
        break;
    }
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
        print('lol ajoit miinaan');
        _eatPiece(n, pieceData[index].multiplier);
        return true;
      }else{
        print('ate piece $index');
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
        pieceIcons[pieceId] = _placePiece(pieceData[pieceId].homePos[0],pieceData[pieceId].homePos[1], pieceData[pieceId].color,pieceData[pieceId].multiplier);
      }
    }

    Player player = getPlayerByColor(pieceData[index].color);
    player.drinks += eaterMultiplier * pieceData[index].multiplier * player.players;

    pieceData[index].reset();
    pieceIcons[index] = _placePiece(pieceData[index].homePos[0],pieceData[index].homePos[1], pieceData[index].color,pieceData[index].multiplier);
  }

  void _handleTurn(int idx){


    if(idx != null) _movePiece(idx, diceVal);
    //6 = new turn
    if(diceVal != 6){

      switch(cur){

        case Turn.RED:
          cur = Turn.BLUE;
          bgColor = Colors.indigo;
          break;

        case Turn.BLUE:
          cur = Turn.GREEN;
          bgColor = Colors.green;
          break;

        case Turn.GREEN:
          cur = Turn.YELLOW;
          bgColor = Colors.yellow;
          break;

        case Turn.YELLOW:
          cur = Turn.RED;
          bgColor = Colors.red;
          break;
      }
      attempts = 0;
      canRaise = false;
    }

    diceRolled = false;

    //cosmetic. hides piece selection before dice is rolled
    setState((){
      legalMoves.setAll(0, [false, false, false, false]);
    });

  }

  int selectedPiece;

  void _handleRadioValueChange(int value) {
    setState(() {
      _radioGroupVal = value;

      switch (_radioGroupVal) {
        case 0:
          selectedPiece = _findPiece(cur)[0][1];
          break;
      case 1:
          selectedPiece = _findPiece(cur)[1][1];
          break;
      case 2:
          selectedPiece = _findPiece(cur)[2][1];
          break;
      case 3:
          selectedPiece = _findPiece(cur)[3][1];
          break;

    }
    });
  }

  List<List<int>> _findPiece(Turn cur){

    List<List<int>> order = new List(4);
    int n = 0;
    for(int i = cur.index * 4; i < cur.index * 4 + 4; i++){
      order[n] = [pieceData[i].steps,i];
      n++;
    }
    order.sort((a,b) => a[0].compareTo(b[0]));
    return order;
  }

  Player getPlayerByColor(Color color){
    if(color == Colors.red){
      return PlayerRed;
    }else if(color == Colors.indigo){
      return PlayerBlue;
    }else if(color == Colors.green){
      return PlayerGreen;
    }else if(color == Colors.yellow){
      return PlayerYellow;
    }
    return null;
  }

  bool _checkWin(Color color){

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
    Player player = getPlayerByColor(color);
    if(player.drunk >= player.drinks && piecesInGoal.length == 4){
      player.winner = true;
      Navigator.of(context).pushNamed('/playerselect/game/end', arguments: [PlayerRed, PlayerBlue, PlayerGreen, PlayerYellow]);
      return true;
    }
    return false;
  }

  bool first = true;

  bool canRaise = false;

  int _radioGroupVal = -1;

  double pieceSize = 20;

  Color bgColor = Colors.red;

  Widget build(BuildContext context){


    double width = MediaQuery.of(context).size.width - 20;

    pieceSize = width / 13;

    if(first) {
      _initBoard(width);
      _initPieces(width);
      _createBoardIcons();
      List<Player> players = ModalRoute.of(context).settings.arguments;
      PlayerRed = players[0];
      PlayerBlue = players[1];
      PlayerGreen = players[2];
      PlayerYellow = players[3];
      sound.load('naks-koko-2.mp3');
      sound.load('naks-up-1.mp3');
      sound.load('naks-down1.mp3');
      first = false;
    }

    //add all widgetts to a signle list
    List<Widget> all = [];
    //board
    all.add(Container(
      margin: const EdgeInsets.fromLTRB(10,10,10,5),
      decoration : BoxDecoration(
        color: Colors.lightBlueAccent,
        borderRadius: BorderRadius.all(Radius.circular(pieceSize * 2)),
      ),

      width: width,
      height: width,
    ));

    all.addAll(boardIcons);
    all.addAll(pieceIcons);

    //dice
    all.add(Positioned(
      top: width / 2 - pieceSize / 4,
      left: width / 2 - pieceSize / 4,
      child:_dice(),
    ));

    return Scaffold(
        backgroundColor: bgColor,
        body:ListView(
          children:[
            Stack(
              children:all,
            ),

            legalMoves.contains(true) ? Container(
              height: 70,
              margin: const EdgeInsets.fromLTRB(10,5,10,5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child:Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  legalMoves[0] ? Column(
                    children:[
                      Radio(
                        value: 0,
                        groupValue: _radioGroupVal,
                        onChanged: _handleRadioValueChange,
                        ),
                        canDouble[0] ? Text('Tuplaa') : Text('Vika')
                      ]
                  ): Container(),

                  legalMoves[1] ? Column(
                    children:[
                      Radio(
                        value: 1,
                        groupValue: _radioGroupVal,
                        onChanged: _handleRadioValueChange,
                      ),
                      canDouble[1] ? Text('Tuplaa') : Text('Kolmas')
                    ]
                  ) : Container(),

                  legalMoves[2] ? Column(
                    children:[
                      Radio(
                        value: 2,
                        groupValue: _radioGroupVal,
                        onChanged: _handleRadioValueChange,
                       ),
                      canDouble[2] ? Text('Tuplaa') : Text('Toka')
                    ]
                  ) : Container(),

                  legalMoves[3] ? Column(
                    children:[
                      Radio(
                        value: 3,
                        groupValue: _radioGroupVal,
                        onChanged: _handleRadioValueChange,
                      ),
                      Text('Kärki')
                    ]
                  ) : Container(),
                ],

              ),
            ): Container(),

            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  diceRolled ?  Container(
                    margin: const EdgeInsets.fromLTRB(10,5,2.5,5),
                    width: width / 2 - 20,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        boxShadow:[
                          BoxShadow(
                              color: Colors.black54,
                              offset: Offset(1,1),
                              blurRadius: 0.5,
                              spreadRadius: 0.5
                          ),]
                    ),
                    child: MaterialButton(
                      onPressed: (){
                        setState(() {
                          if(legalMoves.contains(true)) {
                            canRaise = false;
                            _handleTurn(selectedPiece);
                          }else{
                            _handleTurn(null);
                          }
                        });
                      },
                      child: Text('Liiku'),
                    ),
                  ) : Container(),
                  canRaise ? Container(
                    margin: const EdgeInsets.fromLTRB(2.5,5,10,5),
                    width: width / 2 - 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                        boxShadow:[
                          BoxShadow(
                              color: Colors.black54,
                              offset: Offset(1,1),
                              blurRadius: 0.5,
                              spreadRadius: 0.5
                          ),]
                    ),
                    child: MaterialButton(
                      onPressed: (){
                        setState(() {
                          raise();
                          _handleTurn(null);
                        });
                      },
                      child: Text('Korota'),
                    ),
                  ) : Container(),
                ]
            ),

            //player info starts
            Container(
              margin: const EdgeInsets.fromLTRB(10,5,10,5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[
                  Row(
                      children:PlayerRed.getPlayerInfo(pieceSize),
                  ),
                  IconButton(
                    icon: Icon(Icons.plus_one,size: pieceSize),
                    onPressed: (){
                      setState((){
                        PlayerRed.drunk++;
                        _checkWin(Colors.red);
                      });
                    },
                  )
                ]
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(10,5,10,5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child:Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[
                  Row(children:PlayerBlue.getPlayerInfo(pieceSize)),
                  IconButton(
                    icon: Icon(Icons.plus_one,size: pieceSize),
                    onPressed: (){
                      setState((){
                        PlayerBlue.drunk++;
                        _checkWin(Colors.indigo);
                      });
                    },
                  )
                ]
              ),
            ),

            Container(
              margin: const EdgeInsets.fromLTRB(10,5,10,5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[
                  Row(children:PlayerGreen.getPlayerInfo(pieceSize)),
                  IconButton(
                    icon: Icon(Icons.plus_one,size: pieceSize),
                    onPressed: (){
                      setState((){
                        PlayerGreen.drunk++;
                        _checkWin(Colors.green);
                      });
                    },
                  )
                ]
              ),
            ),
           Container(
             margin: const EdgeInsets.fromLTRB(10,5,10,5),
             decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.all(Radius.circular(10)),
             ),
             child:Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[
                  Row(children:PlayerYellow.getPlayerInfo(pieceSize)),
                  IconButton(
                    icon: Icon(Icons.plus_one,size: pieceSize),
                    onPressed: (){
                      setState((){
                        PlayerYellow.drunk++;
                        _checkWin(Colors.yellow);
                      });
                    },
                  )
                ]
            )
           ),
          ],

        )
    );
    }
  }