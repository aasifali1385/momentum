import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:momentum/dio/ChartService.dart';
import 'package:html/parser.dart' as html;

class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  Map<String, dynamic> allData = {};
  late Box stockBox;

  String status = "Scan";

  @override
  void initState() {
    super.initState();
    _getList();
  }

  Future<void> _getList() async {
    stockBox = await Hive.openBox('stockBox');
    // allData.clear();
    // allData = {for (var element in stockBox.values) element['code']: element};

    for (var element in stockBox.values) {
      allData[element['code']] = element;
    }

    print(stockBox.values.length);

    setState(() {});

    // setState(() {
    //   allData = {for (var element in stockBox.values) element['code']: element};
    // });
  }

  void _scan() async {
    setState(() {
      status = "Scanning...";
    });

    final chartService = ChartService();
    var htmlText = await chartService.getToken();

    final doc = html.parse(htmlText.data);
    String? token =
        doc.querySelector('meta[name="csrf-token"]')!.attributes['content'];

    final res = await chartService.chartScan(token);
    final jsonData = jsonDecode(res.toString());
    List<dynamic> dataArray = jsonData['data'];

    allData.clear();
    for (var ls in dataArray) {
      allData[ls['nsecode']] = {
        'code': ls['nsecode'],
        'selected': false,
        'high': 0,
        'low': 0
      };
    }

    stockBox.clear();
    await stockBox.putAll(allData);
    stockBox.close();
    setState(() {
      status = "Scan";
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final statusBarHeight = mediaQueryData.padding.top;

    return Container(
      color: Colors.green,
      // padding: EdgeInsets.only(top: statusBarHeight),
      child: Column(
        children: [
          Expanded(
            child: allData.isEmpty
                ? const Center(
                    child: Text(
                    'NOTHING TO SHOW HERE',
                    style: TextStyle(fontSize: 18),
                  ))
                : ListView.builder(
                    itemCount: allData.length,
                    itemBuilder: (context, index) {
                      List<String> keys = allData.keys.toList();
                      String key = keys[index];
                      return item(allData[key]);
                    }),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 40)),
                onPressed: status == "Scan" ? _scan : null,
                child: Text(
                  status,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                )),
          )
        ],
      ),
    );
  }

  Widget item(item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black))),
      child: Row(
        children: [
          Expanded(
              child: Text(item['code'], style: const TextStyle(fontSize: 18))),
          Checkbox(
              activeColor: Colors.black,
              value: item['selected'],
              onChanged: (checked) {
                item['selected'] = checked;

                setState(() {
                  allData[item['code']] = item;
                });
                stockBox.put(item['code'], item);
              })
        ],
      ),
    );
  }
}
