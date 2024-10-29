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

  Future<dynamic> chartScan(token, double per) async {
    try {
      final scanClause = "( {33489} ( latest close > latest open and latest sma( latest close , 15 ) > 3 days ago sma( 3 days ago close , 15 ) * 1.001 and latest sma( latest close , 30 ) > 3 days ago sma( 3 days ago close , 30 ) * 1.001 and latest sma( latest close , 150 ) > 3 days ago sma( 3 days ago close , 150 ) * 1.001 and latest sma( latest close , 15 ) > latest sma( latest close , 30 ) and latest sma( latest close , 30 ) > latest sma( latest close , 150 ) and latest close > latest sma( latest close , 15 ) and latest low < latest sma( latest close , 15 ) * $per ) )";
      final formData = FormData.fromMap({'scan_clause': scanClause});
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
          // 'raw/chartdisplay.php?v=o&t=d&E=1&E2=1&h=1&l=0&vg=1&y=1&s=0&w=0&c1=RSI%7E&c2=14%7E&c3=BB%7Esupertrend%7E&c4=20%2C2%7E7%2C3%7E&a1=1&a1t=c&a1v=SMA&a1l=44&a2=1&a2t=c&a2v=SMA&a2l=50&a3l=15&a4l=20&a5l=28&ti=91&d=d&width=1127&is_premium=false&user_id=0',
          'raw/chartdisplay.php?v=o&t=d&E=1&E2=1&h=1&l=0&vg=1&y=1&s=0&w=0&c1=RSI%7E&c2=14%7E&a1=1&a1t=c&a1v=SMA&a1l=150&a2=1&a2t=c&a2v=SMA&a2l=15&a3l=150&a4l=20&a5=1&a5t=c&a5v=SMA&a5l=30&ti=121&d=d&A=SBIN&width=1127&is_premium=false&user_id=0',
          queryParameters: {"A": stock});
    } on DioException catch (e) {
      return e.response;
    }
  }
}
