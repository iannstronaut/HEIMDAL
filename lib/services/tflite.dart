import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

class FireDetector extends StatefulWidget {
  @override
  _FireDetectorState createState() => _FireDetectorState();
}

class _FireDetectorState extends State<FireDetector> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  String result = "";
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras![0], ResolutionPreset.medium);
    await _controller?.initialize();
    _controller?.startImageStream((image) {
      if (!isDetecting) {
        isDetecting = true;
        _runModelOnFrame(image);
      }
    });
  }

  Future<void> _loadModel() async {
    String? res = await Tflite.loadModel(
      model: "assets/models/FireDetection.tflite",
      labels: "assets/labels.txt", // You can create a labels file if needed
    );
    print(res);
  }

  Future<void> _runModelOnFrame(CameraImage image) async {
    // Convert CameraImage to appropriate format for TFLite
    var recognitions = await Tflite.runModelOnFrame(
      bytesList: image.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      imageHeight: image.height,
      imageWidth: image.width,
      numResults: 2,
      threshold: 0.6,
    );

    if (recognitions != null && recognitions.isNotEmpty) {
      setState(() {
        result =
            recognitions[0]['label'] == "fire" ? "Fire Detected!" : "No Fire!";
        isDetecting = false; // Reset the detection flag
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fire Detector"),
      ),
      body: Column(
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
          SizedBox(height: 20),
          Text(
            result,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
