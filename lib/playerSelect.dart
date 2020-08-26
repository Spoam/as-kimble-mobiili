import 'package:flutter/material.dart';
import 'package:kimble/lobby.dart';
import 'package:kimble/player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';


class PlayerSelectScreen extends StatefulWidget{

  @override
  _PlayerSelectScreenState createState() => _PlayerSelectScreenState();
}

class Lobby extends PlayerSelectScreen{

  @override
  _LobbyState createState() => _LobbyState();
}


class _PlayerSelectScreenState extends State<PlayerSelectScreen>{


  List<FocusNode> focusNodes = List.generate(8, (node) => FocusNode());

  final Map<String, List<TextEditingController>> controllers =
  {
    'red' : [TextEditingController(), TextEditingController(text: '1')],
    'blue' : [TextEditingController(), TextEditingController(text: '1')],
    'green' : [TextEditingController(), TextEditingController(text: '1')],
    'yellow' : [TextEditingController(), TextEditingController(text: '1')]
  };


  void _nextFocus(BuildContext context, int i){
    focusNodes[i].unfocus();
    FocusScope.of(context).requestFocus(focusNodes[i + 1]);

  }

  void _startGame(){

    if(controllers['red'][0].text.isEmpty) controllers['red'][0].text = "Punaiset";
    if(controllers['blue'][0].text.isEmpty) controllers['blue'][0].text = "Siniset";
    if(controllers['green'][0].text.isEmpty) controllers['green'][0].text = "Vihreät";
    if(controllers['yellow'][0].text.isEmpty) controllers['yellow'][0].text = "Keltaiset";



    try{

      Player red = Player(controllers['red'][0].text, Colors.red, int.parse(controllers['red'][1].text));
      Player blue = Player(controllers['blue'][0].text, Colors.indigo, int.parse(controllers['blue'][1].text));
      Player green = Player(controllers['green'][0].text, Colors.green, int.parse(controllers['green'][1].text));
      Player yellow = Player(controllers['yellow'][0].text, Colors.yellow, int.parse(controllers['yellow'][1].text));

      Navigator.of(context).pushNamed('/playerselect/game', arguments: GameArguments([red, blue, green, yellow], false, [Colors.red, Colors.indigo, Colors.green, Colors.yellow], true, 0));

    }on FormatException catch(e){
      _showDialog(e.message);
    }
  }

  void _continue(){
    //Navigator.of(context).pushNamed('/playerselect/game', arguments: [red, blue, green, yellow]);
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

  Widget _buildPlayerInput(width, pieceSize, color, nodeID, colorName){
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

  @override
  void dispose(){
    super.dispose();
  }

    @override
    Widget build(BuildContext context){

      double width = MediaQuery.of(context).size.width - 20;

      double pieceSize = width / 13;


      return Scaffold(
        backgroundColor: Colors.white30,
        appBar: AppBar(
        title:Text('players').tr(),
        ),
        body:ListView(

          children:[
            _buildPlayerInput(width, pieceSize, Colors.red, 0, 'red'),
            _buildPlayerInput(width, pieceSize, Colors.blue, 2, 'blue'),
            _buildPlayerInput(width, pieceSize, Colors.green, 4, 'green'),
            _buildPlayerInput(width, pieceSize, Colors.yellow, 6, 'yellow'),
            Container( //start button
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
                    _startGame();
                  });
                },
                child: Text('start_play').tr(),
              )
            ),
            Container( //start button
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
                      _continue();
                    });
                  },
                  child: Text('continue').tr(),
                )
            ),
            FloatingActionButton(//back button
              onPressed:(){
              Navigator.pop(context);
              },
              child:Text('back').tr(),
          )
          ],
        ),
      );
    }
}


class _LobbyState extends _PlayerSelectScreenState{

  @override
  void _startGame() async{

    if(controllers['red'][0].text.isEmpty) controllers['red'][0].text = "Punaiset";
    if(controllers['blue'][0].text.isEmpty) controllers['blue'][0].text = "Siniset";
    if(controllers['green'][0].text.isEmpty) controllers['green'][0].text = "Vihreät";
    if(controllers['yellow'][0].text.isEmpty) controllers['yellow'][0].text = "Keltaiset";



    try{

      Player red = Player(controllers['red'][0].text, Colors.red, int.parse(controllers['red'][1].text));
      Player blue = Player(controllers['blue'][0].text, Colors.indigo, int.parse(controllers['blue'][1].text));
      Player green = Player(controllers['green'][0].text, Colors.green, int.parse(controllers['green'][1].text));
      Player yellow = Player(controllers['yellow'][0].text, Colors.yellow, int.parse(controllers['yellow'][1].text));

      Firestore.instance.collection('game').document('Red')
          .setData({'name' : red.name, 'drinks' : 0, 'drunk' : 0, 'raises' : 0});

      await Navigator.of(context).pushNamed('/playerselect/game', arguments: [red, blue, green, yellow]);


    }on FormatException catch(e){
      _showDialog(e.message);
    }
  }
}