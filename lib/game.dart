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

class _GameWindowState extends State<GameWindow>{

  List<Positioned> pieceIcons = new List(16);
  List<PieceData> pieceData = new List(16);
  //List<List<double>> board = [[10,10],[20,20],[40,40],[60,60],[80,80],[100,100],[120,120],[140,140]];
  List<List<double>> board = new List(28);
  List<Positioned> boardIcons = new List(28);
  Turn cur = Turn.RED;



  void _initBoard(double width){
    for(int i = 0; i < 28; i++){
        //x = sin(i),y = cos(i) => ympyrä
        board[i] = [width/2 - 10 + width/2.5 * sin(i/(28/(2*pi))), width/2 + width/2.5 * cos(i/(28/(2*pi)))];
    }

  }

  void _createBoardIcons() {

    for(int i = 0; i < 28; i++) {
      boardIcons[i] = Positioned(
        top: board[i][1],
        left: board[i][0],
        child: Icon(Icons.gps_not_fixed,
          color: Colors.grey,),
      );
    }
  }

  int diceVal = 1;

  Random rand = Random(DateTime.now().microsecond);

  bool diceRolled = false;

  void _longPressEnd(LongPressEndDetails details){
    setState(() {});
    //side = rand.nextInt(6) + 1;
  }
  void _tapUp(TapUpDetails details){
    setState(() {});
    //side = rand.nextInt(6) + 1;
  }

  GestureDetector _dice(){
    return GestureDetector(
        onLongPressEnd: _longPressEnd,
        onTapUp: _tapUp,
        onTap: (){
          setState(() {

            if(!diceRolled){
              diceVal = rand.nextInt(6) + 1;
              diceRolled = true;
              _checkLegalMoves();
            }
          });
        },
        child:Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("res/textures/pips$diceVal.png"),
              fit: BoxFit.cover,
          )
        )
      )
    );
  }

  Positioned _placePiece(double x, double y,Color col){
    return Positioned(
      top: y,
      left: x,
      child: Icon(Icons.brightness_1,
          color: col),

    );
  }


  void _initPieces(double width, double height){
    double topMargin = 10;
    double sideMargin = 10;
    double pieceSize = 20;

    for(int i = 0; i < 16; i++){
      if(i / 4 < 1){
        pieceIcons[i] = _placePiece(sideMargin, width / 2 - pieceSize + pieceSize*i,Colors.red);
        pieceData[i] = PieceData(21,Colors.red);

      }else if(i / 4 < 2){
        pieceIcons[i] = _placePiece(width / 2 - 3*pieceSize + pieceSize * (i-3), topMargin, Colors.indigo);
        pieceData[i] = PieceData(14,Colors.indigo);

      }else if(i / 4 < 3){
        pieceIcons[i] = _placePiece(width - pieceSize - sideMargin, width / 2 - 2*pieceSize + pieceSize*(i - 7), Colors.green);
        pieceData[i] = PieceData(7,Colors.green);
      }else if(i / 4 < 4){
        pieceIcons[i] = _placePiece(width / 2 - pieceSize*3 + pieceSize*(i-11), width - pieceSize, Colors.yellow);
        pieceData[i] = PieceData(0,Colors.yellow);
      }
    }
  }

  void _double(){
    //TODO
  }

  void _movePiece(int n){
    int move = 0;
    if(pieceData[n].atHome == true && diceVal == 6){
      move = 1;
      pieceData[n].atHome = false;
      _double();
    }else{
      move = diceVal;
    }
    pieceData[n].steps += move;
    pieceData[n].pos += move;
    pieceData[n].steps == 1 ? pieceData[n].isMine = true : pieceData[n].isMine = false;
    //loop board
    if(pieceData[n].pos > 27) pieceData[n].pos -= 28;

    pieceIcons[n] = _placePiece(board[pieceData[n].pos][0], board[pieceData[n].pos][1], pieceData[n].color);
  }

  List<bool> legalMoves = [true,true,true,true];

  void _checkLegalMoves(){

    List<PieceData> data = [];
    List<List<int>> pieces = _findPiece(cur);
    data.add(pieceData[pieces[0][1]]);
    data.add(pieceData[pieces[1][1]]);
    data.add(pieceData[pieces[2][1]]);
    data.add(pieceData[pieces[3][1]]);
    
    legalMoves.setAll(0, [true, true, true, true]);


    if(diceVal != 6){
      for(int i = 0; i < 4; i++){
        if(data[i].atHome) legalMoves[i] = false;
      }

      //test for a friendly piece in the same spot
      for(int i = 0; i < 4; i++){
        int nextPos = data[i].pos + diceVal;
        if(nextPos > 27) nextPos -= 28;
        var samePos = data.where((piece) => piece.pos == nextPos);
        if(samePos.length > 0) legalMoves[i] = false;
      }
    }else{
      for(int i = 0; i < 4; i++){
        if(data[i].atHome) legalMoves[i] = true;
      }
    }

  }

  void _handleTurn(int idx){

    if(cur == Turn.RED){
      cur = Turn.BLUE;
    }else if(cur == Turn.BLUE){
      cur = Turn.GREEN;
    }else if(cur == Turn.GREEN){
      cur = Turn.YELLOW;
    }else if(cur == Turn.YELLOW){
      cur = Turn.RED;
    }

    if(idx != null) _movePiece(idx);

    //update selected piece to first piece of next player
    _radioGroupVal = 3;
    selectedPiece = _findPiece(cur)[_radioGroupVal][1];

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

  Widget build(BuildContext context){

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    if(first) {
      _initBoard(width);
      _initPieces(width, height);
      _createBoardIcons();
      first = false;
    }

    //add all widgetts to a signle list
    List<Widget> all = [];
    //board
    all.add(Container(
      margin: const EdgeInsets.all(10.0),
      color: Colors.amber[600],
      width: width,
      height: width,
    ));

    all.addAll(boardIcons);
    all.addAll(pieceIcons);

    //dice
    all.add(Positioned(
      top: width / 2 - 15,
      left: width / 2 - 15,
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

