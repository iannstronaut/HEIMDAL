import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

class YoloDetectionPage extends StatefulWidget {
  @override
  _YoloDetectionPageState createState() => _YoloDetectionPageState();
}

class _YoloDetectionPageState extends State<YoloDetectionPage> {
  CameraController? _cameraController;
  List<dynamic>? _recognitions;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    loadModel();
    initCamera();
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: "assets/models/yolo_wildfire16.tflite",
      labels: "assets/models/labels.txt",
    );
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);

    await _cameraController!.initialize();
    _cameraController!.startImageStream((image) {
      if (!_isDetecting) {
        _isDetecting = true;
        runModelOnFrame(image);
      }
    });
    setState(() {});
  }

  Future<void> runModelOnFrame(CameraImage image) async {
    final recognitions = await Tflite.detectObjectOnFrame(
      bytesList: image.planes.map((plane) => plane.bytes).toList(),
      model: "YOLO",
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 0.0,
      imageStd: 255.0,
      numResultsPerClass: 1,
      threshold: 0.5,
    );
    setState(() {
      _recognitions = recognitions;
      _isDetecting = false;
    });
  }

  @override
  void dispose() {
    Tflite.close();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("YOLO Detection")),
      body: _cameraController == null || !_cameraController!.value.isInitialized
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                CameraPreview(_cameraController!),
                _recognitions != null
                    ? Stack(
                        children: _recognitions!.map((rec) {
                          return Positioned(
                            left: rec["rect"]["x"] *
                                MediaQuery.of(context).size.width,
                            top: rec["rect"]["y"] *
                                MediaQuery.of(context).size.height,
                            width: rec["rect"]["w"] *
                                MediaQuery.of(context).size.width,
                            height: rec["rect"]["h"] *
                                MediaQuery.of(context).size.height,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red, width: 3),
                              ),
                              child: Text(
                                "${rec["detectedClass"]} ${(rec["confidenceInClass"] * 100).toStringAsFixed(0)}%",
                                style: TextStyle(
                                  backgroundColor: Colors.red,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    : Container(),
              ],
            ),
    );
  }
}
