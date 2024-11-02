import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:heimdal/pages/maps_api_handler.dart';
import 'package:camera/camera.dart';

const apiKey = "Ac6IGn7Q4e7Vgn7vhsYY";
const styleUrl = "https://api.maptiler.com/maps/satellite/style.json";

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Map();
  }
}

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State createState() => MapState();
}

class MapState extends State<Map> {
  late MapLibreMapController mapController;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchAndAddMarkers();
  }

  void _onMapCreated(MapLibreMapController controller) {
    mapController = controller;
  }

  Future<void> _fetchAndAddMarkers() async {
    final coordinates = await apiService.fetchCoordinates();

    for (var coordinate in coordinates) {
      final latitude = coordinate['latitude'];
      final longitude = coordinate['longitude'];

      mapController.addSymbol(
        SymbolOptions(
          geometry: LatLng(latitude, longitude),
          iconSize: 1.5,
          iconImage: "assets/icons/ic_fire.png",
        ),
      );
    }
  }

  // Method untuk membuka kamera dan merekam video
  Future<void> _recordVideo() async {
    // Mendapatkan daftar kamera
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    // Membuka halaman rekaman video
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoRecorder(camera: firstCamera),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapLibreMap(
        onMapCreated: _onMapCreated,
        styleString: "$styleUrl?key=$apiKey",
        myLocationEnabled: true,
        initialCameraPosition:
            const CameraPosition(target: LatLng(5.0, 125.0), zoom: 2.0),
        trackCameraPosition: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _recordVideo,
        tooltip: 'Record Video',
        child: const Icon(Icons.videocam),
      ),
    );
  }
}

// Halaman untuk merekam video
class VideoRecorder extends StatelessWidget {
  final CameraDescription camera;

  const VideoRecorder({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Video')),
      body: const Center(
          child: Text('Video recording feature to be implemented here')),
    );
  }
}