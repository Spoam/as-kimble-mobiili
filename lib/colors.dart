import 'package:flutter/material.dart';
Color getColorFromString(String color){
  switch (color){
    case 'red':
      return Colors.red;

    case 'blue':
      return Colors.indigo;

    case 'yellow':
      return Colors.yellow;

    case 'green':
      return Colors.green;

    default:
      return Colors.brown;
  }
}
