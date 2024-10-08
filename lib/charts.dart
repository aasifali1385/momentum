import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:momentum/dio/ChartService.dart';
import 'package:html/parser.dart' as html;
import 'package:image/image.dart' as Img;

class Charts extends StatefulWidget {
  const Charts({super.key});

  @override
  State<Charts> createState() => _ChartsState();
}

class _ChartsState extends State<Charts> {
  Map<String, dynamic> allData = {};
  late Box<dynamic> stockBox;

  int progress = 0;

  @override
  void initState() {
    super.initState();
    _getList();
  }

  void _getList() async {
    stockBox = await Hive.openBox('stockBox');
    progress = 1;
    for (var element in stockBox.values) {
      element['image'] = await _getChart(element['code']);
      allData[element['code']] = element;
      setState(() {
        progress++;
      });
    }
  }

  Future<dynamic> _getChart(code) async {
    final res = await ChartService().getChart(code);
    final doc = html.parse(res.data);
    String? src = doc.querySelector('img')!.attributes['src'];

    Uint8List uint8list = base64Decode(src.toString().split(',')[1]);
    Img.Image? image = Img.decodeImage(uint8list);
    Img.Image rotatedImage = Img.copyRotate(image!, angle: -90);
    Uint8List rotatedUint8list = Img.encodeJpg(rotatedImage);
    // String rotatedBase64Image = base64Encode(rotatedUint8list);
    return rotatedUint8list;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final statusBarHeight = mediaQueryData.padding.top;

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.only(top: statusBarHeight),
      child: progress > 1
          ? stockBox.length != allData.length
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    color: Colors.orange,
                    value: progress / stockBox.length,
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: allData.length,
                  itemBuilder: (context, index) {
                    List<String> keys = allData.keys.toList();
                    String key = keys[index];
                    return chart(allData[key]);
                  })
          : const Align(
              alignment: Alignment.bottomCenter,
              child: LinearProgressIndicator(
                minHeight: 8,
                color: Colors.amber,
              ),
            ),
    );
  }

  Widget chart(item) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Image.memory(item['image']),
        Transform.rotate(
          origin: const Offset(33, -59),
          angle: -90 * 3.14 / 180,
          child: Checkbox(
              value: item['selected'],
              onChanged: (checked) {
                item['selected'] = checked;

                setState(() {
                  allData[item['code']] = item;
                });
                stockBox.put(item['code'], item);
              }),
        )
      ],
    );
  }
}
