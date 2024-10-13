import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:momentum/dio/angel_service.dart';

import 'colors.dart';
import 'component.dart';

class Open extends StatefulWidget {
  const Open({super.key});

  @override
  State<Open> createState() => _OpenState();
}

class _OpenState extends State<Open> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  late Box<dynamic> prefBox;

  void _init() async {
    prefBox = await Hive.openBox('pref');
    AngelService().setToken(prefBox.get('angelToken', defaultValue: ''));
    _getData();
  }

  bool? isLogin;

  List<dynamic> list = [];

  void _getData() async {
    final res = await AngelService().gttList();
    print('----------');
    print(res);

    if (res.data['message'] == "SUCCESS") {
      isLogin = true;
      list = res.data['data'];
    } else {
      isLogin = false;
    }

    setState(() {});
    // {"success":false,"message":"Invalid Token","errorCode":"AG8001","data":""}
    // {"status":true,"message":"SUCCESS","errorcode":"",
    // "data":[
    // {"stoplossprice":0.0,"stoplosstriggerprice":0.0,"gttType":"GENERIC","status":"CANCELLED","createddate":"2024-10-11T17:48:26.858+05:30","updateddate":"2024-10-11T18:09:04.161+05:30","expirydate":"2025-10-12T17:48:26.841+05:30","clientid":"A442418","tradingsymbol":"GRANULES-EQ","symboltoken":"11872","exchange":"NSE","producttype":"DELIVERY","transactiontype":"BUY","price":608.06,"qty":14,"triggerprice":608.01,"disclosedqty":0,"id":3375316},
    // {"stoplossprice":0.0,"stoplosstriggerprice":0.0,"gttType":"GENERIC","status":"CANCELLED","createddate":"2024-10-11T17:48:26.713+05:30","updateddate":"2024-10-11T18:09:01.463+05:30","expirydate":"2025-10-12T17:48:26.687+05:30","clientid":"A442418","tradingsymbol":"TRENT-EQ","symboltoken":"1964","exchange":"NSE","producttype":"DELIVERY","transactiontype":"BUY","price":8317.16,"qty":1,"triggerprice":8317.11,"disclosedqty":0,"id":3375315},
  }

  bool isCancel = false;

  void _cancelGTT(data) async {
    final res = await AngelService().cancelGTT(data);
    print(res);
    if (res.data["message"] == "SUCCESS") {
      _getData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          res.data['message'].toString(),
          style: const TextStyle(
              color: MyColors.back, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.white,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final statusBarHeight = mediaQueryData.padding.top;

    return Container(
      padding: EdgeInsets.only(top: statusBarHeight),
      color: MyColors.back,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: isLogin == null
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : !isLogin!
                ? const Text(
                    'PLEASE LOGIN',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(0),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      String dateStr = list[index]['createddate'];

                      bool isHeader = (index == 0) ||
                          (dateStr.substring(0, 10) !=
                              (list[index - 1]['createddate'])
                                  .substring(0, 10));

                      return item(
                        isHeader,
                        DateTime.parse(dateStr),
                        list[index],
                      );
                    }),
      ),
    );
  }

  Widget item(isHeader, date, data) {
    var icon = Icons.add;
    var color = Colors.white;
    var longClick = () {};

    switch (data['status']) {
      case 'NEW':
        icon = Icons.cancel_outlined;
        color = Colors.white;
        longClick = () {
          _cancelGTT(data);
        };

      case "CANCELLED":
        icon = Icons.cancel_outlined;
        color = Colors.white38;

      case 'ACTIVE':
      case 'SENTTOEXCHANGE':
    }

    return Column(
      children: [
        if (isHeader) header(date),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              InkWell(
                onLongPress: longClick,
                child: Icon(
                  icon,
                  color: color,
                  size: IconTheme.of(context).size! + 4,
                ),
              ),
              const SizedBox(width: 4),
              Text(data['tradingsymbol'],
                  style: TextStyle(fontSize: 18, color: color)),
              Expanded(
                child: Text('${data['qty'].round()} x ${data['price'].round()}',
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 18, color: color)),
              ),
              SizedBox(
                width: 75,
                child: Text(' = ${(data['qty'] * data['price']).toInt()}',
                    style: TextStyle(fontSize: 18, color: color)),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget header(date) {
    return Container(
      width: double.infinity,
      color: Colors.white12,
      alignment: Alignment.center,
      child: Text(
        // DateFormat('dd MMM, hh:mm a').format(date),
        DateFormat('dd MMM yyyy').format(date),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white70,
          fontSize: 15,
        ),
      ),
    );
  }
}
