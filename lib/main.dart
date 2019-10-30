import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crclib/crclib.dart';
import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info/package_info.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:yangshanhu_wc/utils/dioUtil.dart';

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

  String progress="";
  bool download = false;

  String green = "assets/images/green.png";
  String red = "assets/images/red.png";

  String green_r = "assets/images/green_r.png";
  String red_r = "assets/images/red_r.png";

  TimerUtil timer;
  String date = "";
  String time = "";

  DioUtils dioUtil = new DioUtils();

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

  List<UsbDevice> devices = [];
  List<UsbPort> usbPorts = List<UsbPort>();

  double WW = 960;
  double HH = 540;

  // 1-14 是女厕
  // 15-20 是男厕
  // 21-22 残疾人位
  @override
  void initState() {

    //_checkVersionInfo();
    //tt();
    
        dioUtil.post("页面初始化开始...");
        super.initState();
    
        //初始化今日访问人数
        todayFemale = SpUtil.getInt("todayFemale") ?? 0;
        todayMan = SpUtil.getInt("todayMan") ?? 0;
    
        smileNum = SpUtil.getInt("smileNum") ?? 0;
        normalNum = SpUtil.getInt("normalNum") ?? 0;
        sadNum = SpUtil.getInt("sadNum") ?? 0;
    
        //开始初始化定时器
        dioUtil.post("初始化【当前时间计时】定时器");
        timer = TimerUtil();
        timer.setInterval(1000);
        timer.setOnTimerTickCallback((i) {
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
        dioUtil.post("启动【当前时间计时】定时器");
        if (timer != null) {
          timer.startTimer();
        }
    
        UsbSerial.usbEventStream.listen((UsbEvent msg) async {
          if (msg.event == UsbEvent.ACTION_USB_ATTACHED) {
            //监测到usb 上线
            dioUtil.post("====== 有usb接入 >> ${json.encode(msg)}");
          }
          if (msg.event == UsbEvent.ACTION_USB_DETACHED) {
            //监测到usb 下线
            dioUtil.post("====== 有usb退出 >> ${json.encode(msg)}");
          }
          openUsbPorts();
        });
    
        openUsbPorts(); //获取usb设备
    
        //USB Serial Timer
        dioUtil.post("定时任务初始化【Usb Serial】");
        usbSerialTimer = TimerUtil();
        usbSerialTimer.setInterval(5000);
        usbSerialTimer.setOnTimerTickCallback((i) {
          this.fetchData();
        });
        dioUtil.post("定时任务启动【Usb Serial】");
        if (usbSerialTimer != null) {
          usbSerialTimer.startTimer();
        }
      }
    
      void openUsbPorts() async {
        dioUtil.post("正在获取USB设备...");
        this.usbPorts = List<UsbPort>(); //清零
    
        this.devices = await UsbSerial.listDevices();
        dioUtil.post(
            "获取到USB设备：个数 >> ${devices.length}, 详细 >> ${json.encode(devices)}");
        this.devices.forEach((d) async {
          dioUtil.post("遍历获取到的device, USB设备 >> ${json.encode(d)}");
          UsbPort _port = await d.create();
          bool openResult = await _port.open();
          if (!openResult) {
            dioUtil.post("Failed to open >> ${json.encode(d)}");
            return;
          }
          this.usbPorts.add(_port);
        });
      }
    
      void fetchData() async {
        dioUtil.post("fetchData.. device length: ${devices.length}");
        if (usbPorts.length == 0) {
          return;
        }
        UsbPort port = usbPorts[0];
        fetchData1(port);
    
        if (usbPorts.length >= 2) {
          UsbPort _port = usbPorts[1];
          fetchData2(_port);
        }
      }
    
      //请求坑位信息
      void fetchData1(UsbPort port) async {
        dioUtil.post("开始请求【坑位】信息...");
        await port.setDTR(true);
        await port.setRTS(true);
    
        port.setPortParameters(
            115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
    
        // print first result and close port.
        // 01 01 01 00 xx xx
        // 地址 功能码 数据长度 数据 CRC校验
        dioUtil.post("正在监听【坑位串口】传来的数据...");
        port.inputStream.listen((Uint8List event) {
          dioUtil.post("监听到【坑位串口】传来的数据, event >> $event");
          List<String> result = List<String>();
          event.toList().map((i) {
            result.add(i.toRadixString(16));
          });
          dioUtil.post("转为16进制为 >> $result");
          print(event);
          int useFlag = event[3];
          int address = event[0];
          setState(() {
            //女厕位
            if (address <= 14) {
              //女厕位
              if (useFlag == 0x01 && !this.bools[address - 1]) {
                this.femaleUsing = this.femaleUsing + 1;
                this.todayFemale += this.todayFemale;
                //保存今日女厕总人数
                SpUtil.putInt("todayFemale", todayFemale);
              } else if (useFlag != 0x01 && this.bools[address - 1]) {
                this.femaleUsing = this.femaleUsing - 1;
              }
            } else if (address <= 20) {
              //男厕位
              if (useFlag == 0x01 && !this.bools[address - 1]) {
                this.manUsing = this.manUsing + 1;
                this.todayMan += this.todayMan;
                //保存今日男厕总人数
                SpUtil.putInt("todayMan", todayMan);
              } else if (useFlag != 0x01 && this.bools[address - 1]) {
                this.manUsing = this.manUsing - 1;
              }
            } else if (address <= 22) {
              //残疾厕位
              if (useFlag == 0x01 && !this.bools[address - 1]) {
                this.canjiUsing = this.canjiUsing + 1;
              } else if (useFlag != 0x01 && this.bools[address - 1]) {
                this.canjiUsing = this.canjiUsing - 1;
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
    
        //请求每个坑位的使用情况
        dioUtil.post("准备向【坑位串口】发送请求...");
        for (var i = 1; i <= 22; i++) {
          Uint8List preData = Uint8List.fromList([i, 0x01, 0x00, 0x00, 0x00, 0x01]);
          //crc modbus 校验码
          int crcResultReverse =
              ParametricCrc(16, 0x8005, 0xffff, 0x0000).convert(preData);
          Uint16List crc = Uint16List.fromList([crcResultReverse]);
    
          ByteData crcData = crc.buffer.asByteData(0, 2);
          int crcFirst = crcData.getUint8(0);
          int crcLast = crcData.getUint8(1);
    
          //最终的请求串口实体
          Uint8List postData = Uint8List.fromList(
              [i, 0x01, 0x00, 0x00, 0x00, 0x01, crcLast, crcFirst]);
          dioUtil.post("发送数据pre >> " +
              [i, 0x01, 0x00, 0x00, 0x00, 0x01, crcLast, crcFirst].toString());
          dioUtil.post("发送数据post >> $postData");
          port.write(postData);
        }
    
        //温湿度区域
        port.write(
            Uint8List.fromList([0x28, 0x03, 0x00, 0x00, 0x00, 0x02, 0xC3, 0xF2]));
        port.write(
            Uint8List.fromList([0x29, 0x03, 0x00, 0x10, 0x00, 0x01, 0x83, 0xE7]));
        port.write(
            Uint8List.fromList([0x2A, 0x03, 0x00, 0x08, 0x00, 0x01, 0x03, 0xD3]));
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
        dioUtil.post("监听【评价串口】数据中...");
        port.inputStream.listen((Uint8List event) {
          dioUtil.post("监听到【评价】数据 >> $event");
          List<String> result = List<String>();
          event.toList().map((i) {
            result.add(i.toRadixString(16));
          });
          dioUtil.post("转为16进制为 >> $result");
    
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
        if (timer != null) {
          timer.cancel();
        }
        if (usbSerialTimer != null) {
          usbSerialTimer.cancel();
        }
      }
    
      double doTop(double _top, BuildContext context) {
        return (_top/HH) * MediaQuery.of(context).size.height;
      }
    
      double doLeft(double _left, BuildContext context) {
        return (_left/WW) * MediaQuery.of(context).size.width;
      }
    
      @override
      Widget build(BuildContext context) {
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
                number: todayFemale.toString(),
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
            child: Offstage(
              offstage: !download, 
              child: Text(progress)
              ),
            )
          ],
        ));
      }
    
      void tt() async{
        // String taskId = await FlutterDownloader.enqueue(
        // url: "http://106.14.170.234:8081/download?app=yangshanhuwc_v2.apk",//服务端提供apk文件下载路径
        // savedDir: (await getExternalStorageDirectory()).path.toString(),//本地存放路径
        // fileName: "yangshanhuwc_v2"+ ".apk",//存放文件名
        // showNotification: false,//是否显示在通知栏
        // openFileFromNotification: false,//是否在通知栏可以点击打开此文件
        // );

        // //taskId为任务id （与完成下载的文件成一一对应）open是执行打开 打开需要任务id 相信你已经找到方向了
        // FlutterDownloader.registerCallback((taskId, status, progress) {
        // if (status == DownloadTaskStatus.complete) {
        //   print("下载完成");
        // //下载完成
        // FlutterDownloader.open(taskId:taskId);
        // } else if (status == DownloadTaskStatus.failed) {
        // //下载出错
        // }
        // });
      }

      void _checkVersionInfo() async {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String appVersion = packageInfo.version;
        print("当前APP版本为-> 【$appVersion】");
        await _updateVersion(appVersion);
      }

    void _updateVersion(String appVersion) async{
      Response rsp = await dioUtil.reqUpgradeInfo();
      String data = rsp.data.toString();
      var dataJson = json.decode(data);
      print(dataJson);
      if(dataJson["version_code"]=="") {
        //当前版本号大
        return;
      }
      if (Platform.isAndroid){
        String url = dataJson["android_download_url"];
        print("url >> $url");
        try {
          OtaUpdate().execute(url).listen(
                (OtaEvent event) {
              print('status:${event.status},value:${event.value}');
              switch(event.status){
                case OtaStatus.DOWNLOADING: // 下载中
                  setState(() {
                    progress = '下载进度:${event.value}%';
                    download = true;
                  });
                  break;
                case OtaStatus.INSTALLING: //安装中
                  break;
                case OtaStatus.PERMISSION_NOT_GRANTED_ERROR: // 权限错误
                  print('更新失败，请稍后再试');
                  break;
                default: // 其他问题
                  break;
              }
            }, 
            onDone: (){
              setState(() {
                download = false;
              });
            }
          );
        } catch (e) {
          print('更新失败，请稍后再试');
        }
      }
    }
}
