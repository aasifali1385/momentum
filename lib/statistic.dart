import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:momentum/dio/KiteService.dart';

import 'dio/angel_service.dart';

class Statistic extends StatefulWidget {
  const Statistic({super.key});

  @override
  State<Statistic> createState() => _StatisticState();
}

class _StatisticState extends State<Statistic> {
  String connection = 'Checking...';
  int risk = 500;

  Map<String, dynamic> allData = {};
  late Box<dynamic> stockBox;

  final List<dynamic> list = [];

  void _getList() async {
    stockBox = await Hive.openBox('stockBox');
    allData = {for (var element in stockBox.values) element['code']: element};

    for (var data in allData.values) {
      if (data['selected']) list.add(data['code']);
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _configure();
  }
  void _configure() async {
    await AngelService().configureBox();
    _checkLogin();
    _getList();
  }

  void _checkLogin() async {
    final res = await AngelService().getProfile();

    print(res);

    setState(() {
       connection = res.data['status'] ? "Connected" : "Disconnected";
    });
  }

  void _login(String totp) async {
    final res = await AngelService().login(totp);

    if (res.data['status']) {
      connection = "Connected";
      final token = res.data['data']['jwtToken'];
      await AngelService().saveToken(token);
    }
    else {
      connection = 'Disconnected';
    }
  }

  void _sync() async {

  }



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
      color: Colors.lightGreen,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          SizedBox(height: statusBarHeight),
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
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return item(list[index]);
                }),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 40)),
            onPressed: () {},
            onLongPress: () {},
            child: const Text(
              'Place Orders: (Total Margin Required: 5000)',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget item(data) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black45))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(data, style: const TextStyle(fontSize: 16)),
            Text('', style: const TextStyle(fontSize: 16)),
          ],
        ));
  }

  Widget dialog(context) {

    final controller = TextEditingController();
    var errorText = '';

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
              decoration:  InputDecoration(
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

                      if(controller.text.isEmpty){
                        errorText = "Please enter TOTP";
                      }
                      else{
                        _login(controller.text);
                      }
                    },
                    child: const Text(
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
