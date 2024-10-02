import 'package:flutter/material.dart';

class Chart extends StatefulWidget {
  const Chart({super.key});

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(itemCount: 13, itemBuilder: item),
          ),
        ],
      ),
    );
  }
}

Widget item(context, index) {
  return Stack(
    children: [
      Row(
        children: [
         Image.network('https://dfstudio-d420.kxcdn.com/wordpress/wp-content/uploads/2019/06/digital_camera_photo-1080x675.jpg'),
          Checkbox(value: false, onChanged: (checked) {})
        ],
      ),
    ],
  );
}
