import 'package:dio/dio.dart';

class AngelService {
  static final AngelService _instance = AngelService._internal();

  factory AngelService() => _instance;

  late Dio _dio;
  String token = '';

  AngelService._internal() {
    _dio = Dio();
    _configureDio();
  }

  AngelService._();

  /////////////////////////////////
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
  void setToken(tokenRec) {
    token = tokenRec;
  }

  /////////////////////////////////

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

  Future<dynamic> getSymbolToken(progress) async {
    try {
      return await _dio.get(
          'https://margincalculator.angelbroking.com/OpenAPI_File/files/OpenAPIScripMaster.json',
          onReceiveProgress: progress);
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

  Future<dynamic> getData(tokens) async {
    try {
      final data = {
        "mode": "OHLC",
        "exchangeTokens": {"NSE": tokens}
      };

      return await _dio.post('secure/angelbroking/market/v1/quote',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));
    } on DioException catch (e) {
      return e.response;
    }
  }

  Future<dynamic> getDataInstrument(data) async {
    try {
      return await _dio.post(
          'https://apiconnect.angelone.in/order-service/rest/secure/angelbroking/order/v1/getLtpData',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));
    } on DioException catch (e) {
      return e.response;
    }
  }

  Future<dynamic> createGTT(data) async {
    try {
      // final data = {
      //   "tradingsymbol": "SBIN-EQ", // *
      //   "symboltoken": "3045", // *
      //   "exchange": "NSE",
      //   "transactiontype": "BUY",
      //   "producttype": "DELIVERY",
      //   "price": "800",
      //   "qty": "10",
      //   "triggerprice": "799",
      //   "disclosedqty": "0",
      //   ///////////////////////////////
      //   "gttType": "OCO",
      //   "stoplosstriggerprice": "700",
      //   "stoplossprice": '699',
      // };

      return await _dio.post('secure/angelbroking/gtt/v1/createRule',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));
    } on DioException catch (e) {
      return e.response;
    }
  }

  Future<dynamic> gttList() async {
    try {
      final data = {
        // "status": ["NEW", "CANCELLED", "ACTIVE", "SENTTOEXCHANGE", "FORALL"],

        // null => (TRIGGERED & REJECTED) | Problem:(TRIGGERED & EXECUTED)
        // NEW => PENDING / Placed GTT
        // CANCELLED => CANCELLED
        // ACTIVE =>
        // SENTTOEXCHANGE =>
        // FORALL => Placed + Cancelled

        "status": ["FORALL"],
        "page": 1,
        "count": 20
      };

      return await _dio.post('secure/angelbroking/gtt/v1/ruleList',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));
    } on DioException catch (e) {
      return e.response;
    }
  }

  Future<dynamic> getNewGtt() async {
    try {
      final data = {
        "status": ["NEW"],
        "page": 1,
        "count": 20
      };

      return await _dio.post('secure/angelbroking/gtt/v1/ruleList',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));
    } on DioException catch (e) {
      return e.response;
    }
  }

  Future<dynamic> cancelGTT(gtt) async {
    try {
      final data = {
        "id": gtt['id'],
        "symboltoken": gtt['symboltoken'],
        "exchange": gtt['exchange']
      };

      return await _dio.post('secure/angelbroking/gtt/v1/cancelRule',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));
    } on DioException catch (e) {
      return e.response;
    }
  }

  Future<dynamic> getPosition() async {
    try {
      return await _dio.get('secure/angelbroking/order/v1/getPosition',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
    } on DioException catch (e) {
      return e.response;
    }
  }

  Future<dynamic> getHolding() async {
    try {
      return await _dio.get('secure/angelbroking/portfolio/v1/getHolding',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
    } on DioException catch (e) {
      return e.response;
    }
  }

///////////////////
}
