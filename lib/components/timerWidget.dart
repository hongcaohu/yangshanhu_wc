import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  @override
  _TimerWidgetState createState() {
    return _TimerWidgetState();
  }
}

class _TimerWidgetState extends State<TimerWidget> {

  String date;
  String time;
  TimerUtil timer;

  @override
  void initState() {
    super.initState();
    //开始初始化定时器
    timer = createTimerUtil(1000, (i) {
      setState(() {
        this.date =
            DateUtil.formatDate(DateTime.now(), format: DataFormats.zh_y_mo_d);
        this.time =
            DateUtil.formatDate(DateTime.now(), format: DataFormats.h_m_s);
      });
    });
    //启动定时器
    if (timer != null) {
      timer.startTimer();
    }
  }

  TimerUtil createTimerUtil(int millisecond, OnTimerTickCallback callback) {
    timer = TimerUtil();
    timer.setInterval(millisecond);
    timer.setOnTimerTickCallback(callback);
    return timer;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            this.date,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          Text(
            this.time,
            style: TextStyle(
                color: Colors.white, fontSize: 35, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    //启动定时器
    if (timer != null) {
      timer.cancel();
    }
  }
}
