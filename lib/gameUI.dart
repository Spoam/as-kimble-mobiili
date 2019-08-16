import 'package:flutter/material.dart';
import 'package:kimble/piece.dart';
import 'dart:math';
import 'dart:core';
import 'package:kimble/player.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:kimble/gameLogic.dart';


class GameWindow extends StatefulWidget {
  GameWindow({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _GameWindowState createState() => _GameWindowState();

}

class _GameWindowState extends State<GameWindow> with SingleTickerProviderStateMixin{

  List<AnimatedPositioned> pieceIcons = new List(16);
  List<List<double>> board = new List(28 + 16);
  List<Positioned> boardIcons = new List(44);

  GameLogic logic;

  List<Player> players;

  AudioCache sound = AudioCache(prefix: 'sound/');

  AnimationController controller;
  Animation<double> slideAnimation;

  double turnTextAnimOffset = 0;
  Duration animDuration = Duration(milliseconds: 0);

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

    logic.rollDice();

    //set selected piece to first movable
    int idx = logic.getLegalMoves().reversed.toList().indexOf(true);
    if(idx != -1){
      _handleRadioValueChange(3 - idx);
    }else if(logic.getDiceStatus()){
      _handleTurn(null);
    }
  }


  void _longPressEnd(LongPressEndDetails details) {
    sound.play('naks-up-1.mp3');
    setState((){
      _rollDice();
    });
  }

  void _tapUp(TapUpDetails details) {
    //sound.play('naks-up-1.mp3');
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

          sound.play('naks-koko-2.mp3');

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
                  image: AssetImage("res/textures/pips${logic.diceVal}.png"),
                  fit: BoxFit.fill,
                )
            )
        )
    );
  }


  void placePiece(double x, double y, int pos, int index, Color col, int multiplier, int duration) {

    if(pos != -1){
      x = board[pos][0];
      y = board[pos][1];
    }

    pieceIcons[index] =
        AnimatedPositioned(
          duration: Duration(milliseconds: duration),
          curve: Curves.easeInOut,
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

        placePiece(x, y, -1, i, Colors.red, 1, 0);
        logic.pieceData[i] = PieceData(17, Colors.red, [x, y]);
      } else if (i / 4 < 2) {
        double x = (width - (width / 6)) - rowCenter + (pieceSize / sqrt(2)) * (i - 4);
        double y = (width / 6) - rowCenter + (pieceSize / sqrt(2)) * (i - 4);

        placePiece(x, y, -1, i, Colors.indigo, 1, 0);
        logic.pieceData[i] = PieceData(24, Colors.indigo, [x, y]);
      } else if (i / 4 < 3) {
        double x = (width - (width / 6)) - rowCenter + (pieceSize / sqrt(2)) * (i - 8);
        double y = (width - (width / 6)) + rowCenter - (pieceSize / sqrt(2)) * (i - 8);

        placePiece(x, y,-1, i, Colors.green, 1, 0);
        logic.pieceData[i] = PieceData(3, Colors.green, [x, y]);
      } else if (i / 4 < 4) {
        double x = (width / 6) - rowCenter + (pieceSize / sqrt(2)) * (i - 12);
        double y = (width - (width / 6)) - rowCenter + (pieceSize / sqrt(2)) * (i - 12);

        placePiece(x, y, -1, i, Colors.yellow, 1, 0);
        logic.pieceData[i] = PieceData(10, Colors.yellow, [x, y]);
      }
    }
  }


  void _handleTurn(int idx){

    logic.handleTurn(idx);

    //cosmetic. hides piece selection before dice is rolled
    setState((){
      selectedPiece = null;
      controller.reset();
      _handleRadioValueChange(-1);
      if(logic.diceVal != 6) controller.forward();
    });

  }

  int selectedPiece;

  void _handleRadioValueChange(int value) {
    setState(() {
      _radioGroupVal = value;

      switch (_radioGroupVal) {
        case 0:
          selectedPiece = logic.findPiece(logic.turn.getCurrent())[0][1];
          break;
      case 1:
          selectedPiece = logic.findPiece(logic.turn.getCurrent())[1][1];
          break;
      case 2:
          selectedPiece = logic.findPiece(logic.turn.getCurrent())[2][1];
          break;
      case 3:
          selectedPiece = logic.findPiece(logic.turn.getCurrent())[3][1];
          break;

    }
    });
  }


  Widget _buildPlayerInfo(Color col){
    return Container(
              margin: const EdgeInsets.fromLTRB(10,5,10,5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    Row(
                      children:logic.getPlayerByColor(col).getPlayerInfo(pieceSize),
                    ),
                    IconButton(
                      icon: Icon(Icons.plus_one,size: pieceSize),
                      onPressed: (){
                        setState((){
                          logic.getPlayerByColor(col).drunk++;
                          logic.checkWin(col);
                        });
                      },
                    )
                  ]
              ),
            );
  }

  Widget _showSelected(){

      return Positioned(
      top: pieceIcons[selectedPiece].top - pieceSize / 3.0 / 2.0 ,
      left: pieceIcons[selectedPiece].left - pieceSize / 3.0 / 2.0,
      child: Icon(Icons.gps_not_fixed, color: Colors.black, size: pieceSize + pieceSize / 3.0)
    );
  }

  @override
  void initState(){
    super.initState();

    sound.load('naks-koko-2.mp3');
    sound.load('naks-up-1.mp3');
    sound.load('naks-down1.mp3');
    sound.disableLog();

    controller = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this)
    ..addListener((){
      setState((){
        turnTextAnimOffset = slideAnimation.value;
      });
    })
    ..addStatusListener((status){
      if(status == AnimationStatus.completed){
        controller.reset();
      }
    });

    slideAnimation = Tween<double>(
      begin: 0,
      end: 100,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.slowMiddle,
      ),
    );

  }

  @override
  dispose(){
    controller.dispose();
    super.dispose();
  }

  bool first = true;

  int _radioGroupVal = -1;

  double pieceSize = 20;

  Widget build(BuildContext context){


    double width = MediaQuery.of(context).size.width - 20;

    pieceSize = width / 13;

    if(first) {

      double width = MediaQuery.of(context).size.width - 20;

      players = ModalRoute.of(context).settings.arguments;

      logic = GameLogic(players, placePiece, sound);

      _initBoard(width);
      _initPieces(width);

      _createBoardIcons();

      first = false;
    }

    //add all board widgets to a single list
    List<Widget> boardStack = [];
    //board
    boardStack.add(Container(
      margin: const EdgeInsets.fromLTRB(10,10,10,5),
      decoration : BoxDecoration(
        color: Colors.lightBlueAccent,
        borderRadius: BorderRadius.all(Radius.circular(pieceSize * 2)),
      ),

      width: width,
      height: width,
    ));

    boardStack.addAll(boardIcons);
    boardStack.addAll(pieceIcons);

    if(selectedPiece != null) boardStack.add(_showSelected());

    //dice
    boardStack.add(Positioned(
      top: width / 2 - pieceSize / 4,
      left: width / 2 - pieceSize / 4,
      child:_dice(),
    ));

    Positioned turnText = Positioned(
      top: width / 2 - pieceSize * 2,
      left: width + pieceSize - ((width) * turnTextAnimOffset/80),
      child:Stack(
        children:[
          Text(
            logic.getPlayerByColor(logic.turn.getCurrent()).name,
            style: TextStyle(
              fontSize: pieceSize,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = pieceSize / 15
                ..color = Colors.black,
            ),
          ),
          Text(
            logic.getPlayerByColor(logic.turn.getCurrent()).name,
            style: TextStyle(
              fontSize: pieceSize,
              color: logic.turn.getCurrent(),
            ),
          )
        ],
      )

    );
    boardStack.add(turnText);

    return Scaffold(
        backgroundColor: logic.turn.getCurrent(),
        body:ListView(
          children:[
            Stack(
              children:boardStack,
            ),

            logic.getLegalMoves().contains(true) ? Container(
              height: 70,
              margin: const EdgeInsets.fromLTRB(10,5,10,5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child:Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  logic.getLegalMoves()[0] ? Column(
                    children:[
                      Radio(
                        value: 0,
                        groupValue: _radioGroupVal,
                        onChanged: _handleRadioValueChange,
                        ),
                        logic.getStatusText(0),
                      ]
                  ): Container(),

                  logic.getLegalMoves()[1] ? Column(
                    children:[
                      Radio(
                        value: 1,
                        groupValue: _radioGroupVal,
                        onChanged: _handleRadioValueChange,
                      ),
                      logic.getStatusText(1),
                    ]
                  ) : Container(),

                  logic.getLegalMoves()[2] ? Column(
                    children:[
                      Radio(
                        value: 2,
                        groupValue: _radioGroupVal,
                        onChanged: _handleRadioValueChange,
                       ),
                      logic.getStatusText(2),
                    ]
                  ) : Container(),

                  logic.getLegalMoves()[3] ? Column(
                    children:[
                      Radio(
                        value: 3,
                        groupValue: _radioGroupVal,
                        onChanged: _handleRadioValueChange,
                      ),
                      //no need to check for doubling because first piece can never double
                      logic.getStatusText(3),
                    ]
                  ) : Container(),
                ],

              ),
            ): Container(),

            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  logic.getDiceStatus() ?  Container(
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
                          if(logic.getLegalMoves().contains(true)) {
                            _handleTurn(selectedPiece);
                          }else{
                            _handleTurn(null);
                          }
                        });
                      },
                      child: Text('Liiku'),
                    ),
                  ) : Container(),
                  logic.canRaise ? Container(
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
                          logic.raise();
                          _handleTurn(null);
                        });
                      },
                      child: Text('Korota'),
                    ),
                  ) : Container(),
                ]
            ),

            //player info starts
            _buildPlayerInfo(Colors.red),
            _buildPlayerInfo(Colors.indigo),
            _buildPlayerInfo(Colors.green),
            _buildPlayerInfo(Colors.yellow),
          ],

        )
    );
    }
  }