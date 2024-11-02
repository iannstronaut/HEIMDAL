import 'package:flutter/material.dart';
import 'package:heimdal/pages/camera_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yolo Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: YoloScannerPage(),
    );
  }
}