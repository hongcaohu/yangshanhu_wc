import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:yangshanhu_wc/utils/logUtil.dart';

class Cewei extends StatefulWidget {
  Cewei(
      {Key key,
      this.index = 99,
      this.width = 15,
      this.height = 30,
      this.inputStream,
      this.greenUrl = "assets/images/green.png",
      this.redUrl = "assets/images/red.png"})
      : super(key: key);

  final double width;
  final double height;
  final index;
  final String greenUrl;
  final String redUrl;
  final Stream<Uint8List> inputStream;

  @override
  _CeweiState createState() {
    return _CeweiState();
  }
}

class _CeweiState extends State<Cewei> {
  LogUtils logUtil = new LogUtils();
  String currentUrl;

  @override
  void initState() {
    super.initState();
    currentUrl = widget.greenUrl;
    subscribeInputStream(widget.inputStream);
  }

  @override
  void didUpdateWidget(Cewei oldWidget) {
    super.didUpdateWidget(oldWidget);
    subscribeInputStream(widget.inputStream);
  }

  subscribeInputStream(Stream<Uint8List> inputStream) {
    if (inputStream != null) {
      inputStream.listen((event) {
        logUtil.log("监听到【串口】传来的数据: index: ${widget.index} " + event.toString());
        int address = event[0];
        if (event.length == 6 && address == widget.index) {
          int useFlag = event[3];
          if (useFlag == 1) {
            setState(() {
              currentUrl = widget.redUrl;
            });
          } else if (useFlag == 0) {
            setState(() {
              currentUrl = widget.greenUrl;
            });
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('SizeImage Widget build: index - ${widget.index}');
    return Image.asset(
      this.currentUrl,
      width: widget.width,
      height: widget.height,
    );
  }
}
