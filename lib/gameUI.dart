import 'package:flutter/material.dart';
import 'package:kimble/colors.dart';
import 'package:kimble/lobby.dart';
import 'package:kimble/piece.dart';
import 'dart:math';
import 'dart:core';
import 'package:kimble/player.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:kimble/gameLogic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kimble/turnManager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'globals.dart' as G;


class GameWindow extends StatefulWidget {
  GameWindow({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _GameWindowState createState() => _GameWindowState();

}

class _GameWindowState extends State<GameWindow> with TickerProviderStateMixin{


  List<AnimatedPositioned> pieceIcons = new List(16);
  List<List<double>> board = new List(28 + 16);
  List<Positioned> boardIcons = new List(44);

  GameLogic logic;

  List<Player> players;
  List<Color> localPlayers;
  bool gameOver = false;
  bool raiseAllowed = true;

  bool online;
  int gameID;
  bool host;
  //database subscription
  var turnSub;
  var drinkSub;
  var answerSub;
  int answerCount = 0;
  List<TurnData> turnBuffer = [];
  int turnsHandled = 0;

  AudioCache sound = AudioCache(prefix: 'sound/');

  AnimationController controller;
  AnimationController diceController;
  Animation<double> diceAnimation;
  Animation<double> slideAnimation;

  double turnTextAnimOffset = 0;
  Duration animDuration = Duration(milliseconds: 0);
  Duration diceAnimDur = Duration(milliseconds: 100);
  double diceAnim = 0;

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
          color = players[0].color;
        } else if ((i - 28) / 4 < 2) {
          color = players[1].color;
        } else if ((i - 28) / 4 < 3) {
          color = players[2].color;
        } else if ((i - 28) / 4 < 4) {
          color = players[3].color;
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


    //raising is being discussed
    if(answerCount != 0) return;

    //if it's not your turn or everyone is in goal
    if(!localPlayers.contains(logic.turn.getCurrent()) || gameOver) return;
    logic.rollDice();

    //set selected piece to first movable
    int idx = logic.getLegalMoves().reversed.toList().indexOf(true);
    if(idx != skipTurn){
      _handleRadioValueChange(3 - idx);
    }else if(logic.getDiceStatus()){
      if(online){
        _writeToDatabase(skipTurn);
      }else{
        _handleTurn(skipTurn, -1);
      }
    }
  }


  void _longPressEnd(LongPressEndDetails details) {
    if(G.soundSettings["naks"]) sound.play('naks-up-1.mp3');
    setState((){
      _rollDice();
    });
  }

  void _tapUp(TapUpDetails details) {
    //sound.play('naks-up-1.mp3');
  }

  void _longPress(){
    diceController.forward();
    if(!G.soundSettings["naks"])sound.play('naks-down1.mp3');
  }

  int attempts = 0;

  GestureDetector _dice() {

    return GestureDetector(
        onLongPressEnd: _longPressEnd,
        onTapUp: _tapUp,
        onLongPress: _longPress,
        onTap: () {
          diceController.forward();
          if(G.soundSettings["naks"])sound.play('naks-koko-2.mp3');

          setState(() {
             _rollDice();
          });
        },
        child: Container(
            width: pieceSize * 1.5 * (1 + 0.2 * diceAnim/100),
            height: pieceSize * 1.5 * (1 + 0.2 * diceAnim/100),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                image: DecorationImage(
                  image: AssetImage("assets/textures/pips${logic.diceVal}.png"),
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

        placePiece(x, y, -1, i, players[0].color, 1, 0);
        logic.pieceData[i] = PieceData(17, players[0].color, [x, y]);
      } else if (i / 4 < 2) {
        double x = (width - (width / 6)) - rowCenter + (pieceSize / sqrt(2)) * (i - 4);
        double y = (width / 6) - rowCenter + (pieceSize / sqrt(2)) * (i - 4);

        placePiece(x, y, -1, i, players[1].color, 1, 0);
        logic.pieceData[i] = PieceData(24, players[1].color, [x, y]);
      } else if (i / 4 < 3) {
        double x = (width - (width / 6)) - rowCenter + (pieceSize / sqrt(2)) * (i - 8);
        double y = (width - (width / 6)) + rowCenter - (pieceSize / sqrt(2)) * (i - 8);

        placePiece(x, y,-1, i, players[2].color, 1, 0);
        logic.pieceData[i] = PieceData(3, players[2].color, [x, y]);
      } else if (i / 4 < 4) {
        double x = (width / 6) - rowCenter + (pieceSize / sqrt(2)) * (i - 12);
        double y = (width - (width / 6)) - rowCenter + (pieceSize / sqrt(2)) * (i - 12);

        placePiece(x, y, -1, i, players[3].color, 1, 0);
        logic.pieceData[i] = PieceData(10, players[3].color, [x, y]);
      }
    }
  }


  void _handleTurn(int idx, int diceRoll){

    if(idx != null){
      idx = idx < 0 ? null : idx;
    }

    logic.handleTurn(idx, diceRoll);

    if(logic.isWinner()){ Navigator.of(context).pushNamed('/playerselect/game/end', arguments: players);}
    //cosmetic. hides piece selection before dice is rolled
    setState((){
      selectedPiece = null;
      controller.reset();
      _handleRadioValueChange(-1);
      if(logic.diceVal != 6) controller.forward();
    });
  }

  /*void _raise(){
    if(logic.getPlayerByColor(logic.turn.getCurrent()).raises > 0){
      if(!players.every((p) => p.acceptRaise)){
        logic.getPlayerByColor(logic.turn.getCurrent()).acceptRaise = true;
        print("raising");
        _listenForAnswer();
        _pollRaise();
      }else{
        _writeToDatabase(raise);
      }

    }else{
      _writeToDatabase(raise);
    }
  }

  void _pollRaise(){
    DocumentReference doc = Firestore.instance.collection(gameID.toString()).document("accept");
    doc.setData({'version' : G.version});
    localPlayers.forEach((color) =>
    {
      doc.collection("players")
          .document("${getStringFromColor(color)}")
          .setData({"answer": true}),
      answerCount++
    });
  }

  void _raiseAnswer(Map<String, bool> data){

    if(!localPlayers.contains(logic.turn.getCurrent())) return;

    print("answer received");
    answerCount++;
    if(answerCount >= 4) {
      answerSub.cancel();
      Firestore.instance.collection(gameID.toString())
          .document("accept")
          .delete();
      answerCount = 0;
    }

      data.forEach((color, answer) => logic.getPlayerByColor(getColorFromString(color)).acceptRaise = answer);

      print("hei");
      print(answerCount);
      if(!players.contains((player) => player.acceptedRaise == false)){
        _writeToDatabase(raise);
      }else if (answerCount == 0){
        setState(() {
          logic.canRaise = false;
        });
      }

  }

  void _pollRaiseMessage(){

    CollectionReference doc = Firestore.instance.collection(gameID.toString()).document("accept").collection("players");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Do you accept another round of raises"),
          content: new Text("All players must accept or it will not happen"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("YES!"),
              onPressed: () {
                sound.play("button.mp3");
                localPlayers.forEach((color) => {
                  logic.getPlayerByColor(color).acceptRaise = true,
                  doc.document("${getStringFromColor(color)}").setData({"answer" : true}),
                  Navigator.pop(context)
                });

              },
            ),
            new FlatButton(
              child: new Text("NO :("),
              onPressed: () {
                sound.play("button.mp3");
                localPlayers.forEach((color) => {
                  logic.getPlayerByColor(color).acceptRaise = false,
                  doc.document("${getStringFromColor(color)}").setData({"answer" : false}),
                  Navigator.pop(context)
                });
              },
            ),
          ],
        );
      },
    );
  }*/

  void _turnFromDatabase(){

    if(turnBuffer.isEmpty) return;

    turnBuffer.sort((a, b) => a.turn.compareTo(b.turn));

    print(turnsHandled);
    print(turnBuffer[0].turn);

    //in this case there is a missing turn and we must wait for more turns to be loaded
    if(turnBuffer[0].turn > turnsHandled) return;
    //int this case the turn has already been handled
    if(turnBuffer[0].turn < turnsHandled){
      print("removing old turn");
      turnBuffer.removeAt(0);
      return;
    }

    turnsHandled++;

    logic.diceVal = turnBuffer[0].diceVal;
    setState(() {
      if(turnBuffer[0].pieceId == raise){
        sound.play('korotus_cheer.mp3');
        logic.raise();
      }else{
        _handleTurn(turnBuffer[0].pieceId, turnBuffer[0].diceVal);
      }

    });

    turnBuffer.removeAt(0);

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


  _editDrinks(Color col){

    Player p = logic.getPlayerByColor(col);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),

          ),
          backgroundColor: Color.fromARGB(255, 50, 50, 50),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: pieceSize * 1.5,
                margin: EdgeInsets.fromLTRB(5, 10, 5, 20),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                child: FlatButton(
                  child: raiseAllowed ? Text('ban_raise', textScaleFactor: 1.5,).tr() : Text('allow_raise', textScaleFactor: 1.5,).tr(),
                  onPressed: () {
                    sound.play("button.mp3");
                    _toggleRaise();
                    Navigator.pop(context);
                  },
                ),
              ),
              Container(
                  height: pieceSize * 2,
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),

                  ),
                  child: Align(alignment: Alignment.center, child: Text("drink_management", textScaleFactor: 1.5,).tr(args: [p.name]))
              ),
              Container(
                height: pieceSize * 1.5,
                margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),

                ),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:[
                    Text('drink_amount', textScaleFactor: 1.5).plural(p.drunk),
                    GestureDetector(
                      child: Icon(Icons.exposure_plus_1, size: pieceSize,),
                      onTap: (){sound.play("button.mp3"); _addDrink(col, 1); Navigator.pop(context);},
                    ),
                    GestureDetector(
                      child: Icon(Icons.exposure_plus_2, size: pieceSize,),
                      onTap: (){sound.play("button.mp3"); _addDrink(col, 2); Navigator.pop(context);},
                    ),
                    GestureDetector(
                      child: Icon(Icons.exposure_neg_1, size: pieceSize,),
                      onTap: (){sound.play("button.mp3"); _addDrink(col, -1); Navigator.pop(context);},
                    ),
                    GestureDetector(
                        child: Icon(Icons.exposure_neg_2, size: pieceSize,),
                        onTap: (){sound.play("button.mp3"); _addDrink(col, -2); Navigator.pop(context);}
                    ),
                  ],
                ),
              ),
              Container(
                height: pieceSize * 1.5,
                margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:[
                    Text('penalty_amount', textScaleFactor: 1.5,).plural(p.drinks),
                    GestureDetector(
                      child: Icon(Icons.exposure_plus_1, size: pieceSize,),
                      onTap: (){sound.play("button.mp3"); _addPenalty(col, 1); Navigator.pop(context);},),
                    GestureDetector(
                        child: Icon(Icons.exposure_plus_2, size:  pieceSize,),
                        onTap: (){sound.play("button.mp3"); _addPenalty(col, 2); Navigator.pop(context);}),
                    GestureDetector(
                      child: Icon(Icons.exposure_neg_1, size: pieceSize,),
                      onTap: (){sound.play("button.mp3"); _addPenalty(col, -1); Navigator.pop(context);},),
                    GestureDetector(
                        child: Icon(Icons.exposure_neg_2, size:  pieceSize,),
                        onTap: (){sound.play("button.mp3"); _addPenalty(col, -2); Navigator.pop(context);}),
                  ],
                ),
              ),
              Container(
                height: pieceSize * 1.5,
                margin: EdgeInsets.fromLTRB(10, 15, 10, 5),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child:FlatButton(
                  child: new Text("back").tr(),
                  onPressed: () {
                    sound.play("button.mp3");
                    Navigator.pop(context);
                    return false;
                  },
                )
              ),
            ],
          ),
        );
      },
    );
  }

  _toggleRaise(){
    if(online){
      raiseAllowed = !raiseAllowed;
      DocumentReference doc = Firestore.instance.collection(gameID.toString()).document("raiseStatus");
      doc.setData({'status' : raiseAllowed, 'version' : G.version.substring(0,3)});
    }else{
      raiseAllowed = !raiseAllowed;
    }
  }

  _addDrink(Color col, int amount){
      if(logic.getPlayerByColor(col).drunk + amount <= logic.getPlayerByColor(col).drinks || amount < 0){
        if(online){
          setState(() {
            logic.getPlayerByColor(col).drunk += amount;
            _addDrinkToDatabase(getStringFromColor(col) ,true);
          });
        }else{
          setState(() {
            logic.getPlayerByColor(col).drunk += amount;
          });
        }
        if(logic.checkWin(col)) Navigator.of(context).pushNamed('/playerselect/game/end', arguments: WinArguments(players, gameID));
      }
  }

  _addPenalty(Color col, int amount){
      if(online){
        setState(() {
          logic.getPlayerByColor(col).drinks += amount;
          _addPenaltyToDatabase(getStringFromColor(col) ,true);
        });
      }else{
        setState(() {
          logic.getPlayerByColor(col).drinks += amount;
        });
      }
      if(logic.checkWin(col)) Navigator.of(context).pushNamed('/playerselect/game/end', arguments: WinArguments(players, gameID));
  }

  _addPenaltyToDatabase(String color, bool drink){
    CollectionReference col = Firestore.instance.collection(gameID.toString());
    if (drink) {
      col.document(color)
          .updateData({'drinks': logic.getPlayerByColor(getColorFromString(color)).drinks});
    }
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
                    host ? IconButton(
                      icon: Icon(Icons.local_bar,size: pieceSize),
                      onPressed: (){
                        sound.play("button.mp3");
                        _editDrinks(col);
                      },
                    ): Container()
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

  void _listenForChanges(){
    CollectionReference reference = Firestore.instance.collection(gameID.toString());
    drinkSub = reference.snapshots().listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((change){
        var doc = change.document;
        //brown means not a color
        if(getColorFromString(doc.documentID) != Colors.brown){
          Player p = logic.getPlayerByColor(getColorFromString(doc.documentID));
          if(turnBuffer.length < 4)p.drunk = doc.data['drunk'];
          if(turnBuffer.length < 4)p.drinks = doc.data['drinks'];
          logic.checkWin(p.color);
          if(logic.isWinner()) Navigator.of(context).pushNamed('/playerselect/game/end', arguments: WinArguments(players, gameID));
        }else if(doc.documentID == "accept"){
          if(!localPlayers.contains(logic.turn.getCurrent())){
            //_pollRaiseMessage();
          }
        }else if(doc.documentID == "raiseStatus"){
          raiseAllowed = doc.data['status'];
        }

      });
    });
  }

  /*void _listenForAnswer(){
    CollectionReference reference = Firestore.instance.collection(gameID.toString()).document("accept").collection("players");
    answerSub = reference.snapshots().listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((change){
        var doc = change.document;
        print(doc.documentID);
        _raiseAnswer({doc.documentID : doc.data["answer"]});
      });

    });
  }*/

  void _addDrinkToDatabase(String color, bool drink) {
    CollectionReference col = Firestore.instance.collection(gameID.toString());
    if (drink) {
      col.document(color)
          .updateData({'drunk': logic.getPlayerByColor(getColorFromString(color)).drunk});
    }
  }



  void _readFromDatabase(){
    CollectionReference reference = Firestore.instance.collection(gameID.toString()).document("turns").collection("turn");
    turnSub = reference.snapshots().listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((change){
        var data = change.document.data;
        turnBuffer.add(TurnData(data['turnCount'], data['color'], data['diceVal'], data['pieceId']));
        _turnFromDatabase();

      });
    });
  }

  void _writeToDatabase(int pieceId){
    DocumentReference doc = Firestore.instance.collection(gameID.toString()).document("turns").collection("turn").document('$turnsHandled');
    doc.setData({'turnCount' : turnsHandled, 'color' : getStringFromColor(logic.turn.getCurrent()), 'pieceId': pieceId, 'diceVal' : logic.diceVal});
  }

  @override
  void initState(){
    super.initState();

    sound.load('naks-koko-2.mp3');
    sound.load('naks-up-1.mp3');
    sound.load('naks-down1.mp3');
    sound.load('korotus_cheer.mp3');
    sound.load("button.mp3");
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

    diceController = AnimationController(
        duration: Duration(milliseconds: 300), vsync: this)
      ..addListener((){
        setState((){
          diceAnim = diceAnimation.value;
        });
      })
      ..addStatusListener((status){
        if(status == AnimationStatus.completed) {
          diceController.reverse();
        }else if (status == AnimationStatus.dismissed){
          diceController.reset();
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

    diceAnimation = Tween<double>(
      begin: 0,
      end: 100,
    ).animate(diceController);

  }

  @override
  dispose(){

    CollectionReference col = Firestore.instance.collection(gameID.toString());
    players.forEach((p) =>{
      col.document(getStringFromColor(p.color)).updateData({'drinks' : logic.getPlayerByColor(p.color).drinks})
    });

    turnSub.cancel();
    drinkSub.cancel();
    answerSub.cancel();
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

      GameArguments args = ModalRoute.of(context).settings.arguments;

      players = args.players;

      players.forEach((player) => player.drinks = 0);

      localPlayers = args.localPlayers;

      online = args.online;
      gameID = args.gameID;
      host = args.host;

      logic = GameLogic(players, placePiece, sound);

      _initBoard(width);
      _initPieces(width);

      _createBoardIcons();

      if(online) {
        _readFromDatabase();
        _listenForChanges();
      }

        first = false;
      }
    
    if(localPlayers.contains(logic.turn.getCurrent())){
      if(logic.piecesInGoal(logic.turn.getCurrent()) == 4){
        gameOver = true;
        //check if all players have all pieces in goal
        //gameOver is set to false if even one player doesn't have all pieces in goal
        players.forEach((player) => gameOver = (logic.piecesInGoal(player.color) == 4 ? gameOver : false));
        if(!gameOver) _writeToDatabase(skipTurn);
      }
    }


    if(turnBuffer.isNotEmpty){
      _turnFromDatabase();
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
      top: (width / 2 - pieceSize / 4 ) * (1 - 0.025 * diceAnim/100),
      left: (width / 2 - pieceSize / 4 ) * (1 - 0.025 * diceAnim/100),
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


    return WillPopScope(
        child: Scaffold(
          backgroundColor: logic.turn.getCurrent(),
          body:ListView(
            children:[
              Stack(
                children:boardStack,
              ),

              logic.getLegalMoves().contains(true) && localPlayers.contains(logic.turn.getCurrent()) ? Container(
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

                            if(online){

                              _writeToDatabase(selectedPiece);

                            }else{

                              if(logic.getLegalMoves().contains(true)) {
                                _handleTurn(selectedPiece, -1);
                              }else{
                                _handleTurn(skipTurn, -1);
                              }
                            }


                          });
                        },
                        child: Text('move').tr(),
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
                          if(raiseAllowed){
                            setState(() {
                              if(online){
                                _writeToDatabase(raise);
                              }else{
                                logic.raise();
                              }

                            });
                          }

                        },
                        child: Text('raise').tr(),
                      ),
                    ) : Container(),
                  ]
              ),

              //player info starts
              _buildPlayerInfo(players[0].color),
              _buildPlayerInfo(players[1].color),
              _buildPlayerInfo(players[2].color),
              _buildPlayerInfo(players[3].color),
            ],

          )
      ),
        onWillPop: () => showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: Text('warning').tr(),
            content: Text('quit_confirm').tr(),
            actions: [
              FlatButton(
                child: Text('yes').tr(),
                onPressed: () => Navigator.pop(c, true),
              ),
              FlatButton(
                child: Text('no').tr(),
                onPressed: () => Navigator.pop(c, false),
              ),
            ],
          ),
        ),
    );
    }
  }

  class WinArguments{
    final List<Player> players;
    final int gameID;
    WinArguments(this.players, this.gameID);
  }