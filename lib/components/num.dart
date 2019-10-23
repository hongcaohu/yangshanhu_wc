import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Num extends StatelessWidget {

  Num({ Key key, this.number, this.size=18}) : super(key: key);

  final String number;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(number, style: TextStyle(color: Colors.white, fontSize: this.size),);
  }

}