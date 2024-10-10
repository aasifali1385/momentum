import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:momentum/dio/KiteService.dart';
import 'package:momentum/symbol_token.dart';

import 'dio/angel_service.dart';

class Statistic extends StatefulWidget {
  const Statistic({super.key});

  @override
  State<Statistic> createState() => _StatisticState();
}

class _StatisticState extends State<Statistic> {
  @override
  void initState() {
    super.initState();
    // _configure();
  }

  void _configure() async {
    await AngelService().configureBox();
    _checkLogin();
    _getList();
  }

  /////////////////////////////

  String connection = 'Checking...';
  int risk = 500;
  num marginReq = 0;

  late Box<dynamic> stockBox;
  var orders = [];

  void _getList() async {
    stockBox = await Hive.openBox('stockBox');

    for (var data in stockBox.values) {
      if (data['selected']) {
        orders.add({'tradingsymbol': data['code'], 'price': 0, 'qty': 0});
      }
    }

    var sTokens = ["3045", "2885"];

    // final res = await ApiService2().getData(sTokens);
    // if(!res.data['status']){
    //   print('Please Login First');
    //   return; }

    // print(res);
    // final ls = res.data['data']['fetched'];
    // for (var da in ls) {
    //   final pr = da['high'] * (1 + 0.001);
    //   final sl = da['low'] * (1 - 0.001);
    //   orders.add({
    //     "exchange": "NSE",
    //     "transactiontype": "BUY",
    //     "producttype": "DELIVERY",
    //     "disclosedqty": "0",
    //     "tradingsymbol": da['tradingSymbol'],
    //     "symboltoken": da['symbolToken'],
    //     "price": pr + 0.05,
    //     "qty": 500 / (pr - sl),
    //     "triggerprice": pr
    //   });
    // }

    setState(() {});
  }

  void _checkLogin() async {
    final res = await AngelService().getProfile();
    // print(res);
    // {"status":true,"message":"SUCCESS","errorcode":"","data":{"clientcode":"A442418","name":"Aasif  Ali","email":"","mobileno":"","exchanges":["nse_fo","nse_cm","cde_fo","ncx_fo","bse_fo","bse_cm","mcx_fo"],"products":["MARGIN","MIS","NRML","CNC","CO","BO"],"lastlogintime":"","broker":""}}
    // {"success":false,"message":"Invalid Token","errorCode":"AG8001","data":""}

    setState(() {
      connection =
          res.data['message'] == "SUCCESS" ? "Connected" : "Disconnected";
    });
  }

  bool login = false;

  void _login(String totp) async {
    final res = await AngelService().login(totp);

    if (res.data['status']) {
      connection = "Connected";
      final token = res.data['data']['jwtToken'];
      await AngelService().saveToken(token);
    } else {
      connection = 'Disconnected';
    }

    setState(() {
      login = false;
    });
  }

  void _sync() async {}

  void _test() async {
    // final res = await AngelService().login('408282');
    // if (res.data['status']) {
    //   final token = res.data['data']['jwtToken'];
    //   await AngelService().saveToken(token);
    // }
    // print('Login ${res.data['status']}');

    // final res = await ApiService2().getSymbolToken();
    // var symbolToken = {};
    // for (var ls in res.data) {
    //   if (ls['symbol'].toString().endsWith('-EQ')) {
    //     symbolToken[ls['symbol'].toString().replaceFirst('-EQ', '')] = ls['token'];
    //   }
    // }

    final res = await AngelService().getData();
    print(res.data['data']['fetched']);

    // final res = await ApiService2().createGTT();
    // print(res);
    // if (res.data['status']) {
    //     print(res.data['data']['id']);
    // }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final statusBarHeight = mediaQueryData.padding.top;
    return Container(
      color: Colors.amber,
      padding: EdgeInsets.fromLTRB(8, statusBarHeight + 8, 8, 8),
      child: Column(
        children: [
          const SymbolToken(),
          const Divider(color: Colors.black54,),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => dialog(context));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: connection == "Connected"
                          ? Colors.green
                          : connection == "Disconnected"
                              ? Colors.red
                              : Colors.orange,
                      minimumSize: const Size(double.infinity, 40)),
                  child: Text(
                    connection,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {},
                child: Text('RPT:$risk'),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _sync,
                icon: const Icon(Icons.sync_rounded, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return item(orders[index]);
                }),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 40)),
            onPressed: () {},
            onLongPress: () {},
            child: Text(
              'Place Orders: (Total Margin Required: $marginReq)',
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget item(data) {
    marginReq += (data['qty'] * data['price']);

    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black45))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(data['tradingsymbol'], style: const TextStyle(fontSize: 16)),
            Text(
                '${data['qty']} x ${data['price']} = ${data['qty'] * data['price']}',
                style: const TextStyle(fontSize: 16)),
          ],
        ));
  }

  Widget dialog(context) {
    final controller = TextEditingController();
    String? errorText;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Login',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              maxLength: 6,
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                errorText: errorText,
                labelText: 'Enter TOTP',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(
                  width: 6,
                ),
                Expanded(
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      setState(() {
                        if (controller.text.isEmpty) {
                          errorText = "Please enter TOTP";
                        } else {
                          login = true;
                          _login(controller.text);
                        }
                      });
                    },
                    child: login
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ))
                        : const Text(
                            'Login',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
