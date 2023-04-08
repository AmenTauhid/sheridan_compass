import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class IndoorNavigationApp extends StatelessWidget {
  const IndoorNavigationApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Indoor Navigation App',
      home: IndoorNavigationMap(),
    );
  }
}

void main() {
  runApp(const IndoorNavigationApp());
}

class CustomMarker {
  late final String label;
  late final Offset position;

  CustomMarker({required this.label, required this.position});
}

class IndoorNavigationMap extends StatefulWidget {
  const IndoorNavigationMap({Key? key}) : super(key: key);

  @override
  _IndoorNavigationMapState createState() => _IndoorNavigationMapState();
}

class _IndoorNavigationMapState extends State<IndoorNavigationMap> {
  List<CustomMarker> markers = [
    CustomMarker(label: 'A', position: const Offset(50, 100)),
    CustomMarker(label: 'B', position: const Offset(150, 200)),
    CustomMarker(label: 'C', position: const Offset(250, 300)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoView.customChild(
        backgroundDecoration: const BoxDecoration(color: Colors.white),
        minScale: PhotoViewComputedScale.contained,
        maxScale: 10.0,
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 1.35, // Replace with the correct aspect ratio for your image
              child: FittedBox(
                fit: BoxFit.cover,
                child: Image.asset(
                  'assets/B_building_F1.png',
                ),
              ),
            ),
            ...markers.map((marker) => _buildMarker(marker)),
          ],
        ),
      ),
    );
  }

  Widget _buildMarker(CustomMarker marker) {
    return Positioned(
      left: marker.position.dx,
      top: marker.position.dy,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          marker.label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}