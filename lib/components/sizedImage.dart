import 'package:flutter/material.dart';

class SizeImage extends StatelessWidget {
  SizeImage(
      {Key key,
      this.index = 99,
      this.width = 15,
      this.height = 30,
      this.url = "assets/images/green.png"})
      : super(key: key);

  final double width;
  final double height;
  final int index;
  final String url;

  @override
  Widget build(BuildContext context) {
    print('SizeImage Widget build: index - $index');
    return Image.asset(
      this.url,
      width: this.width,
      height: this.height,
    );
  }
}
