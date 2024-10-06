import 'package:flutter/material.dart';
import 'package:momentum/statistic.dart';
import 'scan.dart';
import 'charts.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 1;

  List<Widget> screens = [
    const Scan(),
    const Charts(),
    const Statistic(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
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
              icon: Icon(Icons.list_alt_outlined), label: "Open"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Closed"),
        ],
      ),
    );
  }
}
