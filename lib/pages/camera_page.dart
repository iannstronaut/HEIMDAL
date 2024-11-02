import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:camera/camera.dart';

class FireDetectionPage extends StatefulWidget {
  @override
  _FireDetectionPageState createState() => _FireDetectionPageState();
}

class _FireDetectionPageState extends State<FireDetectionPage> {
  WebSocketChannel? channel;
  CameraController? cameraController;
  List<dynamic> predictions = [];

  @override
  void initState() {
    super.initState();
    initializeCamera();
    connectWebSocket();
  }

  void initializeCamera() async {
    final cameras = await availableCameras();
    cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await cameraController?.initialize();
    cameraController?.startImageStream((image) async {
      final yuvBytes = concatenatePlanes(image.planes);
      if (yuvBytes != null) {
        final frameData = json.encode({
          'width': image.width,
          'height': image.height,
          'yuvBytes': base64.encode(yuvBytes),
        });
        // Pastikan channel ada sebelum mengirim data
        if (channel != null) {
          channel?.sink.add(frameData);
        }
      }
    });
  }

  // Menggabungkan data dari plane gambar
  Uint8List concatenatePlanes(List<Plane> planes) {
    int totalBytes = 0;
    for (Plane plane in planes) {
      totalBytes += plane.bytes.length;
    }

    final allBytes = Uint8List(totalBytes);
    int offset = 0;
    for (Plane plane in planes) {
      allBytes.setRange(offset, offset + plane.bytes.length, plane.bytes);
      offset += plane.bytes.length;
    }
    return allBytes;
  }

  void connectWebSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse(
          'ws://192.168.106.179:8000/ws/detect'), // Ganti dengan IP server lokal
    );

    channel!.stream.listen((message) {
      setState(() {
        predictions = json.decode(message);
      });
    }, onError: (error) {
      print("WebSocket error: $error");
    }, onDone: () {
      print("WebSocket connection closed");
    });
  }

  @override
  void dispose() {
    cameraController?.dispose();
    channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Deteksi Kebakaran Hutan')),
      body: Stack(
        children: [
          cameraController == null
              ? Center(child: CircularProgressIndicator())
              : CameraPreview(cameraController!),
          // Menampilkan bounding box deteksi
          ...predictions.map((pred) {
            final box = pred['box'];
            return Positioned(
              left: box[0].toDouble(),
              top: box[1].toDouble(),
              child: Container(
                width: box[2].toDouble(),
                height: box[3].toDouble(),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: Text(
                  '${pred['label']} (${(pred['confidence'] * 100).toStringAsFixed(1)}%)',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
