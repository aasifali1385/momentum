import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:momentum/dio/ChartService.dart';
import 'package:html/parser.dart' as html;

class Charts extends StatefulWidget {
  const Charts({super.key});

  @override
  State<Charts> createState() => _ChartsState();
}

class _ChartsState extends State<Charts> {
  Map<String, dynamic> allData = {};
  late Box<dynamic> stockBox;

  final List<Future<String?>> _futures = [];

  @override
  void initState() {
    super.initState();
    _getList();
  }

  void _getList() async {
    stockBox = await Hive.openBox('stockBox');
    allData = {for (var element in stockBox.values) element['code']: element};

    _futures.clear();
    for (var data in allData.values) {
      _futures.add(_getChart(data['code']));
    }
    setState(() {});
  }

  Future<String?> _getChart(code) async {
    final res = await ChartService().getChart(code);
    final doc = html.parse(res.data);
    return doc.querySelector('img')!.attributes['src'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      height: double.infinity,
      // width: double.infinity,
      // padding: const EdgeInsets.only(top: 24),

      child: ListView.builder(
          itemCount: _futures.length,
          itemBuilder: (context, index) {
            return FutureBuilder(
                future: _futures[index],
                builder: (context, snapshot) {
                  return item(snapshot, index);
                });
          }),
    );
  }

  Widget item(snapshot, index) {
    return Container(
      // color: Colors.red,
      child: snapshot.data == null
          ? const Text('\n    Loading...\n',
              style: TextStyle(color: Colors.white, fontSize: 16))
          : Stack(
              children: [
                Image.memory(base64Decode(snapshot.data.split(',')[1])),
              ],
            ),
    );
  }
}
