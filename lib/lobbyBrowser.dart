import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kimble/player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kimble/lobby.dart';
import 'dart:math';
import 'dart:core';
import 'package:kimble/colors.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'globals.dart' as G;


class LobbyBrowser extends StatefulWidget{

  @override
  _LobbyBrowser createState() => _LobbyBrowser();
}

class _LobbyBrowser extends State<LobbyBrowser> {

  bool first = true;

  double width;
  double pieceSize;
  String name = "empty";
  int playerCount = 1;

  Widget _buildLobbyTile(int players, int ID){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      textBaseline: TextBaseline.alphabetic,
      mainAxisAlignment:  MainAxisAlignment.center,
      children:[
        GestureDetector(
          onTap: () {
            if(players != 0) {
              Navigator.of(context).pushNamed('/join/lobby', arguments: JoinArguments(ID, JoinType.JOIN, name, playerCount));
            }else {
              Navigator.of(context).pushNamed('/join/lobby', arguments: JoinArguments(ID, JoinType.HOST, name, playerCount));
            }
            },
          child: Container(
            width: width / 2,
            height: pieceSize * 2,
            margin: EdgeInsets.fromLTRB(10, 10, 2.5, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Text("ID:$ID",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: pieceSize * 1.5,
              ),
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
          child: Icon(Icons.accessibility_new, color: Colors.green, size: pieceSize * 2,),
        ),

        Container(
          width: pieceSize*3,
          height: pieceSize * 2,
          margin: EdgeInsets.fromLTRB(0, 10, 10, 10),
          color: Colors.white,
          child:
          Text("$players/4",
            style: TextStyle(
              fontSize: pieceSize*1.5,
            ),
          ),
        ),
      ],
    );
  }

  StreamBuilder<QuerySnapshot> _buildLobbyStream(){

    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("collectionList").snapshots(),
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
                    if (document.exists && document['joinable']){
                      return _buildLobbyTile(_getPlayerCount(document), document['ID']);
                    }else
                      return ListTile();


                  });
          }
        });
  }

  int _getPlayerCount(DocumentSnapshot document){
    int players = 0;
    if(document['red']) players++;
    if(document['blue']) players++;
    if(document['green']) players++;
    if(document['yellow']) players++;
    return players;
  }

  void _ensureEmptyLobby() async{
    int emptyLobbies = 0;
    List<int> usedIDs = [-1];
    CollectionReference lobbyList = Firestore.instance.collection("collectionList");
    QuerySnapshot lobbies = await lobbyList.getDocuments();
    lobbies.documents.forEach((lobby) {
      if(_getPlayerCount(lobby) == 0) {
        emptyLobbies++;
      }else {
        usedIDs.add(lobby['ID']);
      }
    });

    if (emptyLobbies < 1){
      usedIDs.sort();
      int newID = usedIDs.last + 1;
      lobbyList.document(newID.toString()).setData({
        'version' : G.version.substring(0,3),
        'red' : false,
        'blue' : false,
        'green' : false,
        'yellow' : false,
        'ID': newID,
        'joinable' : true});
    }
  }

  Widget build(BuildContext context){

    if(first){
      JoinArguments args = ModalRoute.of(context).settings.arguments;
      name = args.name;
      playerCount = args.teamSize;
      first = false;
      _ensureEmptyLobby();
    }

    width = MediaQuery.of(context).size.width - 20;

    pieceSize = width / 13;

    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.white30,
        appBar: AppBar(
          title:Text('open lobbies').tr(),
        ),
        body: ListView(
          children: [
            _buildLobbyStream(),
          ],
        ),

      ),


    );



  }

}