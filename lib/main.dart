import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

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
  String green_r = "assets/images/green_r.png";

  TimerUtil timer;
  String date = "";
  String time = "";

  @override
  void initState() {
    super.initState();
    timer = TimerUtil();
    timer.setInterval(1000);
    timer.setOnTimerTickCallback((i) {
      setState(() {
        this.date = DateUtil.formatDate(DateTime.now(), format: DataFormats.zh_y_mo_d);
        this.time = DateUtil.formatDate(DateTime.now(), format: DataFormats.h_m_s);
      });
    });
    if (timer != null) {
      timer.startTimer();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (timer != null) {
      timer.cancel();
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
            child: Image.asset("assets/images/background.jpg", fit:BoxFit.cover),
          ),
/////////////女厕总侧位////////////
          Positioned(
            top: 96,
            left: 148,
            child: Num(number:"15"),
          ),
          //当前使用
          Positioned(
            top: 128,
            left: 130,
            child: Num(number:"15"),
          ),
          //剩余位
          Positioned(
            top: 128,
            left: 225,
            child: Num(number:"15"),
          ),

/////////////男厕总侧位/////////////
          Positioned(
            top: 173,
            left: 148,
            child: Num(number:"15"),
          ),
          //当前使用
          Positioned(
            top: 207,
            left: 130,
            child: Num(number:"15"),
          ),
          //剩余位
          Positioned(
            top: 207,
            left: 225,
            child: Num(number:"15"),
          ),

/////////////残疾人总侧位/////////////
          Positioned(
            top: 247,
            left: 165,
            child: Num(number:"15"),
          ),
          //当前使用
          Positioned(
            top: 280,
            left: 130,
            child: Num(number:"15"),
          ),
          //剩余位
          Positioned(
            top: 280,
            left: 225,
            child: Num(number:"15"),
          ),

/////////////左下角///////////////////
          //温度
          Positioned(
            top: 357,
            left: 180,
            child: Num(number: "24.8 ℃",),
          ),
          //湿度
          Positioned(
            top: 395,
            left: 190,
            child: Num(number: "33 %",),
          ),
          //氨气
          Positioned(
            top: 435,
            left: 180,
            child: Num(number: "13ppm",),
          ),
          //空气质量
          Positioned(
            top: 475,
            left: 180,
            child: Num(number: "PM2.5: 10",),
          ),

//////////// 中间的侧位 ///////////   
          Positioned(
            left: 339,
            top: 168,
            child: SizeImage(),
          ),
          Positioned(
            left: 375,
            top: 168,
            child: SizeImage(),
          ),
          Positioned(
            left: 411,
            top: 168,
            child: SizeImage(),
          ),
          Positioned(
            left: 450,
            top: 168,
            child: SizeImage(),
          ),
          Positioned(
            left: 493,
            top: 168,
            child: SizeImage(),
          ),
          Positioned(
            left: 529,
            top: 168,
            child: SizeImage(),
          ),
          Positioned(
            left: 570,
            top: 168,
            child: SizeImage(),
          ),
          Positioned(
            left: 606,
            top: 168,
            child: SizeImage(),
          ),
          Positioned(
            left: 641,
            top: 168,
            child: SizeImage(),
          ),

          ///////////// 第二排 /////////////
          Positioned(
            left: 388,
            top: 270,
            child: SizeImage(url: green_r),
          ),
          Positioned(
            left: 424,
            top: 270,
            child: SizeImage(url: green_r),
          ),
          Positioned(
            left: 459,
            top: 270,
            child: SizeImage(url: green_r),
          ),
          Positioned(
            left: 493,
            top: 270,
            child: SizeImage(url: green_r),
          ),
          Positioned(
            left: 528,
            top: 270,
            child: SizeImage(url: green_r),
          ),
          Positioned(
            left: 570,
            top: 270,
            child: SizeImage(url: green_r),
          ),
          Positioned(
            left: 605,
            top: 270,
            child: SizeImage(url: green_r),
          ),
          Positioned(
            left: 641,
            top: 270,
            child: SizeImage(url: green_r),
          ),

          /////////// 第三排 ///////////
          Positioned(
            left: 388,
            top: 328,
            child: SizeImage(),
          ),
          Positioned(
            left: 424,
            top: 328,
            child: SizeImage(),
          ),
          Positioned(
            left: 458,
            top: 328,
            child: SizeImage(),
          ),

          Positioned(
            left: 500,
            top: 298,
            child: SizeImage(url: "assets/images/4_01.png", width: 30, height: 68,),
          ),
          Positioned(
            left: 528,
            top: 304,
            child: SizeImage(url: "assets/images/3_02.png", width: 30, height: 58,),
          ),

          /////////////// 满意度评价区 /////////////
          Positioned(
            left: 788,
            top: 350,
            child: Num(number: "45.1%",size: 12,),
          ),
          Positioned(
            left: 843,
            top: 350,
            child: Num(number: "45.1%",size: 12,),
          ),
          Positioned(
            left: 898,
            top: 350,
            child: Num(number: "45.1%",size: 12,),
          ),
          /////////////// 今日客流 /////////////
          Positioned(
            left: 795,
            top: 476,
            child: Num(number: "45",),
          ),
          Positioned(
            left: 900,
            top: 476,
            child: Num(number: "45",),
          ),
          /////////////////// 当前时间 ////////////////
          Positioned(
            left: 790,
            top: 110,
            child: Text(this.date, style: TextStyle(color: Colors.white, fontSize: 18),)
          ),
          Positioned(
            left: 788,
            top: 150,
            child: Text(this.time, style: TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.w500),)
          )
        ],
      )
    );
  }
}
