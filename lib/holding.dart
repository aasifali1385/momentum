import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:momentum/component.dart';
import 'package:momentum/dio/angel_service.dart';
import 'colors.dart';

class Holding extends StatefulWidget {
  const Holding({super.key});

  @override
  State<Holding> createState() => _HoldingState();
}

class _HoldingState extends State<Holding> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  bool isLoading = true;
  List<dynamic> list = [];

  int rpt = 0;

  void _init() async {
    Box<dynamic> prefBox = await Hive.openBox('pref');
    AngelService().setToken(prefBox.get('angelToken', defaultValue: ''));
    rpt = prefBox.get('rpt', defaultValue: 100);
    _getData();
  }

  List<bool> isPlacing = [];

  void _getData() async {
    final res = await AngelService().getHolding();
    // print('Holding=> ${res.data}');
    // {tradingsymbol: NHPC-EQ, exchange: NSE, isin: INE848E01016, t1quantity: 1, realisedquantity: 0, quantity: 2, authorisedquantity: 0,
    // product: DELIVERY, collateralquantity: null, collateraltype: null, haircut: 0.0, averageprice: 90.4, ltp: 90.01, symboltoken: 17400,
    // close: 91.06, profitandloss: -1.0, pnlpercentage: -0.43}

    if (res.data['message'] != 'SUCCESS') {
      snackbar(res.data['message']);
      setState(() {
        isLoading = false;
      });
      return;
    }

    isPlacing = List.filled(res.data['data'].length, false);

    final gttRes = await AngelService().getNewGtt();

    if (gttRes.data['message'] != 'SUCCESS') {
      snackbar(gttRes.data['message']);
      setState(() {
        isLoading = false;
      });
      return;
    }

    // print("GTTS=> $gtts");
    // [{stoplossprice: 89.88, stoplosstriggerprice: 89.93, gttType: OCO, status: NEW,
    // createddate: 2024-10-15T14:25:11.355+05:30, updateddate: 2024-10-15T14:27:41.171+05:30, expirydate: 2025-10-16T14:25:11.326+05:30, clientid: A442418,
    // tradingsymbol: NHPC-EQ, symboltoken: 17400, exchange: NSE, producttype: DELIVERY, transactiontype: SELL, price: 90.64, qty: 2,
    // triggerprice: 90.59, disclosedqty: 0, id: 3410258}

    List<dynamic> gtts = gttRes.data['data'];

    List<dynamic> holdings = res.data['data'];
    holdings.sort((a, b) => a['tradingsymbol'].compareTo(b['tradingsymbol']));

    list = [];
    for (var pos in holdings) {
      pos['haveOCO'] = false;
      pos['qtyOCO'] = 0;

      for (var gtt in gtts) {
        if (gtt['tradingsymbol'] == pos['tradingsymbol'] &&
            gtt['transactiontype'] == "SELL" &&
            gtt['gttType'] == "OCO") {
          pos['haveOCO'] = true;
          pos['qtyOCO'] = gtt['qty'];
          break;
        }
      }
      list.add(pos);
    }

    setState(() {
      isLoading = false;
    });
  }

  void _createOCO(holding, index) async {
    // print(holding);
    // {tradingsymbol: NHPC-EQ, exchange: NSE, isin: INE848E01016, t1quantity: 1, realisedquantity: 0, quantity: 2, authorisedquantity: 0,
    // product: DELIVERY, collateralquantity: null, collateraltype: null, haircut: 0.0, averageprice: 90.4, ltp: 90.01, symboltoken: 17400,
    // close: 91.06, profitandloss: -1.0, pnlpercentage: -0.43}

    final ltp = await AngelService().getDataInstrument({
      "exchange": holding['exchange'],
      "tradingsymbol": holding['tradingsymbol'],
      "symboltoken": holding['symboltoken'],
    });


    if (ltp.data["message"] != "SUCCESS") {
      snackbar(ltp.data['message'].toString());
      setState(() {
        isPlacing[index] = false;
      });
      return;
    }

    // print(ltp);
    // {"status":true,"message":"SUCCESS","errorcode":"",
    // "data":{"exchange":"NSE","tradingsymbol":"AMBUJACEM-EQ","symboltoken":"1270","open":590.2,"high":597.0,"low":586.55,"close":588.9,"ltp":590.35}}
    final da = ltp.data['data'];

    var pr = da['high'] * (1 + 0.001);
    final sl = da['low'] * (1 - 0.001);
    final ratio = (pr - sl) * 2;

    final gtt = {
      "exchange": da['exchange'],
      "transactiontype": "SELL",
      "producttype": "DELIVERY",
      "disclosedqty": "0",
      "tradingsymbol": da['tradingsymbol'],
      "symboltoken": da['symboltoken'],

      "qty": holding['quantity'],
      "price": pr + ratio + 0.05,
      "triggerprice": pr + ratio,

      "gttType": "OCO", // "GENERIC"
      "stoplosstriggerprice": sl,
      "stoplossprice": sl - 0.05,
    };

    // print("GTT=> $gtt");
    // break;

    final res = await AngelService().createGTT(gtt);
    print('OCO => $res');
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
      setState(() {
        isPlacing[index] = false;
      });
    }
  }

  void snackbar(message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message.toString(),
        style: const TextStyle(
            color: MyColors.back, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      backgroundColor: Colors.white,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MyColors.back,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return item(list[index], index);
                }),
      ),
    );
  }

  Widget item(data, index) {
    Color color = data['haveOCO']
        ? data['qtyOCO'] == data['quantity']
            ? Colors.green
            : Colors.amber
        : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          isPlacing[index]
              ? progressCircle()
              : InkWell(
                  onLongPress: data['haveOCO']
                      ? null
                      : () {
                          // setState(() {
                          //   isPlacing[index] = true;
                          // });
                          // _createOCO(data, index);
                        },
                  child: Icon(
                    data['haveOCO']
                        ? Icons.gpp_good_outlined
                        : Icons.gpp_maybe_outlined,
                    color: color,
                    size: IconTheme.of(context).size! + 4,
                  ),
                ),
          const SizedBox(width: 6),
          Text(data['tradingsymbol'],
              style: TextStyle(fontSize: 18, color: color)),
          const Expanded(child: SizedBox()),
          SizedBox(
            width: 70,
            child: Text('B: ${data['quantity']}',
                style: TextStyle(fontSize: 18, color: color)),
          ),
          SizedBox(
            width: 70,
            child: Text('S: ${data['haveOCO'] ? data['qtyOCO'] : ''}',
                style: TextStyle(fontSize: 18, color: color)),
          ),
        ],
      ),
    );
  }
}
