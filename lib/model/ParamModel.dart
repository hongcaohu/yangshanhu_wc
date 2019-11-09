import 'package:flustars/flustars.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:yangshanhu_wc/model/param.dart';

class ParamModel extends Model {
  Param _param;

  int _smileNum;
  int _normalNum;
  int _sadNum;

  get param {
    if (_param == null) {
      return SpUtil.getObj("param", (v) => Param.fromJson(v), defValue: Param(name: "", askInterval: 0, smileNum: 0, normalNum: 0, sadNum: 0));
    }
    return _param;
  }

  get smileNum => _smileNum;
  get normalNum => _normalNum;
  get sadNum => _sadNum;

  void changeSmileNum(int smileNum) {
    _smileNum = smileNum;
    notifyListeners();
  }

  void changeNormalNum(int normalNum) {
    _normalNum = normalNum;
    notifyListeners();
  }

  void changeSadNum(int sadNum) {
    _sadNum = sadNum;
    notifyListeners();
  }

  void changeParam(Param param) {
    _param = param;
    notifyListeners();
  }

  ParamModel of(context) =>
      ScopedModel.of<ParamModel>(context, rebuildOnChange: true);
}
