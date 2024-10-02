import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:momentum/dio/ChartService.dart';
import 'package:html/parser.dart' as html;

class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  List<dynamic> list = [];

  @override
  void initState() {
    super.initState();
    _scan();
  }

  void _scan() async{

    final chartService = ChartService();

    var htmlText = await chartService.getToken();

    final doc = html.parse(htmlText.data);
    String? token = doc.querySelector('meta[name="csrf-token"]')!.attributes['content'];

    print('------------------');
    print(token);

    final res = await chartService.chartScan(token);
    final jsonData = jsonDecode(res.toString());
    final dataArray = jsonData['data'];
    print(dataArray[0]);

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber,
      child: Column(
        children: [
          Expanded(
            child: list.isEmpty
                ? const Text('\n\n\nNothing!',style: TextStyle(fontSize: 20),)
                : ListView.builder(itemCount: 13, itemBuilder: item),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40)),
                onPressed: _scan,
                child: const Text('Scan')),
          )
        ],
      ),
    );
  }

  Widget item(context, index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      child: Row(
        children: [
          Expanded(
              child: Text('Item $index', style: const TextStyle(fontSize: 16))),
          Checkbox(value: false, onChanged: (checked) {})
        ],
      ),
    );
  }
}