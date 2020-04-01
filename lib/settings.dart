import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kimble/gameUI.dart';
import 'package:kimble/winScreen.dart';
import 'package:kimble/playerSelect.dart';
import 'package:kimble/lobby.dart';
import 'package:package_info/package_info.dart';
import 'globals.dart' as G;

class Settings extends StatefulWidget {

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  Widget _buildToggle(String name, double width) {
    return Container(
        width: width,
        margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child:Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(name,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: width / 12
              ),),
            Switch(
                value: G.soundSettings[name],
                onChanged: (value){setState(() {
                    G.soundSettings[name] = value;
                    })
                ;})
          ],
          )
    );
  }

  @override
  Widget build(BuildContext context){

    double width = MediaQuery.of(context).size.width - 20;

    return Scaffold(
      appBar: AppBar(
        title:Text('Kimble'),
      ),
      body:ListView(
          children: [
            Container(
              width: width,
              margin: const EdgeInsets.all(10),
              child: Text("Sound Settings",
                style: TextStyle(
                  fontSize: width / 10
                ),),
            ),
            _buildToggle("triple", width),
            _buildToggle("eat", width),
            _buildToggle("korotus", width),
            _buildToggle("naks", width),
            _buildToggle("mine", width),
            Container(
              width: width / 5,
              margin: const EdgeInsets.fromLTRB(10,10,10,10),
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
              child:MaterialButton(
                onPressed:(){
                    Navigator.pop(context);
                  }
                  ,
                child:Text('Back'),
              ),


            ),
          ]),
    );

  }
}