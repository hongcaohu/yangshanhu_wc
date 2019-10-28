import 'dart:convert';
import 'dart:typed_data';

import 'package:crclib/crclib.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';

import 'components/num.dart';
import 'components/sizedImage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String green = "assets/images/green.png";
  String red = "assets/images/red.png";

  String green_r = "assets/images/green_r.png";
  String red_r = "assets/images/red_r.png";

  TimerUtil timer;
  String date = "";
  String time = "";

  TimerUtil usbSerialTimer;

  bool f1 = false;
  bool f2 = false;
  bool f3 = false;
  bool f4 = false;
  bool f5 = false;
  bool f6 = false;
  bool f7 = false;
  bool f8 = false;
  bool f9 = false;
  bool f10 = false;
  bool f11 = false;
  bool f12 = false;
  bool f13 = false;
  bool f14 = false;
  bool f15 = false;
  bool f16 = false;
  bool f17 = false;
  bool f18 = false;
  bool f19 = false;
  bool f20 = false;
  bool f21 = false;
  bool f22 = false;

  int femaleTotal = 14;
  int femaleUsing = 0;

  int manTotal = 6;
  int manUsing = 0;

  int canjiTotal = 2;
  int canjiUsing = 0;

  int todayFemale = 0;
  int todayMan = 0;

  // 1-14 是女厕
  // 15-20 是男厕
  // 21-22 残疾人位
  @override
  void initState() {
    super.initState();
    timer = TimerUtil();
    timer.setInterval(1000);
    timer.setOnTimerTickCallback((i) {
      setState(() {
        this.date =
            DateUtil.formatDate(DateTime.now(), format: DataFormats.zh_y_mo_d);
        this.time =
            DateUtil.formatDate(DateTime.now(), format: DataFormats.h_m_s);
      });
    });
    if (timer != null) {
      timer.startTimer();
    }

    //USB Serial Timer
    usbSerialTimer = TimerUtil();
    usbSerialTimer.setInterval(5000);
    usbSerialTimer.setOnTimerTickCallback((i) {});
    if (usbSerialTimer != null) {}
  }

  //请求坑位信息
  void fetchData1() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    print(devices);

    UsbPort port;
    if (devices.length == 0) {
      return;
    }
    port = await devices[0].create();

    bool openResult = await port.open();
    if (!openResult) {
      print("Failed to open");
      return;
    }

    await port.setDTR(true);
    await port.setRTS(true);

    port.setPortParameters(115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    // print first result and close port.
    // 01 01 01 00 xx xx
    // 地址 功能码 数据长度 数据 CRC校验
    port.inputStream.listen((Uint8List event) {
      print(event);
      int useFlag = event[3];
      if (useFlag == 0x00) {
        //没有人

      } else if (useFlag == 0x01) {
        //有人

      }
      port.close();
    });

    //请求每个坑位的使用情况
    for (var i = 1; i <= 22; i++) {
      String idex = "";
      if (i < 10) {
        idex = "0${i}";
      } else {
        idex = "${i}";
      }
      int deviceId = int.parse(idex, radix: 16);
      Uint8List preData =
          Uint8List.fromList([deviceId, 0x01, 0x00, 0x00, 0x00, 0x01]);
      int crcResultReverse =
          ParametricCrc(16, 0x8005, 0xffff, 0x0000).convert(preData);

      //调整CRC Modbus 顺序
      String crcResultReverseStr = crcResultReverse.toRadixString(16);
      String crcResultLst2 = crcResultReverseStr.substring(2, 4);
      String crcResultStr = crcResultLst2 + crcResultReverseStr.substring(0, 2);
      int crcResult = int.parse(crcResultStr, radix: 16);

      //最终的请求串口实体
      Uint8List postData = Uint8List.fromList(
          [deviceId, 0x01, 0x00, 0x00, 0x00, 0x01, crcResult]);

      port.write(postData);
    }
  }

  //请求评价信息
  void fetchData2() {}

  @override
  void dispose() {
    super.dispose();
    if (timer != null) {
      timer.cancel();
    }
    if (usbSerialTimer != null) {
      usbSerialTimer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Image.asset("assets/images/background.jpg", fit: BoxFit.cover),
        ),
/////////////女厕总侧位////////////
        Positioned(
          top: 96,
          left: 148,
          child: Num(number: femaleTotal.toString()),
        ),
        //当前使用
        Positioned(
          top: 128,
          left: 130,
          child: Num(number: femaleUsing.toString()),
        ),
        //剩余位
        Positioned(
          top: 128,
          left: 225,
          child: Num(number: (femaleTotal-femaleUsing).toString()),
        ),

/////////////男厕总侧位/////////////
        Positioned(
          top: 173,
          left: 148,
          child: Num(number: manTotal.toString()),
        ),
        //当前使用
        Positioned(
          top: 207,
          left: 130,
          child: Num(number: manUsing.toString()),
        ),
        //剩余位
        Positioned(
          top: 207,
          left: 225,
          child: Num(number: (manTotal-manUsing).toString()),
        ),

/////////////残疾人总侧位/////////////
        Positioned(
          top: 247,
          left: 165,
          child: Num(number: canjiTotal.toString()),
        ),
        //当前使用
        Positioned(
          top: 280,
          left: 130,
          child: Num(number: canjiUsing.toString()),
        ),
        //剩余位
        Positioned(
          top: 280,
          left: 225,
          child: Num(number: (canjiTotal-canjiUsing).toString()),
        ),

/////////////左下角///////////////////
        //温度
        Positioned(
          top: 357,
          left: 180,
          child: Num(
            number: "24.8 ℃",
          ),
        ),
        //湿度
        Positioned(
          top: 395,
          left: 190,
          child: Num(
            number: "33 %",
          ),
        ),
        //氨气
        Positioned(
          top: 435,
          left: 180,
          child: Num(
            number: "13ppm",
          ),
        ),
        //空气质量
        Positioned(
          top: 475,
          left: 180,
          child: Num(
            number: "PM2.5: 10",
          ),
        ),

//////////// 中间的侧位 ///////////
        ///       // f1
        Positioned(
          left: 339,
          top: 168,
          child: f1 ? SizeImage(url: red,) : SizeImage(),
        ),
        //f2
        Positioned(
          left: 375,
          top: 168,
          child: f2 ? SizeImage(url: red,) : SizeImage(),
        ),
        //f3
        Positioned(
          left: 411,
          top: 168,
          child: f3 ? SizeImage(url: red,) : SizeImage(),
        ),
        //f4
        Positioned(
          left: 450,
          top: 168,
          child: f4 ? SizeImage(url: red,) : SizeImage(),
        ),
        //f5
        Positioned(
          left: 493,
          top: 168,
          child: f5 ? SizeImage(url: red,) : SizeImage(),
        ),
        //f6
        Positioned(
          left: 529,
          top: 168,
          child: f6 ? SizeImage(url: red,) : SizeImage(),
        ),



        Positioned(
          left: 570,
          top: 168,
          child: f15 ? SizeImage(url: red,) : SizeImage(),
        ),
        Positioned(
          left: 606,
          top: 168,
          child: f16 ? SizeImage(url: red,) : SizeImage(),
        ),
        Positioned(
          left: 641,
          top: 168,
          child: f17 ? SizeImage(url: red,) : SizeImage(),
        ),

        ///////////// 第二排 /////////////
        Positioned(
          left: 388,
          top: 270,
          child: f7 ? SizeImage(url: red_r,) : SizeImage(url: green_r,),
        ),
        Positioned(
          left: 424,
          top: 270,
          child: f8 ? SizeImage(url: red_r,) : SizeImage(url: green_r,),
        ),
        Positioned(
          left: 459,
          top: 270,
          child: f9 ? SizeImage(url: red_r,) : SizeImage(url: green_r,),
        ),
        Positioned(
          left: 493,
          top: 270,
          child: f10 ? SizeImage(url: red_r,) : SizeImage(url: green_r,),
        ),
        Positioned(
          left: 528,
          top: 270,
          child: f11 ? SizeImage(url: red_r,) : SizeImage(url: green_r,),
        ),



        Positioned(
          left: 570,
          top: 270,
          child: f18 ? SizeImage(url: red_r,) : SizeImage(url: green_r,),
        ),
        Positioned(
          left: 605,
          top: 270,
          child: f19 ? SizeImage(url: red_r,) : SizeImage(url: green_r,),
        ),
        Positioned(
          left: 641,
          top: 270,
          child: f20 ? SizeImage(url: red_r,) : SizeImage(url: green_r,),
        ),

        /////////// 第三排 ///////////
        Positioned(
          left: 388,
          top: 328,
          child: f12 ? SizeImage(url: red,) : SizeImage(url: green,),
        ),
        Positioned(
          left: 424,
          top: 328,
          child: f13 ? SizeImage(url: red,) : SizeImage(url: green,),
        ),
        Positioned(
          left: 458,
          top: 328,
          child: f14 ? SizeImage(url: red,) : SizeImage(url: green,),
        ),



        Positioned(
          left: 500,
          top: 298,
          child: SizeImage(
            url: f21 ? "assets/images/4_01.png" : "assets/images/3_01.png",
            width: 30,
            height: 68,
          ),
        ),
        Positioned(
          left: 528,
          top: 304,
          child: SizeImage(
            url: f22 ? "assets/images/4_02.png" : "assets/images/3_02.png",
            width: 30,
            height: 58,
          ),
        ),

        /////////////// 满意度评价区 /////////////
        Positioned(
          left: 788,
          top: 350,
          child: Num(
            number: "45.1%",
            size: 12,
          ),
        ),
        Positioned(
          left: 843,
          top: 350,
          child: Num(
            number: "45.1%",
            size: 12,
          ),
        ),
        Positioned(
          left: 898,
          top: 350,
          child: Num(
            number: "45.1%",
            size: 12,
          ),
        ),
        /////////////// 今日客流 /////////////
        Positioned(
          left: 795,
          top: 476,
          child: Num(
            number: todayFemale.toString(),
          ),
        ),
        Positioned(
          left: 900,
          top: 476,
          child: Num(
            number: todayFemale.toString(),
          ),
        ),
        /////////////////// 当前时间 ////////////////
        Positioned(
            left: 790,
            top: 110,
            child: Text(
              this.date,
              style: TextStyle(color: Colors.white, fontSize: 18),
            )),
        Positioned(
            left: 788,
            top: 150,
            child: Text(
              this.time,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                  fontWeight: FontWeight.w500),
            ))
      ],
    ));
  }
}
