import 'package:flutter/material.dart';
import 'package:kimble/dice.dart';
import 'package:kimble/piece.dart';
import 'dart:math';


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
  List<List<double>> board = new List(28*2);
  List<Positioned> boardIcons = new List(28);



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

  Random rand = Random(1);

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
        pieceData[i] = PieceData(0,Colors.red);

      }else if(i / 4 < 2){
        pieceIcons[i] = _placePiece(width / 2 - 3*pieceSize + pieceSize * (i-3), topMargin, Colors.indigo);
        pieceData[i] = PieceData(10,Colors.indigo);

      }else if(i / 4 < 3){
        pieceIcons[i] = _placePiece(width - pieceSize - sideMargin, width / 2 - 2*pieceSize + pieceSize*(i - 7), Colors.green);
        pieceData[i] = PieceData(20,Colors.green);
      }else if(i / 4 < 4){
        pieceIcons[i] = _placePiece(width / 2 - pieceSize*3 + pieceSize*(i-11), width - pieceSize, Colors.yellow);
        pieceData[i] = PieceData(20,Colors.yellow);
      }
    }
  }

  void _movePiece(int n){
    pieceData[n].steps += diceVal;
    pieceIcons[n] = _placePiece(board[pieceData[n].steps][0], board[pieceData[n].steps][1], pieceData[n].color);
  }

  bool first = true;

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
              FloatingActionButton(
                onPressed:(){
                  setState(() {});
                  _movePiece(0);
                },
                child:Text('liiku'),
              )
            ],
          )
      );
    }
  }

