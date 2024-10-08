import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:momentum/dio/KiteService.dart';

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
    _getList();
    _login();
  }

  void _login() async {
    // final res = await KiteService().login();
    // print(res);
    // final rid = res.data['data']['request_id'];

    // final res2 = await KiteService().twoFacAuth(rid, '323588');
    // print(res2); //{"status":"success","data":{"profile":{}}}

    // if (res2.data['status'] == 'success') {
    //   for (String token in res2.headers['set-cookie']) {
    //     if (token.startsWith('enctoken')) {
    // KiteService().setSP('enctoken', token.split(';')[0].replaceFirst('=', ' '));
    // }
    // }
    // }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final statusBarHeight = mediaQueryData.padding.top;
    return Container(
      color: Colors.blueGrey[200],
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
                onPressed: () {},
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
            Text('3 x 14000', style: const TextStyle(fontSize: 16)),
          ],
        ));
  }

  Widget dialog(context) {
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
            const TextField(
              maxLength: 6,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
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
                      _login();
                      // if (_formKey.currentState!.validate()) {
                      //   _formKey.currentState!.save();
                      //   // Login logic here
                      //   print('Username: $_username, Password: $_password');
                      Navigator.of(context).pop();
                      // }
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
