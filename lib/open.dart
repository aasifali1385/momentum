import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
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

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return item(list[index]);
                    }),
      ),
    );
  }

  Widget item(item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: MyColors.divider))),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item['tradingsymbol'],
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
