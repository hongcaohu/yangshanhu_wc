import 'package:yangshanhu_wc/utils/dioUtil.dart';

class LogUtils {
  
  final debug = true;

  DioUtils dioUtil = DioUtils();

  void log(String msg) {
    if(debug) {
      dioUtil.post(msg);
    }
  }
}