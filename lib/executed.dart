import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:momentum/component.dart';
import 'package:momentum/dio/angel_service.dart';
import 'colors.dart';

class Executed extends StatefulWidget {
  const Executed({super.key});

  @override
  State<Executed> createState() => _ExecutedState();
}

class _ExecutedState extends State<Executed> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  bool isLoading = true;
  List<dynamic> list = [];

  List<bool> isPlacing = [];

  void _init() async {
    Box<dynamic> prefBox = await Hive.openBox('pref');
    AngelService().setToken(prefBox.get('angelToken', defaultValue: ''));
    _getData();
  }

  void _getData() async {
    final res = await AngelService().getPosition();
    print('Position=> ${res.data}');
    // {"symboltoken":"17400","symbolname":"NHPC","instrumenttype":"","priceden":"1.00","pricenum":"1.00","genden":"1.00","gennum":"1.00",
    // "precision":"2","multiplier":"-1","boardlotsize":"1","exchange":"NSE","producttype":"DELIVERY","tradingsymbol":"NHPC-EQ","symbolgroup":"EQ",
    // "strikeprice":"-1.0","optiontype":"","expirydate":"","lotsize":"1","cfbuyqty":"0","cfsellqty":"0","cfbuyamount":"0.00","cfsellamount":"0.00",
    // "buyavgprice":"90.17",
    // "sellavgprice":"0.00","avgnetprice":"90.17","netvalue":"-180.34",
    // "netqty":"2",
    // "totalbuyvalue":"180.34","totalsellvalue":"0.00","cfbuyavgprice":"0.00","cfsellavgprice":"0.00","totalbuyavgprice":"90.17","totalsellavgprice":"0.00",
    // "netprice":"90.17","buyqty":"2","sellqty":"0","buyamount":"180.34","sellamount":"0.00","pnl":"-0.26","realised":"-0.00","unrealised":"-0.26",
    // "ltp":"90.04","close":"91.06"}

    if (res.data['message'] != 'SUCCESS') {
      snackbar(res.data['message']);
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (res.data['data'] == null) {
      snackbar('There is not position today!');
      setState(() {
        isLoading = false;
      });
      return;
    }

    isPlacing = List.filled(res.data['data'].length, false);

    final gttRes = await AngelService().gttList();

    if (gttRes.data['message'] != "SUCCESS") {
      snackbar(res.data['message']);
      setState(() {
        isLoading = false;
      });
      return;
    }

    List<dynamic> gtts = gttRes.data['data'];
    // print("GTTS=> $gtts");
    // [{stoplossprice: 89.88, stoplosstriggerprice: 89.93, gttType: OCO, status: CANCELLED,
    // createddate: 2024-10-15T14:25:11.355+05:30, updateddate: 2024-10-15T14:27:41.171+05:30, expirydate: 2025-10-16T14:25:11.326+05:30, clientid: A442418,
    // tradingsymbol: NHPC-EQ, symboltoken: 17400, exchange: NSE, producttype: DELIVERY, transactiontype: SELL, price: 90.64, qty: 2,
    // triggerprice: 90.59, disclosedqty: 0, id: 3410258}

    list = [];

    for (var pos in res.data['data']) {
      if (int.parse(pos['netqty']) > 0) {
        pos['haveOCO'] = false;
        pos['qtyOCO'] = 0;

        for (var gtt in gtts) {
          if (gtt['status'] == "NEW" &&
              gtt['tradingsymbol'] == pos['tradingsymbol'] &&
              gtt['transactiontype'] == "SELL" &&
              gtt['gttType'] == "OCO") {
            pos['haveOCO'] = true;
            pos['qtyOCO'] = gtt['qty'];
            break;
          }
        }

        list.add(pos);
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  void _createOCO(position, index) async {
    // print(position);
    // {symboltoken: 17400, symbolname: NHPC, instrumenttype: , priceden: 1.00, pricenum: 1.00, genden: 1.00, gennum: 1.00, precision: 2,
    // multiplier: -1, boardlotsize: 1, exchange: NSE, producttype: DELIVERY, tradingsymbol: NHPC-EQ, symbolgroup: EQ, strikeprice: -1.0,
    // optiontype: , expirydate: , lotsize: 1, cfbuyqty: 0, cfsellqty: 0, cfbuyamount: 0.00, cfsellamount: 0.00, buyavgprice: 90.17,
    // sellavgprice: 0.00, avgnetprice: 90.17, netvalue: -180.34, netqty: 2, totalbuyvalue: 180.34, totalsellvalue: 0.00, cfbuyavgprice: 0.00,
    // cfsellavgprice: 0.00, totalbuyavgprice: 90.17, totalsellavgprice: 0.00, netprice: 90.17, buyqty: 2, sellqty: 0, buyamount: 180.34,
    // sellamount: 0.00, pnl: -0.02, realised: -0.00, unrealised: -0.02, ltp: 90.16, close: 91.06}

    final qty = position['netqty'];
    final isBuy = int.parse(position['netqty']) > 0;

    final gttRes = await AngelService().gttList();
    List<dynamic> gtts = [];

    if (gttRes.data['message'] == "SUCCESS") {
      gtts = gttRes.data['data'];
    } else {
      snackbar(gttRes.data['message']);
      return;
    }

    for (var gtt in gtts) {
      if (gtt['status'] == null &&
          gtt['tradingsymbol'] == position['tradingsymbol'] &&
          isBuy) {
        final ratio = (gtt['triggerprice'] - gtt['stoplosstriggerprice']) * 2;
        gtt['triggerprice'] = gtt['triggerprice'] + ratio;
        gtt['price'] = gtt['price'] + ratio;
        gtt['transactiontype'] = "SELL";
        gtt['gttType'] = "OCO";
        gtt['qty'] = qty;

        // print("GTT=> $gtt");
        // break;

        final res = await AngelService().createGTT(gtt);
        print('OCO => $res');

        if (res.data["message"] == "SUCCESS") {
          _getData();
        } else {
          snackbar(res.data['message'].toString());
        }

        // break;
      }
    }

    setState(() {
      isPlacing[index] = false;
    });
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
    // final mediaQueryData = MediaQuery.of(context);
    // final statusBarHeight = mediaQueryData.padding.top;
    return Container(
      // padding: EdgeInsets.only(top: statusBarHeight),
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
    Color color = data['haveOCO'] ? Colors.green : Colors.white;
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
                          setState(() {
                            isPlacing[index] = true;
                          });
                          _createOCO(data, index);
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
          Text(data['symbolname'],
              style: TextStyle(fontSize: 18, color: color)),
          const Expanded(child: SizedBox()),
          SizedBox(
            width: 70,
            child: Text('B: ${data['netqty']}',
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
