import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:momentum/colors.dart';
import 'package:momentum/dio/ChartService.dart';
import 'package:html/parser.dart' as html;
import 'package:flutter/material.dart';

import 'component.dart';

class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  Map<String, dynamic> allData = {};
  late Box stockBox;

  @override
  void initState() {
    super.initState();
    _getList();
  }

  Future<void> _getList() async {
    stockBox = await Hive.openBox('stockBox');

    for (var element in stockBox.values) {
      allData[element['code']] = element;
    }

    print(stockBox.values.length);

    setState(() {});
  }

  bool isScanning = false;

  void _scan(per) async {
    setState(() {
      isScanning = true;
    });

    final chartService = ChartService();
    var htmlText = await chartService.getToken();

    final doc = html.parse(htmlText.data);
    String? token =
        doc.querySelector('meta[name="csrf-token"]')!.attributes['content'];

    final res = await chartService.chartScan(token, per);
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

    // allData['NHPC'] = {
    //   'code': 'NHPC',
    //   'selected': true,
    //   'high': 0,
    //   'low': 0
    // };

    await stockBox.clear();
    await stockBox.putAll(allData);

    setState(() {
      isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final mediaQueryData = MediaQuery.of(context);
    // final statusBarHeight = mediaQueryData.padding.top;

    return Container(
      color: MyColors.back,
      // padding: EdgeInsets.only(top: statusBarHeight),
      child: Column(
        children: [
          Expanded(
            child: allData.isEmpty
                ? const Center(
                    child: Text(
                    'NOTHING TO SHOW HERE',
                    style: TextStyle(fontSize: 18, color: Colors.white),
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
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        // minimumSize: const Size(double.infinity, 40)
                      ),
                      onPressed: isScanning ? null : (){_scan(1.02);},
                      child: isScanning
                          ? progressCircle()
                          : const Text(
                              'Scan Now 2%',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            )),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          // minimumSize: const Size(double.infinity, 40)
                      ),
                      onPressed: isScanning ? null : (){ _scan(1.03);},
                      child: isScanning
                          ? progressCircle()
                          : const Text(
                              'Scan Now 3%',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            )),
                ),
              ],
            ),
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
          border: Border(bottom: BorderSide(color: MyColors.divider))),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item['code'],
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          Checkbox(
              activeColor: Colors.white,
              checkColor: MyColors.back,
              side: const BorderSide(color: Colors.white),
              value: item['selected'],
              onChanged: (checked) async {
                item['selected'] = checked;

                setState(() {
                  allData[item['code']] = item;
                });
                await stockBox.put(item['code'], item);
              })
        ],
      ),
    );
  }
}
