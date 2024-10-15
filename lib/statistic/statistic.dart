import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:momentum/statistic/symbol_token.dart';
import '../colors.dart';
import '../component.dart';
import '../dio/angel_service.dart';

class Statistic extends StatefulWidget {
  const Statistic({super.key});

  @override
  State<Statistic> createState() => _StatisticState();
}

class _StatisticState extends State<Statistic> {
  late Box<dynamic> prefBox;
  late Box<dynamic> stockBox;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    prefBox = await Hive.openBox('pref');
    stockBox = await Hive.openBox('stockBox');
    _checkLogin();
    _getList();
  }

  ////////////////////// Login  //////////////////////
  bool? isLogin;
  bool isLogging = false;

  void _checkLogin() async {
    AngelService().setToken(prefBox.get('angelToken', defaultValue: ''));
    final res = await AngelService().getProfile();
    // print(res);
    // {"status":true,"message":"SUCCESS","errorcode":"","data":{"clientcode":"A442418","name":"Aasif  Ali","email":"","mobileno":"","exchanges":["nse_fo","nse_cm","cde_fo","ncx_fo","bse_fo","bse_cm","mcx_fo"],"products":["MARGIN","MIS","NRML","CNC","CO","BO"],"lastlogintime":"","broker":""}}
    // {"success":false,"message":"Invalid Token","errorCode":"AG8001","data":""}
    setState(() {
      isLogin = res.data['message'] == "SUCCESS";
    });
  }

  void _login(String totp) async {
    setState(() {
      isLogging = true;
    });

    final res = await AngelService().login(totp);
    print('Login...........');
    print(res);
    // {"status":true,"message":"SUCCESS","errorcode":"","data":{"jwtToken":"eyJhbGciOiJIUzUxMiJ}}

    if (res.data['status']) {
      isLogin = true;
      final token = res.data['data']['jwtToken'];
      await prefBox.put('angelToken', token);
      AngelService().setToken(token);
    } else {
      isLogin = false;
    }

    setState(() {});
  }

  ////////////////// Get initial List //////////////////

  int rpt = 0;
  num marginReq = 100;

  var orders = [];

  void _getList() async {
    rpt = prefBox.get('rpt', defaultValue: 100);

    for (var data in stockBox.values) {
      if (data['selected']) {
        orders.add({'tradingsymbol': data['code'], 'price': 0, 'qty': 0});
      }
    }
    setState(() {});
  }

  /////////////////// Syncing ////////////////////
  bool isSyncing = false;

  void _sync() async {
    setState(() {
      isSyncing = true;
    });

    final tokensBox = await Hive.openBox('symbolTokens');
    if (tokensBox.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Please Download Symbol Tokens...',
          style: TextStyle(
              color: MyColors.back, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.white,
      ));

      setState(() {
        isSyncing = false;
      });
      return;
    }

    List<String> sTokens = [];
    for (var data in stockBox.values) {
      if (data['selected']) {
        String token = tokensBox.get('${data['code']}-EQ', defaultValue: '');
        if (token.isNotEmpty) sTokens.add(token);
      }
    }

    /////////////////////////////////////////////////////////////
    final res = await AngelService().getData(sTokens);
    // print(res);

    if (res.data['message'] != "SUCCESS") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          res.data['message'].toString(),
          style: const TextStyle(
              color: MyColors.back, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.white,
      ));

      setState(() {
        isSyncing = false;
      });
      return;
    }
    ////////////////////////////////////////////////////
    final ls = res.data['data']['fetched'];
    orders.clear();
    marginReq = 0;

    for (var da in ls) {
      var pr = da['high'] * (1 + 0.001);
      final sl = da['low'] * (1 - 0.001);
      var qty = (rpt / (pr - sl)).toInt();
      ////////////
      // pr = da['ltp'];
      // qty = 1;
      ////////////
      marginReq += qty * (pr + 0.05);

      orders.add({
        "exchange": "NSE",
        "transactiontype": "BUY",
        "producttype": "DELIVERY",
        "disclosedqty": "0",
        "tradingsymbol": da['tradingSymbol'],
        "symboltoken": da['symbolToken'],
        "price": pr + 0.05,
        "qty": qty,
        "triggerprice": pr,
////////////////////////////////////
//         "gttType": "OCO", // "GENERIC"
        "stoplosstriggerprice": sl,
        "stoplossprice": sl - 0.05,
      });
    }

    setState(() {
      isSyncing = false;
    });
  }

  /////////////////// Place Orders //////////////////
  bool isPlacing = false;

  void _placeOrders() async {
    setState(() {
      isPlacing = true;
    });

    for (var data in orders) {
      print(data);

      final res = await AngelService().createGTT(data);
      // print(res);
      // {"status":true,"message":"SUCCESS","data":{"id":3375315}}
      // {"status":true,"message":"SUCCESS","data":{"id":3375316}}
    }

    setState(() {
      isPlacing = false;
    });
  }

  //////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final statusBarHeight = mediaQueryData.padding.top;

    final totpControl = TextEditingController();

    return Container(
      color: MyColors.back,
      padding: EdgeInsets.fromLTRB(10, statusBarHeight + 10, 10, 10),
      child: Column(
        children: [
          const SymbolToken(),
          const Divider(color: MyColors.divider),
          const SizedBox(height: 6),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                flex: 5,
                child: isLogin == null
                    ? Container(
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.white),
                        ))
                    : isLogin!
                        ? OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 46),
                                side: const BorderSide(color: Colors.white)),
                            onPressed: isSyncing ? null : _sync,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                isSyncing
                                    ? progressCircle()
                                    : const Icon(Icons.sync_rounded,
                                        color: Colors.white),
                                const SizedBox(width: 10),
                                const Text(
                                  'Sync Now',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          )
                        : TextField(
                            controller: totpControl,
                            maxLength: 6,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  style: IconButton.styleFrom(
                                      backgroundColor: Colors.white),
                                  onPressed: isLogging
                                      ? null
                                      : () {
                                          if (totpControl.text.length == 6) {
                                            _login(totpControl.text);
                                          }
                                        },
                                  icon: isLogging
                                      ? progressCircle()
                                      : const Icon(
                                          Icons.login_rounded,
                                          color: MyColors.back,
                                        )),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 26),
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(50)),
                              labelText: 'Enter TOTP',
                              labelStyle: const TextStyle(color: Colors.white),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(50)),
                            ),
                          )),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 46),
                    side: const BorderSide(color: Colors.white)),
                onPressed: () async {
                  setState(() {
                    rpt = rpt < 1000 ? rpt + 50 : 100;
                  });
                  await prefBox.put('rpt', rpt);
                },
                child: Text(
                  'RPT: $rpt',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ]),
          Expanded(
            child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return item(orders[index]);
                }),
          ),
          marginReq == 0
              ? const SizedBox()
              : OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      // backgroundColor: MyColors.primary,
                      // disabledBackgroundColor: Colors.white10,
                      minimumSize: const Size(double.infinity, 40)),
                  onPressed: null,
                  onLongPress: isPlacing ? null : _placeOrders,
                  child: isPlacing
                      ? progressCircle()
                      : Text(
                          'Place Orders (Margin Required: ${marginReq.toInt()})',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15),
                        ),
                ),
        ],
      ),
    );
  }

  Widget item(data) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white54))),
        child: Row(
          children: [
            Text(data['tradingsymbol'],
                style: const TextStyle(fontSize: 17, color: Colors.white)),
            Expanded(
              child: Text('${data['qty'].round()} x ${data['price'].round()}',
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 17, color: Colors.white)),
            ),
            SizedBox(
              width: 70,
              child: Text(' = ${(data['qty'] * data['price']).toInt()}',
                  style: const TextStyle(fontSize: 17, color: Colors.white)),
            ),
          ],
        ));
  }
}
