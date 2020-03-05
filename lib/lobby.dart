import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kimble/player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'dart:core';
import 'package:kimble/colors.dart';

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

  bool host = false;

  bool first = true;

  double width = 1;
  double pieceSize = 1;

  var sub;

  List<Player> players = [];

  final Map<String, List<TextEditingController>> controllers =
  {
    'red' : [TextEditingController(), TextEditingController(text: '1')],
    'blue' : [TextEditingController(), TextEditingController(text: '1')],
    'green' : [TextEditingController(), TextEditingController(text: '1')],
    'yellow' : [TextEditingController(), TextEditingController(text: '1')]
  };

  TextEditingController nameInput = TextEditingController();


  void _nextFocus(BuildContext context, int i){
    focusNodes[i].unfocus();
    FocusScope.of(context).requestFocus(focusNodes[i + 1]);

  }

  void _startHosting(String name, int teamSize) async{

    final snapshot = await Firestore.instance
        .collection(gameID.toString())
        .document('isActive')
        .get();

    //can't host game with same id unless the game is no longer active
    if (snapshot != null && snapshot.exists) {
      if(snapshot.data['isActive'] == 1){
        //TODO error message here
        return;
      }
    }

    var db = Firestore.instance.collection(gameID.toString());
    db.document('isActive').setData({'isActive' : 1});
    db.document('red').setData({'color' : 'red', 'name' : name, 'team' : teamSize, 'drinks' : 0, 'drunk' : 0, 'raises' : 0});
    players.add(Player(name, Colors.red, teamSize));
    ready[0] = true;

  }

  void _joinLobby(String name, int teamSize) async{

    final snapshot = await Firestore.instance
        .collection(gameID.toString())
        .getDocuments();

    //number of players in lobby. -1 because isActive document
    int index = snapshot.documents.length - 1;

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
        //TODO error lobby is full
        return;

    }

    var db = Firestore.instance.collection(gameID.toString());
    db.document(color).setData({'color' : color, 'name' : name, 'team' : teamSize,'drinks' : 0, 'drunk' : 0, 'raises' : 0});
    players.add(Player(name, getColorFromString(color), teamSize));
    ready[index] = true;
  }

  void _startGame()async{

    QuerySnapshot snapshot = await Firestore.instance.collection(gameID.toString()).getDocuments();

    snapshot.documents.forEach((f) => {
      if (f.data['name'] != null){
        players.add(Player(f.data['name'], getColorFromString(f.data['color']), f.data['team']))
      }
    });

    Navigator.of(context).pushNamed('/playerselect/game', arguments: players);
  }

  void _waitForStart(){
    int timesTriggered = 0;
    CollectionReference reference = Firestore.instance.collection(gameID.toString());
    sub = reference.snapshots().listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((change){
        if(change.document.documentID == 'go'){
          _startGame();
        }
      });
    });
  }

  void _triggerStart(){
    Firestore.instance.collection(gameID.toString()).document('go').setData({'a':1});
  }

  void _showDialog(String message) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Viallinen pelaajamäärä"),
          content: new Text(message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
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
          width: width / 2,
          height: pieceSize * 2,
          margin: EdgeInsets.fromLTRB(10, 10, 2.5, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),                             child:
        TextFormField(
          textInputAction: TextInputAction.next,
          textAlign: TextAlign.center,
          focusNode: focusNodes[nodeID],
          onFieldSubmitted :(term){
            _nextFocus(context, nodeID);
          },
          controller: controllers[colorName][0],
          style: TextStyle(
            fontSize: pieceSize * 1.5,
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
            textInputAction: TextInputAction.next,
            textAlign: TextAlign.center,
            focusNode: focusNodes[nodeID + 1],
            onFieldSubmitted: (term){
              _nextFocus(context, nodeID + 1);
            },
            controller: controllers[colorName][1],
            style: TextStyle(
              fontSize: pieceSize*2,
            ),
            decoration: InputDecoration.collapsed(
              hintText: '1',
            ),
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
      Arguments args = ModalRoute.of(context).settings.arguments;
      gameID = args.id;
      host = args.host;
      String name = args.name;
      int teamSize = args.teamSize;

      if(host){
        _startHosting(name, teamSize);
      }else{
        _joinLobby(name, teamSize);
      }
      _waitForStart();
      first = false;
    }
    width = MediaQuery.of(context).size.width - 20;

    pieceSize = width / 13;


    return Scaffold(
      backgroundColor: Colors.white30,
      appBar: AppBar(
        title:Text('Pelaajat'),
      ),
      body:ListView(

        children:[
          Container(
            width: width / 2,
            height: pieceSize * 2,
            margin: EdgeInsets.fromLTRB(40, 10, 40, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
            child: Text('gameID: ' + gameID.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: pieceSize*1.5,
              ),
            ),
          ),
          _playerStream(),
          ready.every( (elem) => elem ) ? Container( //start button
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
                child: Text('Aloita'),
              )
          ): Container(),
          FloatingActionButton(//back button
            onPressed:(){
              Navigator.pop(context);
            },
            child:Text('back'),
          )
        ],
      ),
    );
  }

}

class _JoinGame extends State<JoinGame> {


  TextEditingController nameInput = TextEditingController();
  TextEditingController gameIDInput = TextEditingController();
  TextEditingController teamSizeInput = TextEditingController(text: '1');

  void _join(){
    Navigator.of(context).pushNamed('/join/lobby', arguments: Arguments(int.parse(gameIDInput.text), false, nameInput.text, int.parse(teamSizeInput.text)));
  }

  void _host(){
    if(nameInput.text.isEmpty) return;
    if(teamSizeInput.text.isEmpty) return;
    if(gameIDInput.text.isEmpty) return;

    Navigator.of(context).pushNamed('/join/lobby', arguments: Arguments(int.parse(gameIDInput.text), true, nameInput.text, int.parse(teamSizeInput.text)));
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
        title: Text('Pelaajat'),
      ),
      body: ListView(

        children: [
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
                controller: nameInput,
                style: TextStyle(
                  fontSize: pieceSize * 1.5,
                ),
                decoration: InputDecoration.collapsed(
                  hintText: 'name here',
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
          Container( //start button
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
                    _join();
                  });
                },
                child: Text('Join'),
              )
          ),
          Container( //start button
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
                    _host();
                  });
                },
                child: Text('Host'),
              )
          ),
          FloatingActionButton( //back button
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('back'),
          )
        ],
      ),
    );
  }
}

class Arguments{
  final int id;
  final bool host;
  final String name;
  final int teamSize;
  Arguments(this.id, this.host, this.name, this.teamSize);
}