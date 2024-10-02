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
        baseUrl: 'https://chartink.com',
      ),
    );

    final cookieJar = CookieJar();
    _dio.interceptors.add(CookieManager(cookieJar));
  }

  Dio get dio => _dio;

  ////////////////////////////////////////////

  Future<dynamic> getToken() async {
    try {
      return await _dio.get('/screener');
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

      return await _dio.post('/screener/process',
          data: formData, options: options);
    } on DioException catch (e) {
      return e.response;
    }
  }
}
