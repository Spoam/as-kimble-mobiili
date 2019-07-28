import 'package:flutter/material.dart';
import 'package:kimble/player.dart';

class PlayerSelectScreen extends StatefulWidget{

  @override
  _PlayerSelectScreenState createState() => _PlayerSelectScreenState();
}
class _PlayerSelectScreenState extends State<PlayerSelectScreen>{


  List<FocusNode> focusNodes = List.generate(8, (node) => FocusNode());

  final redNameReader = TextEditingController(text: 'Punaiset');
  final redCountReader = TextEditingController(text: '1');

  final blueNameReader = TextEditingController(text: 'Siniset');
  final blueCountReader = TextEditingController(text: '1');

  final greenNameReader = TextEditingController(text: 'Vihreät');
  final greenCountReader = TextEditingController(text: '1');

  final yellowNameReader = TextEditingController(text: 'Keltaiset');
  final yellowCountReader = TextEditingController(text: '1');


  void _nextFocus(BuildContext context, int i){
    focusNodes[i].unfocus();
    FocusScope.of(context).requestFocus(focusNodes[i + 1]);

  }

  void _startGame(){
    try{

      Player red = Player(redNameReader.text, Colors.red, int.parse(redCountReader.text));
      Player blue = Player(blueNameReader.text, Colors.indigo, int.parse(blueCountReader.text));
      Player green = Player(greenNameReader.text, Colors.green, int.parse(greenCountReader.text));
      Player yellow = Player(yellowNameReader.text, Colors.yellow, int.parse(yellowCountReader.text));

      Navigator.of(context).pushNamed('/playerselect/game', arguments: [red, blue, green, yellow]);

    }on FormatException catch(e){
      _showDialog(e.message);
    }
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

  @override
  void dispose(){
    redNameReader.dispose();
    redCountReader.dispose();
    blueNameReader.dispose();
    blueCountReader.dispose();
    greenNameReader.dispose();
    greenCountReader.dispose();
    yellowNameReader.dispose();
    yellowCountReader.dispose();
    super.dispose();
  }

    @override
    Widget build(BuildContext context){

      double width = MediaQuery.of(context).size.width - 20;

      double pieceSize = width / 13;


      return Scaffold(
        backgroundColor: Colors.white30,
        appBar: AppBar(
        title:Text('Pelaajat'),
        ),
        body:ListView(

          children:[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              textBaseline: TextBaseline.alphabetic,
              mainAxisAlignment:  MainAxisAlignment.center,
              children:[
              Container(
                width: width / 2,
                margin: EdgeInsets.fromLTRB(10, 10, 2.5, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),                child:
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    textAlign: TextAlign.center,
                    focusNode: focusNodes[0],
                    onFieldSubmitted :(term){
                      _nextFocus(context, 0);
                    },
                    controller: redNameReader,
                    style: TextStyle(
                      fontSize: pieceSize,
                    ),
                    decoration: InputDecoration.collapsed(
                      hintText: 'Punaiset',
                    ),
                  ),
              ),

              Container(
                margin: EdgeInsets.fromLTRB(2.5, 10, 0, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                ),
                child: Icon(Icons.accessibility_new, color: Colors.red, size:pieceSize*1.175),
              ),

              Container(
                width: pieceSize,
                margin: EdgeInsets.fromLTRB(0, 10, 10, 10),
                color: Colors.white,
                child:
                  TextFormField(
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    textAlign: TextAlign.center,
                    focusNode: focusNodes[1],
                    onFieldSubmitted: (term){
                      _nextFocus(context, 1);
                    },
                    controller: redCountReader,
                    style: TextStyle(
                      fontSize: pieceSize,
                    ),
                    decoration: InputDecoration.collapsed(
                      hintText: '1',
                    ),
                  ),
              ),
            ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              textBaseline: TextBaseline.alphabetic,
              mainAxisAlignment:  MainAxisAlignment.center,
              children:[
                Container(
                  width: width / 2,
                  margin: EdgeInsets.fromLTRB(10, 10, 2.5, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),                             child:
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      textAlign: TextAlign.center,
                      focusNode: focusNodes[2],
                      onFieldSubmitted :(term){
                        _nextFocus(context, 2);
                      },
                      controller: blueNameReader,
                      style: TextStyle(
                        fontSize: pieceSize,
                      ),
                      decoration: InputDecoration.collapsed(
                        hintText: 'Siniset',
                      ),
                  ),
                ),

                Container(
                  margin: EdgeInsets.fromLTRB(2.5, 10, 0, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                  ),
                  child: Icon(Icons.accessibility_new, color: Colors.blue, size:pieceSize*1.175),
                ),

                Container(
                  width: pieceSize,
                  margin: EdgeInsets.fromLTRB(0, 10, 10, 10),
                  color: Colors.white,
                  child:
                    TextFormField(
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      textAlign: TextAlign.center,
                      focusNode: focusNodes[3],
                      onFieldSubmitted: (term){
                        _nextFocus(context, 3);
                      },
                      controller: blueCountReader,
                      style: TextStyle(
                        fontSize: pieceSize,
                      ),
                      decoration: InputDecoration.collapsed(
                        hintText: '1',
                      ),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              textBaseline: TextBaseline.alphabetic,
              mainAxisAlignment:  MainAxisAlignment.center,
              children:[
                Container(
                  width: width / 2,
                  margin: EdgeInsets.fromLTRB(10, 10, 2.5, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),                             child:
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      textAlign: TextAlign.center,
                      focusNode: focusNodes[4],
                      onFieldSubmitted :(term){
                        _nextFocus(context, 4);
                      },
                      controller: greenNameReader,
                      style: TextStyle(
                        fontSize: pieceSize,
                      ),
                      decoration: InputDecoration.collapsed(
                        hintText: 'Vihreät',
                      ),
                    ),
                ),

                Container(
                  margin: EdgeInsets.fromLTRB(2.5, 10, 0, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                  ),
                  child: Icon(Icons.accessibility_new, color: Colors.green, size:pieceSize*1.175),
                ),

                Container(
                  width: pieceSize,
                  margin: EdgeInsets.fromLTRB(0, 10, 10, 10),
                  color: Colors.white,
                  child:
                    TextFormField(
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      textAlign: TextAlign.center,
                      focusNode: focusNodes[5],
                      onFieldSubmitted: (term){
                        _nextFocus(context, 5);
                      },
                      controller: greenCountReader,
                      style: TextStyle(
                        fontSize: pieceSize,
                      ),
                      decoration: InputDecoration.collapsed(
                        hintText: '1',
                      ),
                    ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              textBaseline: TextBaseline.alphabetic,
              mainAxisAlignment:  MainAxisAlignment.center,
              children:[
                Container(
                  width: width / 2,
                  margin: EdgeInsets.fromLTRB(10, 10, 2.5, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),                             child:
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      textAlign: TextAlign.center,
                      focusNode: focusNodes[6],
                      onFieldSubmitted :(term){
                        _nextFocus(context, 6);
                      },
                      controller: yellowNameReader,
                      style: TextStyle(
                        fontSize: pieceSize,
                      ),
                      decoration: InputDecoration.collapsed(
                        hintText: 'Keltaiset',
                      ),
                    ),
                ),

                Container(
                  margin: EdgeInsets.fromLTRB(2.5, 10, 0, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                  ),
                  child: Icon(Icons.accessibility_new, color: Colors.yellow, size:pieceSize*1.175),
                ),

                Container(
                  width: pieceSize,
                  margin: EdgeInsets.fromLTRB(0, 10, 10, 10),
                  color: Colors.white,
                  child:
                    TextFormField(
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      textAlign: TextAlign.center,
                      focusNode: focusNodes[7],
                      onFieldSubmitted: (term){
                        _nextFocus(context, 7);
                      },
                      controller: yellowCountReader,
                      style: TextStyle(
                        fontSize: pieceSize,
                      ),
                      decoration: InputDecoration.collapsed(
                        hintText: '1',
                      ),
                    ),
                ),
              ],
            ),
            Container(
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
                child: Text('Aloita'),
              )
            ),
            FloatingActionButton(
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