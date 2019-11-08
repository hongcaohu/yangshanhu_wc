import 'package:flutter/material.dart';

class StatisWidget extends StatefulWidget {

  StatisWidget({Key key, this.space}):super(key: key);

  final double space;

  @override
  _StatisWidgetState createState() {
    return _StatisWidgetState();
  }
}

class _StatisWidgetState extends State {

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Text("AAA"),
          Text("BBB"),
          Text("CCC")
        ],
      ),
    );
  }

}