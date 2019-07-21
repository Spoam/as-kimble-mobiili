import 'package:flutter/material.dart';
import 'package:kimble/dice.dart';
import 'package:kimble/piece.dart';
import 'dart:math';
import 'dart:core';

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

  List<List<int>> goals = List(4);

  List<int> goalRed = new List(4);
  List<int> goalBlue = new List(4);
  List<int> goalGreen = new List(4);
  List<int> goalYellow = new List(4);

  Turn cur = Turn.RED;


  void _initBoard(double width) {
    for (int i = 0; i < 28; i++) {
      //x = sin(i),y = cos(i) => ympyrä
      board[i] = [
        width / 2 + width / 2.5 * cos(i / (28 / (2 * pi))),
        width / 2 + width / 2.5 * sin(i / (28 / (2 * pi)))
      ];
    }
    for (int i = 0; i < 16; i++) {
      if (i / 4 < 1) {
        board[i + 28] = [
          width / 4 + (pieceSize / sqrt(2)) * i,
          width / 4 + (pieceSize / sqrt(2)) * i
        ];
      } else if (i / 4 < 2) {
        board[i + 28] = [
          width - width / 4 - (pieceSize / sqrt(2)) * (i - 4),
          width / 4 + (pieceSize / sqrt(2)) * (i - 4)
        ];
      } else if (i / 4 < 3) {
        board[i + 28] = [
          width - width / 4 - (pieceSize / sqrt(2)) * (i - 8),
          width - width / 4 - (pieceSize / sqrt(2)) * (i - 8)
        ];
      } else if (i / 4 < 4) {
        board[i + 28] = [
          width / 4 + (pieceSize / sqrt(2)) * (i - 12),
          width - width / 4 - (pieceSize / sqrt(2)) * (i - 12)
        ];
      }
    }

    for (int i = 0; i < 4; i++) {
      goals[i] = [null, null, null, null];
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

  int diceVal = 1;

  Random rand = Random(DateTime
      .now()
      .microsecond);

  bool diceRolled = false;

  void _longPressEnd(LongPressEndDetails details) {
    setState(() {});
    //side = rand.nextInt(6) + 1;
  }

  void _tapUp(TapUpDetails details) {
    setState(() {});
    //side = rand.nextInt(6) + 1;
  }

  int attempts = 0;

  GestureDetector _dice() {
    bool canMove = false;

    return GestureDetector(
        onLongPressEnd: _longPressEnd,
        onTapUp: _tapUp,
        onTap: () {
          setState(() {
            if (!diceRolled) {
              diceVal = rand.nextInt(6) + 1;
              attempts++;

              if (diceVal != 6 && attempts < 3) {
                canMove = _checkLegalMoves(1);
                canMove = _checkLegalMoves(2);
                canMove = _checkLegalMoves(3);
                canMove = _checkLegalMoves(4);
                canMove = _checkLegalMoves(5);
              } else {
                canMove = true;
              }
              diceRolled = canMove;

              _checkLegalMoves(diceVal);

              //set selected piece to first movable
              int idx = legalMoves.indexOf(true);
              if(idx != -1){
                _handleRadioValueChange(idx);
              }else{
                selectedPiece = null;
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
          });
        },
        child: Container(
            width: pieceSize * 1.5,
            height: pieceSize * 1.5,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("res/textures/pips$diceVal.png"),
                  fit: BoxFit.cover,
                )
            )
        )
    );
  }

  Positioned _placePiece(double x, double y, Color col, int multiplier,) {
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
        pieceData[i] = PieceData(17, 17, Colors.red, [x, y]);
      } else if (i / 4 < 2) {
        double x = (width - (width / 6)) - rowCenter +
            (pieceSize / sqrt(2)) * (i - 4);
        double y = (width / 6) - rowCenter + (pieceSize / sqrt(2)) * (i - 4);

        pieceIcons[i] = _placePiece(x, y, Colors.indigo, 1);
        pieceData[i] = PieceData(24, 24, Colors.indigo, [x, y]);
      } else if (i / 4 < 3) {
        double x = (width - (width / 6)) - rowCenter +
            (pieceSize / sqrt(2)) * (i - 8);
        double y = (width - (width / 6)) + rowCenter -
            (pieceSize / sqrt(2)) * (i - 8);

        pieceIcons[i] = _placePiece(x, y, Colors.green, 1);
        pieceData[i] = PieceData(3, 3, Colors.green, [x, y]);
      } else if (i / 4 < 4) {
        double x = (width / 6) - rowCenter + (pieceSize / sqrt(2)) * (i - 12);
        double y = (width - (width / 6)) - rowCenter +
            (pieceSize / sqrt(2)) * (i - 12);

        pieceIcons[i] = _placePiece(x, y, Colors.yellow, 1);
        pieceData[i] = PieceData(10, 10, Colors.yellow, [x, y]);
      }
    }
  }

  bool _double(int n) {
    int index = _getPieceAt(pieceData[n].startPos + 1);
    if (index != null) {
      if (pieceData[n].color == pieceData[index].color) {
        pieceData[index].multiplier++;
        pieceData[index].doubleMembers.add(n);
        pieceData[n].reset();
        pieceData[n].isInDouble = true;

        pieceIcons[index] = _placePiece(board[pieceData[index].pos][0], board[pieceData[index].pos][1], pieceData[index].color, pieceData[index].multiplier);
        pieceIcons[n] = _placePiece(10, 10, pieceData[n].color, 1);

        return true;
      }
    }
    return false;
  }

  void _movePiece(int n) {
    int move = 0;
    if (pieceData[n].atHome == true && diceVal == 6) {
      move = 1;
      pieceData[n].atHome = false;
      if (_double(n)) return;
    } else {
      move = diceVal;
    }

    //if true this piece got eaten
    if (_checkEat(pieceData[n].pos + move, n)) return;

    //entering goal
    if (pieceData[n].steps + move > 28) {
      if (pieceData[n].atGoal) {
        goals[cur.index][pieceData[n].steps - 29] = null;
      }

      goals[cur.index][pieceData[n].steps + move - 29] = n;
      pieceData[n].atGoal = true;
    }

    pieceData[n].steps += move;
    pieceData[n].pos += move;


    pieceData[n].steps == 1 ? pieceData[n].isMine = true : pieceData[n].isMine =
    false;
    //loop board
    if (pieceData[n].pos > 27 && !pieceData[n].atGoal) pieceData[n].pos -= 28;
    if (pieceData[n].atGoal) {
      pieceData[n].pos = pieceData[n].steps + 4 * cur.index - 1;
    }
    pieceIcons[n] = _placePiece(
        board[pieceData[n].pos][0], board[pieceData[n].pos][1],
        pieceData[n].color, pieceData[n].multiplier);
  }

  List<bool> legalMoves = [true, true, true, true];

  bool _checkLegalMoves(diceVal) {
    List<PieceData> data = [];
    List<List<int>> pieces = _findPiece(cur);
    data.add(pieceData[pieces[0][1]]);
    data.add(pieceData[pieces[1][1]]);
    data.add(pieceData[pieces[2][1]]);
    data.add(pieceData[pieces[3][1]]);

    legalMoves.setAll(0, [true, true, true, true]);

    if (diceVal != 6) {
      for (int i = 0; i < 4; i++) {
        if (data[i].atHome) legalMoves[i] = false;
        if (data[i].isInDouble) legalMoves[i] = false;
      }


      //test for a friendly piece in the same spot
      for (int i = 0; i < 4; i++) {
        int nextPos = data[i].pos + diceVal;
        if (nextPos > 27) nextPos -= 28;
        var samePos = data.where((piece) => piece.pos == nextPos);
        if (samePos.isNotEmpty) legalMoves[i] = false;
      }
    } else {
      for (int i = 0; i < 4; i++) {
        if (data[i].atHome) legalMoves[i] = true;
        if (data[i].isInDouble) legalMoves[i] = false;
      }
    }

    for (int i = 0; i < 4; i++) {
      if (data[i].steps + diceVal > 28) {

        print(data[i].steps + diceVal - 29);
        if(data[i].steps + diceVal <= 32){
          if (goals[cur.index][data[i].steps + diceVal - 29] == null) {
            legalMoves[i] = true;
          }else{
            legalMoves[i] = false;
          }
        }else{
          legalMoves[i] = false;
        }
      }
    }
    return legalMoves.contains(true);
  }

  int _getPieceAt(int pos){
    for(int i = 0; i < 16; i++){
      if(pieceData[i].pos == pos) return i;
    }
    return null;
  }

  bool _checkEat(int pos, int n){

    int index = _getPieceAt(pos);
    if(index != null){
      if(pieceData[index].isMine){
        print('lol ajoit miinaan');
        _eatPiece(n);
        return true;
      }else{
        _eatPiece(index);
      }
    }
    return false;
  }

  void _eatPiece(int index){
    if(pieceData[index].doubleMembers.length > 0){

      for(int i = 0; i < pieceData[index].doubleMembers.length; i++){
        int pieceId = pieceData[index].doubleMembers[i];
        pieceData[pieceId].reset();
        pieceIcons[pieceId] = _placePiece(pieceData[pieceId].homePos[0],pieceData[pieceId].homePos[1], pieceData[pieceId].color,pieceData[pieceId].multiplier);
      }
    }
    pieceData[index].reset();
    pieceIcons[index] = _placePiece(pieceData[index].homePos[0],pieceData[index].homePos[1], pieceData[index].color,pieceData[index].multiplier);
  }

  void _handleTurn(int idx){


    if(idx != null) _movePiece(idx);
    //6 = new turn
    if(diceVal != 6){

      switch(cur){

        case Turn.RED:
          cur = Turn.BLUE;
          break;

        case Turn.BLUE:
          cur = Turn.GREEN;
          break;

        case Turn.GREEN:
          cur = Turn.YELLOW;
          break;

        case Turn.YELLOW:
          cur = Turn.RED;
          break;
      }
      attempts = 0;
    }

    diceRolled = false;

  }

  int selectedPiece = 0;

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

  bool first = true;

  int _radioGroupVal = 3;

  double pieceSize = 20;

  Widget build(BuildContext context){


    double width = MediaQuery.of(context).size.width - 20;

    pieceSize = width / 13;


    if(first) {
      _initBoard(width);
      _initPieces(width);
      _createBoardIcons();
      first = false;
    }

    //add all widgetts to a signle list
    List<Widget> all = [];
    //board
    all.add(Container(
      margin: const EdgeInsets.all(10.0),
      color: Colors.lightBlueAccent,
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
        body:ListView(
          children:[
            Stack(
              children:all,
            ),
            Row(
              children: <Widget>[
                legalMoves[0] ? Radio(
                value: 0,
                  groupValue: _radioGroupVal,
                  onChanged: _handleRadioValueChange,
                ) : Container(),
                legalMoves[0] ? Text('Vika') : Text(''),

                legalMoves[1] ? Radio(
                  value: 1,
                  groupValue: _radioGroupVal,
                  onChanged: _handleRadioValueChange,
                ) : Container(),
                legalMoves[1] ? Text('Kolmas') : Text(''),

                legalMoves[2] ? Radio(
                  value: 2,
                  groupValue: _radioGroupVal,
                  onChanged: _handleRadioValueChange,
                ) : Container(),
                legalMoves[2] ? Text('Toka') : Text(''),

                legalMoves[3] ? Radio(
                  value: 3,
                  groupValue: _radioGroupVal,
                  onChanged: _handleRadioValueChange,
                ) : Container(),
                legalMoves[3] ? Text('Kärki') : Text(''),
              ],

            ),
            diceRolled ?  RaisedButton(
              onPressed: (){
                setState(() {
                  if(legalMoves.contains(true)) {
                    _handleTurn(selectedPiece);
                  }else{
                    _handleTurn(null);
                  }
                });
              },
              child:Text('Liiku/Lopeta vuoro')
            ) : Container(),

            Text('$cur'),
            Text('$selectedPiece'),

          ],
        )
    );
    }
  }