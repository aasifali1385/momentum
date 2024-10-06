import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class ChartService {
  static final ChartService _instance = ChartService._internal();

  factory ChartService() => _instance;
  late Dio _dio;

  ChartService._internal() {
    _initDio();
  }

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://chartink.com/',
      ),
    );

    final cookieJar = CookieJar();
    _dio.interceptors.add(CookieManager(cookieJar));
  }

  Dio get dio => _dio;

  ////////////////////////////////////////////

  Future<dynamic> getToken() async {
    try {
      return await _dio.get('screener');
    } on DioException catch (e) {
      return e.response;
    }
  }

  Future<dynamic> chartScan(token) async {
    try {
      const scan44MA =
          "( {33489} ( latest sma( latest close , 44 ) > 5 days ago sma( 5 days ago close , 44 ) + ( 5 days ago sma( 5 days ago close , 44 ) * 0.005 ) and latest close > latest open and latest open < latest sma( latest close , 44 ) + ( latest sma( latest close , 44 ) * 0.02 ) ) ) ";

      final formData = FormData.fromMap({'scan_clause': scan44MA});
      final options = Options(headers: {'X-csrf-token': '$token'});

      return await _dio.post('screener/process',
          data: formData, options: options);
    } on DioException catch (e) {
      return e.response;
    }
  }

  Future<dynamic> getChart(String stock) async {
    try {
      return await _dio.get(
          'raw/chartdisplay.php?v=o&t=d&E=1&E2=1&h=1&l=0&vg=1&y=1&s=0&w=0&c1=RSI%7E&c2=14%7E&c3=BB%7Esupertrend%7E&c4=20%2C2%7E7%2C3%7E&a1=1&a1t=c&a1v=SMA&a1l=44&a2=1&a2t=c&a2v=SMA&a2l=50&a3l=15&a4l=20&a5l=28&ti=91&d=d&width=1127&is_premium=false&user_id=0',
          queryParameters: {"A": stock});
    } on DioException catch (e) {
      return e.response;
    }
  }
}
