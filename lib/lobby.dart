import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kimble/player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'dart:core';
import 'package:kimble/colors.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'globals.dart' as G;


class HostGame extends StatefulWidget{

  @override
  _HostGame createState() => _HostGame();
}

class JoinGame extends StatefulWidget{
  @override
  _JoinGame createState() => _JoinGame();
}

class _HostGame extends State<HostGame>{

  List<FocusNode> focusNodes = List.generate(8, (node) => FocusNode());

  List<bool> ready = [false, false, false, false];

  Random rand = Random(DateTime.now().microsecond);

  int gameID;
  String oldName;

  bool host = false;

  bool first = true;

  double width = 1;
  double pieceSize = 1;

  bool initReady = false;

  var sub;

  List<Player> players = [];
  List<Color> localPlayers = [];

  final Map<String, List<TextEditingController>> controllers =
  {
    'red' : [TextEditingController(), TextEditingController(text: '1')],
    'blue' : [TextEditingController(), TextEditingController(text: '1')],
    'green' : [TextEditingController(), TextEditingController(text: '1')],
    'yellow' : [TextEditingController(), TextEditingController(text: '1')]
  };

  TextEditingController localPlayerNameInput = TextEditingController();
  TextEditingController localPlayerCountInput = TextEditingController(text: '1');

  TextEditingController nameInput = TextEditingController();


  void _nextFocus(BuildContext context, int i){
    focusNodes[i].unfocus();
    FocusScope.of(context).requestFocus(focusNodes[i + 1]);

  }

  void _startHosting(String name, int teamSize) async{

    ready[0] = true;

    final snapshot = await Firestore.instance
        .collection(gameID.toString())
        .document('red')
        .get();

    //can't host game with same id unless the game is no longer active
    if (snapshot != null && snapshot.exists) {
        _showDialog(context ,"A lobby with that ID already exists");
        return;
    }

    var db = Firestore.instance.collection(gameID.toString());
    print(G.version.substring(0,3));
    //db.document('isActive').setData({'version' : G.version.substring(0,3), 'isActive' : true});
    db.document('red').setData({
      'color' : 'red',
      'name' : name,
      'team' : teamSize,
      'drinks' : 0,
      'drunk' : 0,
      'raises' : 0,
      'version' : G.version.substring(0,3)});

    final verification = await Firestore.instance
        .collection(gameID.toString())
        .document('red')
        .get();

    if(!verification.exists){
      _showDialog(context ,"Lobby creation failed");
      return;
    }

    var collections = Firestore.instance.collection("collectionList");
    collections.document(gameID.toString()).setData({
      'version' : G.version.substring(0,3),
      'joinable' : true,
      'red' : true,
      'blue' : false,
      'green' : false,
      'yellow' : false,
      'ID':gameID});


    //players.add(Player(name, Colors.red, teamSize));
    localPlayers.add(Colors.red);
    ready[0] = true;
    initReady = true;
  }

  void _joinLobby(String name, int teamSize) async{

    final snapshot = await Firestore.instance
        .collection(gameID.toString())
        .getDocuments();

    //number of players in lobby. -1 because isActive document
    int index = snapshot.documents.length;

    ready.setRange(0, index, [true, true, true, true]);

    //this means there is no host
    assert(index != 0);

    String color = "red";

    switch (index){

      case 1:
        color = "blue";
        break;

      case 2:
        color = "green";
        break;

      case 3:
        color = "yellow";
        break;

      case 4:
        _showDialog(context, "Lobby is full");
        return;

      default:
        return;

    }

    var db = Firestore.instance.collection(gameID.toString());
    db.document(color).setData({'color' : color, 'name' : name, 'team' : teamSize,'drinks' : 0, 'drunk' : 0, 'raises' : 0, 'version' : G.version.substring(0,3)});
    //players.add(Player(name, getColorFromString(color), teamSize));

    var collections = Firestore.instance.collection("collectionList");
    collections.document(gameID.toString()).setData({'version' : G.version.substring(0,3), color : true}, merge: true);
    
    localPlayers.add(getColorFromString(color));
    ready[index] = true;
    initReady = true;
  }

  void _startGame(bool cont) async{

    QuerySnapshot snapshot = await Firestore.instance.collection(gameID.toString()).getDocuments();

    var collections = Firestore.instance.collection("collectionList");
    collections.document(gameID.toString()).setData({'version' : G.version.substring(0,3), 'joinable' : false}, merge: true);

    snapshot.documents.forEach((f) => {
      if (f.data['name'] != null){
        players.add(Player(f.data['name'], getColorFromString(f.data['color']), f.data['team']))
      }
    });

    if(cont && (players.length != 4)) _showDialog(context, "can't continue game not in progress");

    //makes sure that player indexes are same for all users
    List<Player> args = List(4);
    args[0] = players.firstWhere((test) => test.color == Colors.red);
    args[1] = players.firstWhere((test) => test.color == Colors.indigo);
    args[2] = players.firstWhere((test) => test.color == Colors.green);
    args[3] = players.firstWhere((test) => test.color == Colors.yellow);

    //continue playing as the correct player
    if(cont) localPlayers.add(players.firstWhere((p) => p.name == oldName).color);

    //stop listening
    sub.cancel();

    Navigator.of(context).pushNamed('/playerselect/game', arguments: GameArguments(args, true, localPlayers, localPlayers.contains(Colors.red), gameID));
  }


  void _waitForStart(){

    CollectionReference reference = Firestore.instance.collection(gameID.toString());
    var list = Firestore.instance.collection("collectionList");
    sub = reference.snapshots().listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((change){

        int index = querySnapshot.documents.length - 1;

        reference.document("red").get()
            .then((doc) {
              if(!doc.exists && !host){
                //list.document(gameID.toString()).setData({'version' : G.version.substring(0,3), 'joinable' : false}, merge: true);
                _showDialog(context ,"host has left");
              }
        });

        if(index <= 4 && index >= 0) setState(() {
          ready.setRange(0, index, [true, true, true, true]);
        });

        if(change.document.documentID == 'go'){
          if(initReady) _startGame(false);
        }

      });
    });
  }

  void _triggerStart(){
    Firestore.instance.collection(gameID.toString()).document('go').setData({'version':G.version.substring(0,3)});
  }

  void _showDialog(BuildContext context, String message) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Failed to connect"),
          content: new Text(message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("back").tr(),
              onPressed: () {
                _leave();
                Navigator.of(context).popUntil(ModalRoute.withName('/join'));
              },
            ),
          ],
        );
      },
    );
  }

  _showLeaveWarning(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("warning").tr(),
          content: new Text("are_you_sure").tr(),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("leave").tr(),
              onPressed: () {
                _leave();
                Navigator.of(context).popUntil(ModalRoute.withName('/join'));
                return true;
              },
            ),
            new FlatButton(
              child: new Text("cancel").tr(),
              onPressed: () {
                Navigator.pop(context);
                return false;
              },
            ),
          ],
        );
      },
    );
  }

  Widget _waitingForPlayer(){

    return Container(
      child: Text('Waiting for player...',
        style: TextStyle(
          fontSize: pieceSize * 1.5,
        ),
      ),
    );
  }

  Widget _buildPlayerInput(width, color, nodeID, colorName){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      textBaseline: TextBaseline.alphabetic,
      mainAxisAlignment:  MainAxisAlignment.center,
      children:[
        Container(
          width: width / 1.1,
          height: pieceSize * 2,
          margin: EdgeInsets.fromLTRB(10, 10, 2.5, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),                             child:
        TextFormField(
          textAlign: TextAlign.center,
          controller: localPlayerNameInput,
          textInputAction: TextInputAction.next,
          focusNode: focusNodes[nodeID],
          onFieldSubmitted: (term){
            _nextFocus(context, nodeID);
          },
          style: TextStyle(
            fontSize: pieceSize,
          ),
          decoration: InputDecoration.collapsed(
            hintText: colorName,
          ),
        ),
        ),

        Container(
          margin: EdgeInsets.fromLTRB(2.5, 10, 0, 10),
          width: pieceSize * 2,
          height: pieceSize * 2,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
          ),
          child: Icon(Icons.accessibility_new, color: color, size: pieceSize * 2,),
        ),

        Container(
          width: pieceSize*2,
          height: pieceSize * 2,
          margin: EdgeInsets.fromLTRB(0, 10, 10, 10),
          color: Colors.white,
          child:
          TextFormField(
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            textInputAction: TextInputAction.next,
            focusNode: focusNodes[nodeID + 1],
            onFieldSubmitted: (term){
              _nextFocus(context, nodeID + 1);
            },
            controller: localPlayerCountInput,
            style: TextStyle(
              fontSize: pieceSize*2,
            ),
            decoration: InputDecoration.collapsed(
              hintText: '1',
            ),
          ),
        ),
        Container(
          width: pieceSize*2,
          height: pieceSize * 2,
          margin: EdgeInsets.fromLTRB(0, 10, 10, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child:
            MaterialButton(
              onPressed:(){
                if(ready.contains(false)){
                  _joinLobby(localPlayerNameInput.text, int.parse(localPlayerCountInput.text));
                }
                setState(() {
                  localPlayerNameInput.clear();
                });
              },
              child:Text('+', textScaleFactor: 3,),
            ),
        ),
      ],
    );
  }

  _buildPlayerTile(String name, String color, playerCount){

    if (name == null || color == null){
      return Container();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      textBaseline: TextBaseline.alphabetic,
      mainAxisAlignment:  MainAxisAlignment.center,
      children:[
        Container(
          width: width / 1.5,
          height: pieceSize * 2,
          margin: EdgeInsets.fromLTRB(10, 10, 2.5, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Text(name,
            textAlign: TextAlign.center,
            style: TextStyle(
            fontSize: pieceSize * 1.5,
            ),
          ),
        ),

        Container(
          margin: EdgeInsets.fromLTRB(2.5, 10, 0, 10),
          width: pieceSize * 2,
          height: pieceSize * 2,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
          ),
          child: Icon(Icons.accessibility_new, color: getColorFromString(color), size: pieceSize * 2,),
        ),

        Container(
          width: pieceSize*2,
          height: pieceSize * 2,
          margin: EdgeInsets.fromLTRB(0, 10, 10, 10),
          color: Colors.white,
          child:
          Text(playerCount.toString(),
            style: TextStyle(
              fontSize: pieceSize*2,
            ),
            ),
          ),
      ],
    );
  }

  void _leave(){
    CollectionReference reference = Firestore.instance.collection(gameID.toString());
    CollectionReference collectionList = Firestore.instance.collection("collectionList");
    localPlayers.forEach((p) => {
      reference.document(getStringFromColor(p)).delete(),
      collectionList.document(gameID.toString()).setData({"version" : G.version.substring(0,3), getStringFromColor(p) : false}, merge: true)
    });
    //if(host) reference.document("isActive").delete();
  }

  StreamBuilder<QuerySnapshot> _playerStream(){

    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection(gameID.toString()).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              return new Text('Loading...');
          default:
            return new ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext context, int index) {
                  final DocumentSnapshot document = snapshot.data.documents[index];
                  return _buildPlayerTile(document['name'], document['color'], document['team']);

              });
          }
      });
  }



  @override
  void dispose(){
    sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){

    if(first){
      JoinArguments args = ModalRoute.of(context).settings.arguments;
      gameID = args.id;
      JoinType type = args.type;
      String name = args.name;
      int teamSize = args.teamSize;
      host = type == JoinType.HOST;

      if(host){
        _startHosting(name, teamSize);

      }else if(type == JoinType.JOIN){
        _joinLobby(name, teamSize);

      }else if(type == JoinType.CONTINUE){
        oldName = name;
        _startGame(true);
      }else if(type == JoinType.SPECTATE){
        _startGame(false);
      }
      _waitForStart();
      first = false;
    }

    width = MediaQuery.of(context).size.width - 20;

    pieceSize = width / 13;

    return WillPopScope(
        child:Scaffold(
          backgroundColor: Colors.white30,
          appBar: AppBar(
            title:Text('Lobby'),
          ),
          body:ListView(

        children:[
            Container(
            width: width / 2,
            height: pieceSize * 1.5,
            margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: Text('ID: ' + gameID.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: pieceSize*1.2,
              ),
            ),
          ),
            _playerStream(),
            ready.every( (elem) => elem ) && host ? Container( //start button
              margin: const EdgeInsets.fromLTRB(10,10,10,10),
              width: width / 2 - 20,
              decoration: BoxDecoration(
                  color: Colors.blue,
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
                    _triggerStart();
                  });
                },
                child: Text('Start'),
              )
          ): Container(),

          ready.contains(false) ? _buildPlayerInput(width / 2, Colors.black54, 0, "add local player"): Container(),

          Container( //leave button
              margin: const EdgeInsets.fromLTRB(10,10,10,10),
              width: width / 3 - 20,
              decoration: BoxDecoration(
                  color: Colors.blue,
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
                onPressed: () {
                  _showLeaveWarning();
                },
                child: Text('Leave'),
              )
          ),
        ],
      ),
    ),
      onWillPop: () => showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Warning'),
          content: Text('Are you sure you want to leave?'),
          actions: [
            FlatButton(
              child: Text('Leave'),
              onPressed: () {
                _leave();
                Navigator.of(context).popUntil(ModalRoute.withName('/join'));
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(c, false),
            ),
          ],
        ),
      ),
    );
  }

}

class _JoinGame extends State<JoinGame> {


  TextEditingController nameInput = TextEditingController();
  TextEditingController gameIDInput = TextEditingController();
  TextEditingController teamSizeInput = TextEditingController(text: '1');

  void _errorMessage(String message){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Error"),
          content: new Text(message).tr(),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("back").tr(),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _join(JoinType type){
    if(nameInput.text.isEmpty) {
      _errorMessage("name error");
      return;
    }
    if(teamSizeInput.text.isEmpty) return;
    if(type == JoinType.BROWSE){
      Navigator.of(context).pushNamed('/join/browse', arguments: JoinArguments(-1, type, nameInput.text, int.parse(teamSizeInput.text)));
      return;
    }
    if(gameIDInput.text.isEmpty) return;
    Navigator.of(context).pushNamed('/join/lobby', arguments: JoinArguments(int.parse(gameIDInput.text), type, nameInput.text, int.parse(teamSizeInput.text)));
  }

  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width - 20;

    double pieceSize = width / 13;


    return Scaffold(
      backgroundColor: Colors.white30,
      appBar: AppBar(
        title: Text('Online ver ${G.version}'),
      ),
      body: ListView(

        children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          textBaseline: TextBaseline.alphabetic,
          mainAxisAlignment:  MainAxisAlignment.center,
          children:[
            Container(
                  width: width / 2,
                  height: pieceSize * 2,
                  margin: EdgeInsets.fromLTRB(10, 10, 2.5, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: TextFormField(
                textInputAction: TextInputAction.next,
                textAlign: TextAlign.center,
                maxLength : 20,
                controller: nameInput,
                style: TextStyle(
                  fontSize: pieceSize * 1.5,
                ),
                decoration: InputDecoration(
                  hintText: 'name',
                  counter: Offstage(),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                ),
              ),
              ),

              Container(
                margin: EdgeInsets.fromLTRB(2.5, 10, 0, 10),
                width: pieceSize * 2,
                height: pieceSize * 2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                ),
                child: Icon(Icons.accessibility_new, color: Colors.black54, size: pieceSize * 2,),
              ),

              Container(
                width: pieceSize*2,
                height: pieceSize * 2,
                margin: EdgeInsets.fromLTRB(0, 10, 10, 10),
                color: Colors.white,
                child:
                TextFormField(
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  textAlign: TextAlign.center,
                  controller: teamSizeInput,
                  style: TextStyle(
                    fontSize: pieceSize*2,
                  ),
                  decoration: InputDecoration.collapsed(
                    hintText: '1',
                  ),
                ),
              ),
            ],
          ),
          Container( //spectate
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            width: width / 2 - 20,
            decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black54,
                      offset: Offset(1, 1),
                      blurRadius: 0.5,
                      spreadRadius: 0.5
                  ),
                ]
            ),
            child: MaterialButton(
              onPressed: () {
                setState(() {
                  _join(JoinType.BROWSE);
                });
              },
              child: Text('browse').tr(),
            ),
          ),

          Container( //direct connect button
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              width: width / 2 - 20,
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black54,
                        offset: Offset(1, 1),
                        blurRadius: 0.5,
                        spreadRadius: 0.5
                    ),
                  ]
              ),
              child: MaterialButton(
                onPressed: () {
                  setState(() {
                    _join(JoinType.JOIN);
                  });
                },
                child: Text('join direct').tr(),
              )
          ),
          Container( //spectate
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              width: width / 2 - 20,
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black54,
                        offset: Offset(1, 1),
                        blurRadius: 0.5,
                        spreadRadius: 0.5
                    ),
                  ]
              ),
              child: MaterialButton(
                onPressed: () {
                  setState(() {
                    _join(JoinType.SPECTATE);
                  });
                },
                child: Text('spectate').tr(),
              ),
          ),
          Container(
            width: width / 2,
            height: pieceSize * 2,
            margin: EdgeInsets.fromLTRB(40, 10, 40, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: TextFormField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                controller: gameIDInput,
                style: TextStyle(
                  fontSize: pieceSize*1.5,
                ),
                decoration: InputDecoration.collapsed(
                  hintText: 'game id',

                )
            ),
          ),
          FloatingActionButton( //back button
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('back').tr(),
          ),

        ],
      ),

    );
  }
}

class JoinArguments{
  final int id;
  final JoinType type;
  final String name;
  final int teamSize;
  JoinArguments(this.id, this.type, this.name, this.teamSize);
}

class GameArguments{
  final List<Player> players;
  final bool online;
  final List<Color> localPlayers;
  final int gameID;
  final bool host;
  GameArguments(this.players, this.online, this.localPlayers, this.host, this.gameID);
}

enum JoinType{
  HOST,
  JOIN,
  CONTINUE,
  SPECTATE,
  BROWSE
}