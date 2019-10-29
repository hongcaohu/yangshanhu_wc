import 'package:dio/dio.dart';

class DioUtils {

  String logUrl = "http://106.14.170.234:8081/uploadLogs";
  Dio dio = new Dio();

  void post(String body) async {
    await dio.post(logUrl, data: {"content": body});
  }
}