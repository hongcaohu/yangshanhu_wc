import 'dart:io';
import 'dart:typed_data';

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:yangshanhu_wc/model/ParamModel.dart';
import 'package:yangshanhu_wc/model/param.dart';
import 'package:yangshanhu_wc/ui/setting.dart';
import 'package:yangshanhu_wc/utils/logUtil.dart';

import 'components/num.dart';
import 'components/sizedImage.dart';

void main() async {
  await SpUtil.getInstance();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  ParamModel paramModel = ParamModel();

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ParamModel>(
      model: paramModel,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Flutter Demo Home Page'),
        routes: <String, WidgetBuilder>{
          '/setting': (BuildContext context) => new Setting()
        },
      ),
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
  String progress = "";
  bool download = false;

  String green = "assets/images/green.png";
  String red = "assets/images/red.png";

  String green_r = "assets/images/green_r.png";
  String red_r = "assets/images/red_r.png";

  TimerUtil timer;
  TimerUtil sendTimer;

  String date = "";
  String time = "";

  LogUtils logUtil = new LogUtils();

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

  double tempData = 0.0;
  double humData = 0.0;
  double nhData = 0.0;
  int pmData = 0;

  String customTitle;

  List<UsbDevice> devices = [];
  List<UsbPort> usbPorts = List<UsbPort>();
  List<UsbDevice> serialDevices = List<UsbDevice>();
  UsbPort sendPort;

  double WW = 960;
  double HH = 540;

  List<Uint8List> commands = [
    Uint8List.fromList([0x01, 0x01, 0x00, 0x00, 0x00, 0x01, 0xFD, 0xCA]),
    Uint8List.fromList([0x02, 0x01, 0x00, 0x00, 0x00, 0x01, 0xFD, 0xF9]),
    Uint8List.fromList([0x03, 0x01, 0x00, 0x00, 0x00, 0x01, 0xFC, 0x28]),
    Uint8List.fromList([0x04, 0x01, 0x00, 0x00, 0x00, 0x01, 0xFD, 0x9F]),
    Uint8List.fromList([0x05, 0x01, 0x00, 0x00, 0x00, 0x01, 0xFC, 0x4E]),
    Uint8List.fromList([0x06, 0x01, 0x00, 0x00, 0x00, 0x01, 0xFC, 0x7D]),
    Uint8List.fromList([0x07, 0x01, 0x00, 0x00, 0x00, 0x01, 0xFD, 0xAC]),
    Uint8List.fromList([0x08, 0x01, 0x00, 0x00, 0x00, 0x01, 0xFD, 0x53]),
    Uint8List.fromList([0x09, 0x01, 0x00, 0x00, 0x00, 0x01, 0xFC, 0x82]),
    Uint8List.fromList([0x0A, 0x01, 0x00, 0x00, 0x00, 0x01, 0xFC, 0xB1]),
    Uint8List.fromList([0x0B, 0x01, 0x00, 0x00, 0x00, 0x01, 0xFD, 0x60]),
    Uint8List.fromList([0x0C, 0x01, 0x00, 0x00, 0x00, 0x01, 0xFC, 0xD7]),
    Uint8List.fromList([0x0D, 0x01, 0x00, 0x00, 0x00, 0x01, 0xFD, 0x06]),
    Uint8List.fromList([0x0E, 0x01, 0x00, 0x00, 0x00, 0x01, 0xFD, 0x35]),
    Uint8List.fromList([0x0F, 0x01, 0x00, 0x00, 0x00, 0x01, 0xFC, 0xE4]),
    Uint8List.fromList([0x10, 0x01, 0x00, 0x00, 0x00, 0x01, 0xFE, 0x8B]),
    Uint8List.fromList([0x11, 0x01, 0x00, 0x00, 0x00, 0x01, 0xFF, 0x5A]),
    Uint8List.fromList([0x12, 0x01, 0x00, 0x00, 0x00, 0x01, 0xFF, 0x69]),
    Uint8List.fromList([0x13, 0x01, 0x00, 0x00, 0x00, 0x01, 0xFE, 0xB8]),
    Uint8List.fromList([0x14, 0x01, 0x00, 0x00, 0x00, 0x01, 0xFF, 0x0F]),
    Uint8List.fromList([0x15, 0x01, 0x00, 0x00, 0x00, 0x01, 0xFE, 0xDE]),
    Uint8List.fromList([0x16, 0x01, 0x00, 0x00, 0x00, 0x01, 0xFE, 0xED]),
    Uint8List.fromList([0x28, 0x03, 0x00, 0x00, 0x00, 0x02, 0xC3, 0xF2]),
    Uint8List.fromList([0x29, 0x03, 0x00, 0x10, 0x00, 0x01, 0x83, 0xE7]),
    Uint8List.fromList([0x2A, 0x03, 0x00, 0x08, 0x00, 0x01, 0x03, 0xD3])
  ];

  // 1-14 是女厕
  // 15-20 是男厕
  // 21-22 残疾人位
  @override
  void initState() {
    logUtil.log("页面初始化开始...");
    super.initState();

    //初始化今日访问人数
    todayFemale = SpUtil.getInt("todayFemale") ?? 0;
    todayMan = SpUtil.getInt("todayMan") ?? 0;

    smileNum = SpUtil.getInt("smileNum") ?? 0;
    normalNum = SpUtil.getInt("normalNum") ?? 0;
    sadNum = SpUtil.getInt("sadNum") ?? 0;

    // String name = SpUtil.getString("name");
    // customTitle = (name==""||name==null) ? "羊山湖智慧厕所" : name;

    //开始初始化定时器
    timer = createTimerUtil(1000, (i) {
      setState(() {
        this.date =
            DateUtil.formatDate(DateTime.now(), format: DataFormats.zh_y_mo_d);
        this.time =
            DateUtil.formatDate(DateTime.now(), format: DataFormats.h_m_s);
        //零点清空男女厕今日汇总数据
        if (this.time == "00:00:00") {
          this.todayFemale = 0;
          this.todayMan = 0;
          SpUtil.putInt("todayFemale", 0);
          SpUtil.putInt("todayMan", 0);
        }
      });
    });
    //启动定时器
    if (timer != null) {
      timer.startTimer();
    }

    sendTimer = createTimerUtil(5000, (i) {
      reqSerialData();
    });
    //启动定时器
    if (sendTimer != null) {
      sendTimer.startTimer();
    }
    logUtil.log("timer 和 sendTimer 启动完成");

    UsbSerial.usbEventStream.listen((UsbEvent msg) async {
      //非USB鼠标
      if (!msg.device.productName.contains('Mouse')) {
        print("Event: ${msg.event}, Msg: $msg");

        if (msg.event == UsbEvent.ACTION_USB_ATTACHED) {
          //监测到usb 上线
          logUtil.log("====== 有usb接入 >> $msg");
        }
        if (msg.event == UsbEvent.ACTION_USB_DETACHED) {
          //监测到usb 下线
          logUtil.log("====== 有usb退出 >> $msg");
        }
        openUsbPorts();
      }
    });
    openUsbPorts(); //获取usb设备
  }

  void openUsbPorts() async {
    this.usbPorts = List<UsbPort>(); //清零
    this.devices = await UsbSerial.listDevices();

    print("获取到devices个数: ${devices.length},  详细: $devices");
    logUtil.log("获取到devices个数: ${devices.length},  详细: $devices");
    this.devices.forEach((d) async {
      if (!d.productName.toLowerCase().contains('mouse')) {
        logUtil.log("遍历获取到的device: $d");
        this.serialDevices.add(d);

        UsbPort _port = await d.create();
        bool openResult = await _port.open();
        if (!openResult) {
          print("打开port 失败,设备：$d");
          logUtil.log("打开port 失败,设备: $d");
        } else {
          this.usbPorts.add(_port);
        }
      }
    });

    //3秒钟后启动处理程序
    Future.delayed(Duration(milliseconds: 3000), () {
      fetchData();
    });
  }

  void fetchData() {
    print("处理获取到成功打开的端口列表， Port长度: ${usbPorts.length}, 详细: $usbPorts");
    logUtil.log("处理获取到成功打开的端口列表， Port长度: ${usbPorts.length}, 详细: $usbPorts");
    if (this.serialDevices.length == 0) {
      return;
    }
    UsbDevice device;
    String dKey;
    logUtil.log(
        "kengweiUsbValue: ${SpUtil.getString("kengweiUsbValue")}, pingjiaUsbValue: ${SpUtil.getString("pingjiaUsbValue")}");
    for (int i = 0; i < serialDevices.length; i++) {
      device = serialDevices[0];
      dKey = "${device.vid}-${device.pid}";
      if (dKey == SpUtil.getString("kengweiUsbValue")) {
        //坑位usb
        logUtil.log("获取坑位USB, device: $device");
        fetchData1(device);
      } else if (dKey == SpUtil.getString("pingjiaUsbValue")) {
        //评价usb
        logUtil.log("获取评价USB, device: $device");
        fetchData2(device);
      }
    }

    // if (this.serialDevices.length >= 2) {
    //   UsbDevice device = serialDevices[1];
    //   fetchData2(device);
    // }
  }

  //请求坑位信息
  fetchData1(UsbDevice d) async {
    UsbPort port = await d.create();
    bool openResult = await port.open();
    if (!openResult) {
      print("打开port 失败,设备：$d");
      logUtil.log("打开port 失败,设备: $d");
      return;
    }
    await port.setDTR(true);
    await port.setRTS(true);
    port.setPortParameters(
        9600, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
    //port.sendReq();

    // print first result and close port.
    // 01 01 01 00 xx xx
    // 地址 功能码 数据长度 数据 CRC校验
    port.inputStream.listen((event) {
      print("监听到【坑位串口】传来的数据, event >> $event");
      logUtil.log("监听到【坑位串口】传来的数据: " + event.toString());
      if (event.length != 6) {
        return;
      }
      int useFlag = event[3];
      int address = event[0];
      setState(() {
        //女厕位
        if (address <= 14) {
          //女厕位
          if (useFlag == 0x01 && !this.bools[address - 1]) {
            this.femaleUsing++;
            this.todayFemale++;
            //保存今日女厕总人数
            SpUtil.putInt("todayFemale", todayFemale);
          } else if (useFlag != 0x01 && this.bools[address - 1]) {
            this.femaleUsing--;
          }
        } else if (address <= 20) {
          //男厕位
          if (useFlag == 0x01 && !this.bools[address - 1]) {
            this.manUsing++;
            this.todayMan++;
            //保存今日男厕总人数
            SpUtil.putInt("todayMan", todayMan);
          } else if (useFlag != 0x01 && this.bools[address - 1]) {
            this.manUsing--;
          }
        } else if (address <= 22) {
          //残疾厕位
          if (useFlag == 0x01 && !this.bools[address - 1]) {
            this.canjiUsing = this.canjiUsing + 1;
          } else if (useFlag != 0x01 && this.bools[address - 1]) {
            this.canjiUsing--;
          }
        }
        this.bools[address - 1] = useFlag == 0x01 ? true : false;
        this.bools = List.from(bools);

        // 01 01 01 00 xx xx
        // 地址 功能码 数据长度 数据 CRC校验
        //温湿度
        ByteData dataBuffer = event.buffer.asByteData(0, event.length);
        if (address == 0x28) {
          this.tempData = dataBuffer.getUint16(3) / 10;
          this.humData = dataBuffer.getUint16(5) / 10;
        } else if (address == 0x29) {
          //氨气
          this.nhData = dataBuffer.getUint16(3) / 10;
        } else if (address == 0x2A) {
          //空气质量
          this.pmData = dataBuffer.getUint16(3);
        }
      });
    });
    //发送串口请求
    //port.sendReq();
    // for (int i = 0; i < commands.length; i++) {
    //   print("请求数据: ${commands[i]}");
    //   await port.write(commands[i]);
    //   sleep(Duration(milliseconds: 30));
    // }
  }

  reqSerialData() {
    //发送串口请求
    //port.sendReq();
    if (sendPort != null) {
      for (int i = 0; i < commands.length; i++) {
        print("请求串口数据: ${commands[i]}");
        sendPort.write(commands[i]);
        sleep(Duration(milliseconds: 30));
      }
    }
  }

  //请求评价信息
  //5A A5 06 83 00 00 02 00 01 满意++
  //5A A5 06 83 00 00 02 00 02 一般++
  //5A A5 06 83 00 00 02 00 03 不满意++
  fetchData2(UsbDevice d) async {
    UsbPort port = await d.create();
    bool openResult = await port.open();
    if (!openResult) {
      print("打开port 失败,设备：$d");
      logUtil.log("打开port 失败,设备: $d");
      return;
    }
    await port.setDTR(true);
    await port.setRTS(true);
    port.setPortParameters(
        9600, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    // print first result and close port.
    // 01 01 01 00 xx xx
    // 地址 功能码 数据长度 数据 CRC校验
    port.inputStream.listen((Uint8List event) {
      logUtil.log("监听到【评价】数据 >> $event");
      int satisfaction = event[8];
      if (satisfaction == 0x01) {
        smileNum += smileNum;
        SpUtil.putInt("smileNum", smileNum);
      } else if (satisfaction == 0x02) {
        normalNum += normalNum;
        SpUtil.putInt("normalNum", normalNum);
      } else if (satisfaction == 0x03) {
        sadNum += sadNum;
        SpUtil.putInt("sadNum", sadNum);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    sendTimer?.cancel();
  }

  double doTop(double _top, BuildContext context) {
    return (_top / HH) * MediaQuery.of(context).size.height;
  }

  double doLeft(double _left, BuildContext context) {
    return (_left / WW) * MediaQuery.of(context).size.width;
  }

  TimerUtil createTimerUtil(int millisecond, OnTimerTickCallback callback) {
    timer = TimerUtil();
    timer.setInterval(millisecond);
    timer.setOnTimerTickCallback(callback);
    return timer;
  }

  getParamModel(BuildContext context) {
    ParamModel model = ParamModel().of(context);
    Param _param = model.param;
    setState(() {
      this.customTitle = _param.name;
      this.smileNum = _param.smileNum;
      this.normalNum = _param.normalNum;
      this.sadNum = _param.sadNum;
    });
  }

  @override
  Widget build(BuildContext context) {
    getParamModel(context);
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Image.asset(
            "assets/images/background.jpg",
            fit: BoxFit.fill,
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          child: Container(
            height: 70,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text(
                customTitle == null || customTitle == ""
                    ? "羊山湖智慧公厕"
                    : customTitle,
                style: TextStyle(
                    fontSize: 30, color: Color.fromRGBO(255, 242, 101, 1)),
              ),
            ),
          ),
        ),
        /////////////女厕总侧位////////////
        Positioned(
          top: doTop(94, context),
          left: doLeft(148, context),
          child: Num(number: femaleTotal.toString()),
        ),
        //当前使用
        Positioned(
          top: doTop(127, context),
          left: doLeft(130, context),
          child: Num(number: femaleUsing.toString()),
        ),
        //剩余位
        Positioned(
          top: doTop(127, context),
          left: doLeft(225, context),
          child: Num(number: (femaleTotal - femaleUsing).toString()),
        ),

        /////////////男厕总侧位/////////////
        Positioned(
          top: doTop(172, context),
          left: doLeft(148, context),
          child: Num(number: manTotal.toString()),
        ),
        //当前使用
        Positioned(
          top: doTop(206, context),
          left: doLeft(130, context),
          child: Num(number: manUsing.toString()),
        ),
        //剩余位
        Positioned(
          top: doTop(206, context),
          left: doLeft(225, context),
          child: Num(number: (manTotal - manUsing).toString()),
        ),

        /////////////残疾人总侧位/////////////
        Positioned(
          top: doTop(245, context),
          left: doLeft(165, context),
          child: Num(number: canjiTotal.toString()),
        ),
        //当前使用
        Positioned(
          top: doTop(279, context),
          left: doLeft(130, context),
          child: Num(number: canjiUsing.toString()),
        ),
        //剩余位
        Positioned(
          top: doTop(279, context),
          left: doLeft(225, context),
          child: Num(number: (canjiTotal - canjiUsing).toString()),
        ),

        /////////////左下角///////////////////
        //温度
        Positioned(
          top: doTop(354, context),
          left: doLeft(180, context),
          child: Num(
            number: this.tempData.toString() + " ℃",
          ),
        ),
        //湿度
        Positioned(
          top: doTop(392, context),
          left: doLeft(190, context),
          child: Num(
            number: this.humData.toString() + " %",
          ),
        ),
        //氨气
        Positioned(
          top: doTop(432, context),
          left: doLeft(180, context),
          child: Num(
            number: this.nhData.toString() + " ppm",
          ),
        ),
        //空气质量
        Positioned(
          top: doTop(472, context),
          left: doLeft(180, context),
          child: Num(
            number: "PM2.5: " + this.pmData.toString(),
          ),
        ),

        //////////// 中间的侧位 ///////////
        Positioned(
          left: doLeft(339, context),
          top: doTop(168, context),
          child: bools[0]
              ? SizeImage(
                  url: red,
                )
              : SizeImage(),
        ),
        //f2
        Positioned(
          left: doLeft(375, context),
          top: doTop(168, context),
          child: bools[1]
              ? SizeImage(
                  url: red,
                )
              : SizeImage(),
        ),
        //f3
        Positioned(
          left: doLeft(411, context),
          top: doTop(168, context),
          child: bools[2]
              ? SizeImage(
                  url: red,
                )
              : SizeImage(),
        ),
        //f4
        Positioned(
          left: doLeft(450, context),
          top: doTop(168, context),
          child: bools[3]
              ? SizeImage(
                  url: red,
                )
              : SizeImage(),
        ),
        //f5
        Positioned(
          left: doLeft(493, context),
          top: doTop(168, context),
          child: bools[4]
              ? SizeImage(
                  url: red,
                )
              : SizeImage(),
        ),
        //f6
        Positioned(
          left: doLeft(529, context),
          top: doTop(168, context),
          child: bools[5]
              ? SizeImage(
                  url: red,
                )
              : SizeImage(),
        ),

        Positioned(
          left: doLeft(570, context),
          top: doTop(168, context),
          child: bools[14]
              ? SizeImage(
                  url: red,
                )
              : SizeImage(),
        ),
        Positioned(
          left: doLeft(606, context),
          top: doTop(168, context),
          child: bools[15]
              ? SizeImage(
                  url: red,
                )
              : SizeImage(),
        ),
        Positioned(
          left: doLeft(641, context),
          top: doTop(168, context),
          child: bools[16]
              ? SizeImage(
                  url: red,
                )
              : SizeImage(),
        ),

        ///////////// 第二排 /////////////
        Positioned(
          left: doLeft(388, context),
          top: doTop(270, context),
          child: bools[6]
              ? SizeImage(
                  url: red_r,
                )
              : SizeImage(
                  url: green_r,
                ),
        ),
        Positioned(
          left: doLeft(424, context),
          top: doTop(270, context),
          child: bools[7]
              ? SizeImage(
                  url: red_r,
                )
              : SizeImage(
                  url: green_r,
                ),
        ),
        Positioned(
          left: doLeft(459, context),
          top: doTop(270, context),
          child: bools[8]
              ? SizeImage(
                  url: red_r,
                )
              : SizeImage(
                  url: green_r,
                ),
        ),
        Positioned(
          left: doLeft(493, context),
          top: doTop(270, context),
          child: bools[9]
              ? SizeImage(
                  url: red_r,
                )
              : SizeImage(
                  url: green_r,
                ),
        ),
        Positioned(
          left: doLeft(528, context),
          top: doTop(270, context),
          child: bools[10]
              ? SizeImage(
                  url: red_r,
                )
              : SizeImage(
                  url: green_r,
                ),
        ),

        Positioned(
          left: doLeft(570, context),
          top: doTop(270, context),
          child: bools[17]
              ? SizeImage(
                  url: red_r,
                )
              : SizeImage(
                  url: green_r,
                ),
        ),
        Positioned(
          left: doLeft(605, context),
          top: doTop(270, context),
          child: bools[18]
              ? SizeImage(
                  url: red_r,
                )
              : SizeImage(
                  url: green_r,
                ),
        ),
        Positioned(
          left: doLeft(641, context),
          top: doTop(270, context),
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
          left: doLeft(388, context),
          top: doTop(328, context),
          child: bools[11]
              ? SizeImage(
                  url: red,
                )
              : SizeImage(
                  url: green,
                ),
        ),
        Positioned(
          left: doLeft(424, context),
          top: doTop(328, context),
          child: bools[12]
              ? SizeImage(
                  url: red,
                )
              : SizeImage(
                  url: green,
                ),
        ),
        Positioned(
          left: doLeft(458, context),
          top: doTop(328, context),
          child: bools[13]
              ? SizeImage(
                  url: red,
                )
              : SizeImage(
                  url: green,
                ),
        ),

        Positioned(
          left: doLeft(500, context),
          top: doTop(298, context),
          child: SizeImage(
            url:
                bools[20] ? "assets/images/4_01.png" : "assets/images/3_01.png",
            width: 30,
            height: 68,
          ),
        ),
        Positioned(
          left: doLeft(528, context),
          top: doTop(304, context),
          child: SizeImage(
            url:
                bools[21] ? "assets/images/4_02.png" : "assets/images/3_02.png",
            width: 30,
            height: 58,
          ),
        ),

        /////////////// 满意度评价区 /////////////
        Positioned(
          left: doLeft(788, context),
          top: doTop(350, context),
          child: Num(
            number: (smileNum + normalNum + sadNum) == 0
                ? "0.0%"
                : (smileNum / (smileNum + normalNum + sadNum))
                        .toStringAsFixed(1) +
                    "%",
            size: 12,
          ),
        ),
        Positioned(
          left: doLeft(843, context),
          top: doTop(350, context),
          child: Num(
            number: (smileNum + normalNum + sadNum) == 0
                ? "0.0%"
                : (normalNum / (smileNum + normalNum + sadNum))
                        .toStringAsFixed(1) +
                    "%",
            size: 12,
          ),
        ),
        Positioned(
          left: doLeft(898, context),
          top: doTop(350, context),
          child: Num(
            number: (smileNum + normalNum + sadNum) == 0
                ? "0.0%"
                : (sadNum / (smileNum + normalNum + sadNum))
                        .toStringAsFixed(1) +
                    "%",
            size: 12,
          ),
        ),
        /////////////// 今日客流 /////////////
        Positioned(
          left: doLeft(795, context),
          top: doTop(476, context),
          child: Num(
            number: todayFemale.toString(),
          ),
        ),
        Positioned(
          left: doLeft(900, context),
          top: doTop(476, context),
          child: Num(
            number: todayMan.toString(),
          ),
        ),
        /////////////////// 当前时间 ////////////////
        Positioned(
            left: doLeft(790, context),
            top: doTop(110, context),
            child: Text(
              this.date,
              style: TextStyle(color: Colors.white, fontSize: 18),
            )),
        Positioned(
            left: doLeft(788, context),
            top: doTop(150, context),
            child: Text(
              this.time,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                  fontWeight: FontWeight.w500),
            )),
        Positioned(
          left: 1,
          top: 1,
          child: Offstage(offstage: !download, child: Text(progress)),
        ),
        Positioned(
            left: 0,
            top: 0,
            child: FlatButton(
              onPressed: openUsbPorts,
              child: Text(""),
            )),
        Positioned(
            left: MediaQuery.of(context).size.width - 50,
            top: 15,
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, "/setting"),
              child: Icon(
                Icons.settings,
                color: Colors.white70,
              ),
            )),
      ],
    ));
  }
}
