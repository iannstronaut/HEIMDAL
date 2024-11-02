import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class YoloScannerPage extends StatefulWidget {
  @override
  _YoloScannerPageState createState() => _YoloScannerPageState();
}

class _YoloScannerPageState extends State<YoloScannerPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late Interpreter _interpreter;
  List<CameraDescription> cameras = [];
  bool isDetecting = false;
  List<dynamic> detections = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _controller = CameraController(
        cameras[0], // Use the first available camera
        ResolutionPreset.high,
      );
      _initializeControllerFuture = _controller.initialize();
      await _initializeControllerFuture;

      // Start the image stream after the camera is initialized
      _controller.startImageStream((CameraImage image) {
        if (!isDetecting) {
          isDetecting = true;
          _runModel(image);
        }
      });
    } else {
      // Handle the case when no cameras are available
      print("No cameras available");
    }
  }

  Future<void> _loadModel() async {
    _interpreter =
        await Interpreter.fromAsset('assets/models/yolo_wildfire16.tflite');
  }

  void _runModel(CameraImage image) async {
    // Convert CameraImage to a format suitable for the model
    var inputImage = _preprocessImage(image);

    // Prepare output buffer
    var output = List.filled(1 * 10 * 4, 0)
        .reshape([1, 10, 4]); // Adjust shape based on your model
    _interpreter.run(inputImage, output);

    // Process output
    setState(() {
      detections = output; // Store detections for rendering
      isDetecting = false; // Reset detecting flag
    });
  }

  List<List<int>> _preprocessImage(CameraImage image) {
    // Convert CameraImage to a format suitable for the model
    // Resize and normalize the image
    // This is a placeholder; implement your resizing logic here
    return []; // Return the processed image data
  }

  @override
  void dispose() {
    _controller.dispose();
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Real-Time YOLO Scanner')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                ..._buildDetectionBoxes(),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  List<Widget> _buildDetectionBoxes() {
    // Create bounding boxes for detected objects
    return detections.map((detection) {
      // Extract bounding box coordinates and draw them
      return Positioned(
        left: detection[0] * MediaQuery.of(context).size.width,
        top: detection[1] * MediaQuery.of(context).size.height,
        width: detection[2] * MediaQuery.of(context).size.width,
        height: detection[3] * MediaQuery.of(context).size.height,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red),
          ),
        ),
      );
    }).toList();
  }
}
