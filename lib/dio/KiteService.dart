import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class KiteService {
  static final KiteService _instance = KiteService._internal();

  factory KiteService() => _instance;
  late Dio _dio;

  KiteService._internal() {
    _initDio();
  }

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://kite.zerodha.com/api/',
      ),
    );

    // final cookieJar = CookieJar();
    // _dio.interceptors.add(CookieManager(cookieJar));
  }

  Dio get dio => _dio;

  ////////////////////////////////////////////
  final options = Options(contentType: Headers.formUrlEncodedContentType);

  Future<dynamic> login() async {
    try {
      final data = {
        'user_id': 'UL0624',
        'password': 'Meraprizer@8899',
        'type': 'user_id'
      };

      return await _dio.post('login', data: data, options: options);
    } on DioException catch (e) {
      return e.response;
    }
  }

  Future<dynamic> twoFacAuth(rid, totp) async {
    try {
      final data = {
        'user_id': 'UL0624',
        'request_id': rid,
        'twofa_value': totp,
        'twofa_type': 'app_code',
        'skip_session': ''
      };

      return await _dio.post('twofa', data: data, options: options);
    } on DioException catch (e) {
      return e.response;
    }
  }
}
