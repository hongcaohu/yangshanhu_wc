import 'package:flutter/cupertino.dart';

class Cewei extends StatelessWidget {
  Cewei({Key key, this.name, this.left, this.top, this.child})
      : super(key: key);

  final String name;
  final double left;
  final double top;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: child,
    );
  }
}
