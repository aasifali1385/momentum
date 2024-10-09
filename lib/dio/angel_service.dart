import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AngelService {
  static final AngelService _instance = AngelService._internal();

  factory AngelService() => _instance;

  late Dio _dio;
  String token = '';

  late Box<dynamic> pref;

  AngelService._internal() {
    _dio = Dio();
    _configureDio();
  }

  AngelService._();

  //////////////////////////////////////
  void _configureDio() {
    // Configure Dio instance
    _dio.options.baseUrl = 'https://apiconnect.angelone.in/rest/';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-UserType': 'USER',
      'X-SourceID': 'WEB',
      'X-ClientLocalIP': 'CLIENT_LOCAL_IP',
      'X-ClientPublicIP': 'CLIENT_PUBLIC_IP',
      'X-MACAddress': 'MAC_ADDRESS',
      'X-PrivateKey': 'XulMXS75'
    };
  }

  Dio get dio => _dio;

  /////////////////////////////////

  Future<void> configureBox() async {
    pref = await Hive.openBox('preferences');
    token = pref.get('token');
  }

  /////////////////////////////////////////////

  Future<void> saveToken(token) async {
    token = token;
    await pref.put('token', token);
  }

  ///////////////////////////////////

  // final API_KEY = 'XulMXS75';
  // final SECRET_KEY = 'b68b1579-316d-4e00-8472-eacae849e27a';

  Future<dynamic> login(totp) async {
    try {
      final data = {
        "clientcode": "A442418",
        "password": "8899",
        "totp": totp,
        "state": "STATE_VARIABLE"
      };

      return await _dio.post('auth/angelbroking/user/v1/loginByPassword',
          data: data);
    } on DioException catch (e) {
      return e.response;
    }
  }

  Future<dynamic> getSymbolToken() async {
    try {
      return await _dio.get(
        'https://margincalculator.angelbroking.com/OpenAPI_File/files/OpenAPIScripMaster.json',
        onReceiveProgress: (transfer, total) {
          print('${transfer / total * 100}');
        },
      );
    } on DioException catch (e) {
      e.response;
    }
  }

  Future<dynamic> getProfile() async {
    try {
      return await _dio.get('secure/angelbroking/user/v1/getProfile',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
    } on DioException catch (e) {
      return e.response;
    }
  }

  Future<dynamic> getData() async {
    try {
      final data = {
        "mode": "OHLC",
        "exchangeTokens": {
          "NSE": ["3045", "2885"]
        }
      };

      return await _dio.post('secure/angelbroking/market/v1/quote',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));
    } on DioException catch (e) {
      return e.response;
    }
  }

  Future<dynamic> createGTT() async {
    try {
      final data = {
        "tradingsymbol": "SBIN-EQ", // *
        "symboltoken": "3045", // *
        "exchange": "NSE",
        "transactiontype": "BUY",
        "producttype": "DELIVERY",
        "price": "800",
        "qty": "10",
        "triggerprice": "799",
        "disclosedqty": "0",
        ///////////////////////////////
        "gttType": "OCO",
        "stoplosstriggerprice": "700",
        "stoplossprice": '699',
      };

      return await _dio.post('secure/angelbroking/gtt/v1/createRule',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));
    } on DioException catch (e) {
      return e.response;
    }
  }

///////////////////
}
