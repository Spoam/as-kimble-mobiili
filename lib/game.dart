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
          setState(() {});
          diceVal = rand.nextInt(6) + 1;

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

  void _movePiece(int n){
    pieceData[n].steps += diceVal;
    pieceData[n].pos += diceVal;
    //loop board
    if(pieceData[n].pos > 27) pieceData[n].pos -= 28;

    pieceIcons[n] = _placePiece(board[pieceData[n].pos][0], board[pieceData[n].pos][1], pieceData[n].color);
  }

  void _handleTurn(int idx){

    if(cur == Turn.RED){
      _movePiece(idx);
      cur = Turn.BLUE;
    }else if(cur == Turn.BLUE){
      _movePiece(idx);
      cur = Turn.GREEN;
    }else if(cur == Turn.GREEN){
      _movePiece(idx);
      cur = Turn.YELLOW;
    }else if(cur == Turn.YELLOW){
      _movePiece(idx);
      cur = Turn.RED;
    }

    //update selected piece to first piece of next player
    selectedPiece = _findPiece(3);
    _radioGroupVal = 3;

  }

  int selectedPiece = 0;

  void _handleRadioValueChange(int value) {
    setState(() {
      _radioGroupVal = value;

      switch (_radioGroupVal) {
        case 0:
          selectedPiece = _findPiece(0);
          break;
      case 1:
          selectedPiece = _findPiece(1);
          break;
      case 2:
          selectedPiece = _findPiece(2);
          break;
      case 3:
          selectedPiece = _findPiece(3);
          break;

    }
    });
  }

  int _findPiece(int idx){

    List<List<int>> order = new List(4);
    int n = 0;
    for(int i = cur.index * 4; i < cur.index * 4 + 4; i++){
      order[n] = [pieceData[i].steps,i];
      n++;
    }
    order.sort((a,b) => a[0].compareTo(b[0]));
    return order[idx][1];
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
                Radio(
                value: 0,
                  groupValue: _radioGroupVal,
                  onChanged: _handleRadioValueChange,
                ),
                Text(
                    'Vika',
                ),

                Radio(
                  value: 1,
                  groupValue: _radioGroupVal,
                  onChanged: _handleRadioValueChange,
                ),
                Text(
                  'Kolmas',
                ),

                Radio(
                  value: 2,
                  groupValue: _radioGroupVal,
                  onChanged: _handleRadioValueChange,
                ),
                Text(
                  'Toka',
                ),
                Radio(
                  value: 3,
                  groupValue: _radioGroupVal,
                  onChanged: _handleRadioValueChange,
                ),
                Text(
                  'Kärki',
                ),


              ],

            ),
            FloatingActionButton(
              onPressed:(){
                setState(() {
                  _handleTurn(selectedPiece);
                });
              },
              child:Text('liiku'),
            ),
            Text('$cur'),
            Text('$selectedPiece'),

          ],
        )
    );
    }
  }

