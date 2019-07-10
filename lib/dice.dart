import 'package:flutter/material.dart';
import 'dart:math';

class Die extends StatefulWidget{

  Die({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _DieState createState() => _DieState();

}

class _DieState extends State<Die>{

  Random rand = Random(1);
  int side = 0;



  void _longPressEnd(LongPressEndDetails details){
    setState(() {});
    //side = rand.nextInt(6) + 1;
  }
  void _tapUp(TapUpDetails details){
    setState(() {});
    //side = rand.nextInt(6) + 1;
  }

  Widget build(BuildContext context){
    return GestureDetector(
      onLongPressEnd: _longPressEnd,
      onTapUp: _tapUp,
      onTap: (){
        setState(() {});
        side = rand.nextInt(6) + 1;

      },
      child:Text('noppa:$side'),

    );
  }
}
