import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'dart:convert';
import 'dart:io';

class FireDetectionPage extends StatefulWidget {
  @override
  _FireDetectionPageState createState() => _FireDetectionPageState();
}

class _FireDetectionPageState extends State<FireDetectionPage> {
  String? videoResultUrl;
  final ImagePicker _picker = ImagePicker();
  File? _videoFile;
  bool _isUploading = false;
  String _uploadStatus = '';

  Future<void> recordVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      setState(() {
        _videoFile = File(video.path);
      });
      await uploadVideo(video.path);
    }
  }

  Future<void> uploadVideo(String filePath) async {
    setState(() {
      _isUploading = true;
      _uploadStatus = 'Mengunggah video...';
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://192.168.78.48:8000/upload-video/'), // Pastikan alamat IP benar
      );

      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        setState(() {
          videoResultUrl =
              'http://192.168.78.48:8000' + jsonResponse['output_video_url'];
          _uploadStatus = 'Video berhasil diunggah';
        });
        
        // Panggil showResultVideo untuk langsung alihkan ke pemutar video
        showResultVideo();
      } else {
        setState(() {
          _uploadStatus =
              'Gagal mengunggah video: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _uploadStatus = 'Error mengunggah video: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void showResultVideo() {
    if (videoResultUrl != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(videoUrl: videoResultUrl!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deteksi Kebakaran Hutan'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: recordVideo,
              child: Text('Rekam Video'),
            ),
            SizedBox(height: 20),
            if (_videoFile != null) Text('Video direkam: ${_videoFile!.path}'),
            SizedBox(height: 20),
            if (_isUploading) CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(_uploadStatus),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  VideoPlayerScreen({required this.videoUrl});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse("http://192.168.78.48:8000/download-video/output_video.mp4"))
      ..initialize().then((_) {
        setState(() {
          _isLoading = false;
        });
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil Video'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying ? _controller.pause() : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
