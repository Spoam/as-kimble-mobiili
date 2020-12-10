import 'package:flutter/material.dart';
import 'package:kimble/gameUI.dart';
import 'package:kimble/player.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'globals.dart' as G;


class WinScreen extends StatefulWidget{

  _WinState createState() => _WinState();
}

class _WinState extends State<WinScreen>{

  List<Player> players;

  void _findMoralWinner(){

    players.sort((playerA,playerB) => (playerB.drunk/playerB.players).compareTo(playerA.drunk/playerA.players));

    Iterable<Player> drinks = players.where((player) => player.drunk/player.players == players[0].drunk/players[0].players);

    drinks.forEach((player) => player.moralWinner = true);

  }

  Widget _buildResultBar(int index, double size){

    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:[
          Row(children: players[index].getPlayerInfo(size)),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              players[index].winner ? Icon(Icons.stars, size: size, color: Colors.amberAccent) : Container(),
              players[index].moralWinner ? Icon(Icons.delete, size: size, color: Colors.black38) : Container(),
            ]
          )

        ],
      ),
    );
  }

  _clearGame(int gameID) async{
    CollectionReference ref = Firestore.instance.collection(gameID.toString());
    QuerySnapshot docs = await ref.getDocuments();
    docs.documents.forEach((doc) {doc.reference.delete();});

    CollectionReference collectionList = Firestore.instance.collection("collectionList");
    collectionList.document(gameID.toString()).setData({
      'version' : G.version.substring(0,3),
      'ID' : gameID,
      'joinable' : true,
      'red' : false,
      'blue' : false,
      'green' : false,
      'yellow' : false});

  }

  @override
  Widget build(BuildContext context){

    WinArguments args = ModalRoute.of(context).settings.arguments;
    players = args.players;
    int gameID = args.gameID;

    _findMoralWinner();
    _clearGame(gameID);

    double width = MediaQuery.of(context).size.width;

    double pieceSize = width / 13;

    return Scaffold(
      backgroundColor: Colors.white30,
      appBar: AppBar(
        title:Text('results').tr(),
      ),
      body:ListView(
        children:[
          _buildResultBar(0, pieceSize),
          _buildResultBar(1, pieceSize),
          _buildResultBar(2, pieceSize),
          _buildResultBar(3, pieceSize),

          FloatingActionButton(
            onPressed:(){
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
            child:Text('back to menu').tr(),
          ),
        ],
      ),

    );

  }


}
