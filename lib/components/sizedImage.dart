import 'package:flutter/material.dart';

class SizeImage extends StatelessWidget {
  SizeImage({Key key, this.width=15, this.height=30, this.url="assets/images/green.png"}) : super(key: key);

  final double width;
  final double height;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.asset(this.url,width: this.width,height: this.height,);
  }

  
}