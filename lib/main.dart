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

  List<bool> bools = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

  // bool f1 = false;
  // bool f2 = false;
  // bool f3 = false;
  // bool f4 = false;
  // bool f5 = false;
  // bool f6 = false;
  // bool f7 = false;
  // bool f8 = false;
  // bool f9 = false;
  // bool f10 = false;
  // bool f11 = false;
  // bool f12 = false;
  // bool f13 = false;
  // bool f14 = false;
  // bool f15 = false;
  // bool f16 = false;
  // bool f17 = false;
  // bool f18 = false;
  // bool f19 = false;
  // bool f20 = false;
  // bool f21 = false;
  // bool f22 = false;

  int femaleTotal = 14;
  int femaleUsing = 0;

  int manTotal = 6;
  int manUsing = 0;

  int canjiTotal = 2;
  int canjiUsing = 0;

  int todayFemale = 0;
  int todayMan = 0;

  int smileNum = 0;
  int normalNum = 0;
  int sadNum = 0;

  // 1-14 是女厕
  // 15-20 是男厕
  // 21-22 残疾人位
  @override
  void initState() {
    super.initState();

    //初始化今日访问人数
    todayFemale = SpUtil.getInt("todayFemale") ?? 0;
    todayMan = SpUtil.getInt("todayMan") ?? 0;

    smileNum = SpUtil.getInt("smileNum") ?? 0;
    normalNum = SpUtil.getInt("normalNum") ?? 0;
    sadNum = SpUtil.getInt("sadNum") ?? 0;

    timer = TimerUtil();
    timer.setInterval(1000);
    timer.setOnTimerTickCallback((i) {
      setState(() {
        this.date =
            DateUtil.formatDate(DateTime.now(), format: DataFormats.zh_y_mo_d);
        this.time =
            DateUtil.formatDate(DateTime.now(), format: DataFormats.h_m_s);
        //零点清空男女厕今日汇总数据
        if(this.time == "00:00:00") {
          this.todayFemale = 0;
          this.todayMan = 0;
          SpUtil.putInt("todayFemale", 0);
          SpUtil.putInt("todayMan", 0);
        }
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
  
  void fetchData() async {
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
    fetchData1(port);
  }

  //请求坑位信息
  void fetchData1(UsbPort port) async {
    await port.setDTR(true);
    await port.setRTS(true);

    port.setPortParameters(
        115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    // print first result and close port.
    // 01 01 01 00 xx xx
    // 地址 功能码 数据长度 数据 CRC校验
    port.inputStream.listen((Uint8List event) {
      print(event);
      int useFlag = event[3];
      int address = event[0];
      setState(() {
        //女厕位
        if (address <= 14) {  //女厕位
          if(useFlag==0x01 && !this.bools[address-1]) {
            this.femaleUsing = this.femaleUsing + 1;
            this.todayFemale += this.todayFemale;
            //保存今日女厕总人数
            SpUtil.putInt("todayFemale", todayFemale);
          }else if(useFlag!=0x01 && this.bools[address-1]) {
            this.femaleUsing = this.femaleUsing - 1;
          }
        }else if(address <= 20) { //男厕位
          if(useFlag==0x01 && !this.bools[address-1]) {
            this.manUsing = this.manUsing + 1;
            this.todayMan += this.todayMan; 
            //保存今日男厕总人数
            SpUtil.putInt("todayMan", todayMan);
          }else if(useFlag!=0x01 && this.bools[address-1]) {
            this.manUsing = this.manUsing - 1;
          }
        }else if(address <= 22) { //残疾厕位
          if(useFlag==0x01 && !this.bools[address-1]) {
            this.canjiUsing = this.canjiUsing + 1;
          }else if(useFlag!=0x01 && this.bools[address-1]) {
            this.canjiUsing = this.canjiUsing - 1;
          }
        }
        this.bools[address-1] = useFlag==0x01 ? true : false;
        this.bools = List.from(bools);
      });

      //switch (address) {
        // case 0x01: {
        //   setState(() {
        //     if(useFlag==0x01 && !this.f1) {
        //       this.femaleUsing = this.femaleUsing + 1;
        //     }else if(useFlag!=0x01 && this.f1) {
        //       this.femaleUsing = this.femaleUsing - 1;
        //     }
        //     this.f1 = useFlag==0x01 ? true : false;
        //   });
        // }
        // break;
      //}
      
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
  //5A A5 06 83 00 00 02 00 01 满意++
  //5A A5 06 83 00 00 02 00 02 一般++
  //5A A5 06 83 00 00 02 00 03 不满意++
  void fetchData2(UsbPort port) async {
    await port.setDTR(true);
    await port.setRTS(true);
    port.setPortParameters(
        115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    // print first result and close port.
    // 01 01 01 00 xx xx
    // 地址 功能码 数据长度 数据 CRC校验
    port.inputStream.listen((Uint8List event) {
      print(event);
      int satisfaction = event[8];
      if(satisfaction==0x01) {
        smileNum += smileNum;
        SpUtil.putInt("smileNum", smileNum);
      }else if(satisfaction==0x02) {
        normalNum += normalNum;
        SpUtil.putInt("normalNum", normalNum);
      }else if(satisfaction==0x03) {
        sadNum += sadNum;
        SpUtil.putInt("sadNum", sadNum);
      }
    });
  }

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
          child: Num(number: (femaleTotal - femaleUsing).toString()),
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
          child: Num(number: (manTotal - manUsing).toString()),
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
          child: Num(number: (canjiTotal - canjiUsing).toString()),
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
          child: bools[0]
              ? SizeImage(
                  url: red,
                )
              : SizeImage(),
        ),
        //f2
        Positioned(
          left: 375,
          top: 168,
          child: bools[1]
              ? SizeImage(
                  url: red,
                )
              : SizeImage(),
        ),
        //f3
        Positioned(
          left: 411,
          top: 168,
          child: bools[2]
              ? SizeImage(
                  url: red,
                )
              : SizeImage(),
        ),
        //f4
        Positioned(
          left: 450,
          top: 168,
          child: bools[3]
              ? SizeImage(
                  url: red,
                )
              : SizeImage(),
        ),
        //f5
        Positioned(
          left: 493,
          top: 168,
          child: bools[4]
              ? SizeImage(
                  url: red,
                )
              : SizeImage(),
        ),
        //f6
        Positioned(
          left: 529,
          top: 168,
          child: bools[5]
              ? SizeImage(
                  url: red,
                )
              : SizeImage(),
        ),

        Positioned(
          left: 570,
          top: 168,
          child: bools[14]
              ? SizeImage(
                  url: red,
                )
              : SizeImage(),
        ),
        Positioned(
          left: 606,
          top: 168,
          child: bools[15]
              ? SizeImage(
                  url: red,
                )
              : SizeImage(),
        ),
        Positioned(
          left: 641,
          top: 168,
          child: bools[16]
              ? SizeImage(
                  url: red,
                )
              : SizeImage(),
        ),

        ///////////// 第二排 /////////////
        Positioned(
          left: 388,
          top: 270,
          child: bools[6]
              ? SizeImage(
                  url: red_r,
                )
              : SizeImage(
                  url: green_r,
                ),
        ),
        Positioned(
          left: 424,
          top: 270,
          child: bools[7]
              ? SizeImage(
                  url: red_r,
                )
              : SizeImage(
                  url: green_r,
                ),
        ),
        Positioned(
          left: 459,
          top: 270,
          child: bools[8]
              ? SizeImage(
                  url: red_r,
                )
              : SizeImage(
                  url: green_r,
                ),
        ),
        Positioned(
          left: 493,
          top: 270,
          child: bools[9]
              ? SizeImage(
                  url: red_r,
                )
              : SizeImage(
                  url: green_r,
                ),
        ),
        Positioned(
          left: 528,
          top: 270,
          child: bools[10]
              ? SizeImage(
                  url: red_r,
                )
              : SizeImage(
                  url: green_r,
                ),
        ),

        Positioned(
          left: 570,
          top: 270,
          child: bools[17]
              ? SizeImage(
                  url: red_r,
                )
              : SizeImage(
                  url: green_r,
                ),
        ),
        Positioned(
          left: 605,
          top: 270,
          child: bools[18]
              ? SizeImage(
                  url: red_r,
                )
              : SizeImage(
                  url: green_r,
                ),
        ),
        Positioned(
          left: 641,
          top: 270,
          child: bools[19]
              ? SizeImage(
                  url: red_r,
                )
              : SizeImage(
                  url: green_r,
                ),
        ),

        /////////// 第三排 ///////////
        Positioned(
          left: 388,
          top: 328,
          child: bools[11]
              ? SizeImage(
                  url: red,
                )
              : SizeImage(
                  url: green,
                ),
        ),
        Positioned(
          left: 424,
          top: 328,
          child: bools[12]
              ? SizeImage(
                  url: red,
                )
              : SizeImage(
                  url: green,
                ),
        ),
        Positioned(
          left: 458,
          top: 328,
          child: bools[13]
              ? SizeImage(
                  url: red,
                )
              : SizeImage(
                  url: green,
                ),
        ),

        Positioned(
          left: 500,
          top: 298,
          child: SizeImage(
            url: bools[20] ? "assets/images/4_01.png" : "assets/images/3_01.png",
            width: 30,
            height: 68,
          ),
        ),
        Positioned(
          left: 528,
          top: 304,
          child: SizeImage(
            url: bools[21] ? "assets/images/4_02.png" : "assets/images/3_02.png",
            width: 30,
            height: 58,
          ),
        ),

        /////////////// 满意度评价区 /////////////
        Positioned(
          left: 788,
          top: 350,
          child: Num(
            number: (smileNum+normalNum+sadNum)==0 ? "0.0%" : (smileNum/(smileNum+normalNum+sadNum)).toStringAsFixed(1)+"%",
            size: 12,
          ),
        ),
        Positioned(
          left: 843,
          top: 350,
          child: Num(
            number: (smileNum+normalNum+sadNum)==0 ? "0.0%" : (normalNum/(smileNum+normalNum+sadNum)).toStringAsFixed(1)+"%",
            size: 12,
          ),
        ),
        Positioned(
          left: 898,
          top: 350,
          child: Num(
            number: (smileNum+normalNum+sadNum)==0 ? "0.0%" : (sadNum/(smileNum+normalNum+sadNum)).toStringAsFixed(1)+"%",
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
