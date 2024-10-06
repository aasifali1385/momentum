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
  late Box<dynamic> stockBox;

  String scan = "Scan";

  @override
  void initState() {
    super.initState();
    _getList();
  }

  Future<void> _getList() async {
    stockBox = await Hive.openBox('stockBox');
    allData = {for (var element in stockBox.values) element['code']: element};
    setState(() {});
  }

  void _scan() async {
    setState(() {
      scan = "Scanning...";
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
    setState(() {
      scan = "Scan";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber,
      child: Column(
        children: [
          Expanded(
              child: Column(
            children: [
              const SizedBox(height: 30),
              for (var da in allData.values) item(da),
            ],
          )
              // allData.isEmpty
              //     ? const Text(
              //         '\n\n\nNothing!',
              //         style: TextStyle(fontSize: 20),
              //       )
              //     : ListView.builder(
              //         itemCount: allData.length,
              //         itemBuilder: (context, index) {
              //           return item(allData. [index]);
              //         }),
              ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40)),
                onPressed: scan == "Scan" ? _scan : null,
                child: Text(scan)),
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
