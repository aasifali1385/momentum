import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../dio/angel_service.dart';
import 'package:momentum/component.dart';

class SymbolToken extends StatefulWidget {
  const SymbolToken({super.key});

  @override
  State<SymbolToken> createState() => _SymbolTokenState();
}

class _SymbolTokenState extends State<SymbolToken> {
  @override
  initState() {
    super.initState();
    _init();
  }

  late Box<dynamic> prefBox;
  late Box<dynamic> tokensBox;

  int tokens = 0;
  String date = '';

  void _init() async {
    prefBox = await Hive.openBox('pref');
    tokensBox = await Hive.openBox('symbolTokens');

    setState(() {
      date = prefBox.get('date', defaultValue: '');
      tokens = tokensBox.length;
    });

    // if (tokens == 0) fetchTokens();
  }

  bool isFetching = false;
  double progress = 0.0;

  void fetchTokens() async {
    setState(() {
      isFetching = true;
    });

    final res = await AngelService().getSymbolToken(
      (transfer, total) {
        setState(() {
          progress = transfer / total;
        });
      },
    );

    if (res == null) {
      setState(() {
        isFetching = false;
      });
      return;
    }

    var symbolToken = {};
    for (var ls in res.data) {
      if (ls['symbol'].toString().endsWith('-EQ')) {
        symbolToken[ls['symbol']] = ls['token'];
      }
    }

    await tokensBox.putAll(symbolToken);
    await prefBox.put(
        'date', DateFormat('dd MMM HH:mm a').format(DateTime.now()));

    setState(() {
      isFetching = false;
      date = prefBox.get('date', defaultValue: '');
      tokens = tokensBox.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: isFetching
              ? LinearProgressIndicator(
                  color: Colors.white,
                  value: progress,
                  backgroundColor: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 6,
                )
              : Text(
                  ' Updated on $date, ST:$tokens',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
        ),
        const SizedBox(width: 8),
        IconButton(
            onPressed: isFetching ? null : fetchTokens,
            style: IconButton.styleFrom(
                // backgroundColor: Colors.blue,
                // disabledBackgroundColor: Colors.blue,
                ),
            icon: isFetching
                ? progressCircle()
                : const Icon(
                    Icons.download_rounded,
                    color: Colors.white,
                  ))
      ],
    );
  }
}
