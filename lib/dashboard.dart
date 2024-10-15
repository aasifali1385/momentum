import 'package:flutter/material.dart';
import 'package:momentum/executed.dart';
import 'package:momentum/statistic/statistic.dart';
import 'colors.dart';
import 'holding.dart';
import 'open.dart';
import 'scan.dart';
import 'charts.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 5;

  List<Widget> screens = [
    const Scan(),
    const Charts(),
    const Statistic(),
    const Open(),
    const Executed(),
    const Holding(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        backgroundColor: MyColors.backDark,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.document_scanner_outlined), label: "Scan"),
          BottomNavigationBarItem(
              icon: Icon(Icons.candlestick_chart_outlined), label: "Charts"),
          BottomNavigationBarItem(
              icon: Icon(Icons.calculate_outlined), label: "Statistic"),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_rounded), label: "Open"),
          BottomNavigationBarItem(
              icon: Icon(Icons.checklist_rtl_rounded), label: "Today"),
          BottomNavigationBarItem(
              icon: Icon(Icons.format_list_bulleted_rounded), label: "Holding"),
        ],
      ),
    );
  }
}
