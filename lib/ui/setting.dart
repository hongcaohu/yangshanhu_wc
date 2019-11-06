import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:yangshanhu_wc/components/settingItem.dart';
import 'package:yangshanhu_wc/model/ParamModel.dart';
import 'package:yangshanhu_wc/model/param.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() {
    return _SettingState();
  }
}

class _SettingState extends State<Setting> {
  String name = '';
  int askInterval = 0;
  int smileNum = 0;
  int normalNum = 0;
  int sadNum = 0;

  String kengweiUsbValue;
  String pingjiaUsbValue;

  List<DropdownMenuItem> kengweiItemList = new List();
  List<DropdownMenuItem> pingjiaItemList = new List();

  @override
  void initState() {
    super.initState();
    name = SpUtil.getString('name') ?? '';
    askInterval = SpUtil.getInt('askInterval') ?? 0;
    smileNum = SpUtil.getInt("smileNum") ?? 0;
    normalNum = SpUtil.getInt("normalNum") ?? 0;
    sadNum = SpUtil.getInt("sadNum") ?? 0;
    print(SpUtil.getKeys());

    kengweiUsbValue = SpUtil.getString("kengweiUsbValue");
    pingjiaUsbValue = SpUtil.getString("pingjiaItemList");

    initItemList();
  }

  initItemList() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (devices != null && devices.length > 0) {
      List<DropdownMenuItem> _kengweiItemList = new List();
      List<DropdownMenuItem> _pingjiaItemList = new List();
      devices.forEach((d) {
        if (!d.productName.toLowerCase().contains('mouse')) {
          _kengweiItemList.add(DropdownMenuItem(
            child: Text("${d.vid}-${d.pid} ${d.productName}"),
            value: '${d.vid}-${d.pid}',
          ));
          _pingjiaItemList.add(DropdownMenuItem(
            child: Text("${d.vid}-${d.pid} ${d.productName}"),
            value: '${d.vid}-${d.pid}',
          ));
        }
      });
      setState(() {
        kengweiItemList = _kengweiItemList;
        pingjiaItemList = _pingjiaItemList;
      });
    }
  }

  _onChangeName(value) {
    this.name = value;
  }

  _onChangeAskInterval(value) {
    this.askInterval = int.parse(value);
  }

  _onChangeSmileNum(value) {
    this.smileNum = int.parse(value);
  }

  _onChangeNormalNum(value) {
    this.normalNum = int.parse(value);
  }

  _onChangeSadNum(value) {
    this.sadNum = int.parse(value);
  }

  saveSetting(BuildContext context) {
    SpUtil.putString('name', name);
    SpUtil.putInt('askInterval', askInterval);
    SpUtil.putInt('smileNum', smileNum);
    SpUtil.putInt('normalNum', normalNum);
    SpUtil.putInt('sadNum', sadNum);
    SpUtil.putString('kengweiUsbValue', kengweiUsbValue);
    SpUtil.putString('pingjiaUsbValue', pingjiaUsbValue);

    Param _p = Param(
        name: name ?? "",
        askInterval: askInterval ?? 0,
        smileNum: smileNum ?? 0,
        normalNum: normalNum ?? 0,
        sadNum: sadNum ?? 0);

    SpUtil.putObject("param", _p);
    //更新状态数据
    ParamModel model = ParamModel().of(context);
    model.changeParam(_p);

    //保存成功
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("提示信息"),
            content: Text("保存成功！"),
            actions: <Widget>[
              FlatButton(
                child: Text("确定"),
                onPressed: () {
                  print("before");
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  print("after");
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("设置"), actions: <Widget>[
        FlatButton(
          child: Text(
            "保存",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          onPressed: () => saveSetting(context),
        )
      ]),
      body: SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: <Widget>[
                SettingItem(
                  label: '名称',
                  //labelText: '请输入名称',
                  inputText: '$name',
                  onChange: _onChangeName,
                ),
                SettingItem(
                  label: '询问周期(秒)',
                  //labelText: '请输入询问周期',
                  keyType: TextInputType.number,
                  inputText: '$askInterval',
                  onChange: _onChangeAskInterval,
                ),
                SettingItem(
                  label: '满意',
                  //labelText: '请输入满意人数',
                  keyType: TextInputType.number,
                  inputText: '$smileNum',
                  onChange: _onChangeSmileNum,
                ),
                SettingItem(
                  label: '一般',
                  //labelText: '请输入一般人数',
                  keyType: TextInputType.number,
                  inputText: '$normalNum',
                  onChange: _onChangeNormalNum,
                ),
                SettingItem(
                  label: '不满意',
                  //labelText: '请输入不满意人数',
                  keyType: TextInputType.number,
                  inputText: '$sadNum',
                  onChange: _onChangeSadNum,
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 30),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Text(
                          "坑位端口",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: DropdownButton(
                          hint: Text('下拉选择一个USB端口'),
                          value: kengweiUsbValue,
                          items: kengweiItemList,
                          onChanged: (v) {
                            setState(() {
                              kengweiUsbValue = v;
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 30),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Text(
                          "评价端口",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: DropdownButton(
                          hint: Text('下拉选择一个USB端口'),
                          value: pingjiaUsbValue,
                          items: pingjiaItemList,
                          onChanged: (v) {
                            setState(() {
                              pingjiaUsbValue = v;
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )),
      ),
      resizeToAvoidBottomPadding: false,
    );
  }
}
