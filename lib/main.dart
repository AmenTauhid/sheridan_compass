import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

void main() {
  runApp(const IndoorNavigationApp());
}
class CustomMarker{
  late final String label;
  late final Offset position;

  CustomMarker({ required this.label, required this.position});

}
class IndoorNavigationApp extends StatelessWidget {
  const IndoorNavigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Indoor Navigation')),
        body: const IndoorNavigationMap(),
      ),
    );
  }
}

class IndoorNavigationMap extends StatefulWidget {
  const IndoorNavigationMap({super.key});

  @override
  _IndoorNavigationMapState createState() => _IndoorNavigationMapState();
}

/*
class _IndoorNavigationMapState extends State<IndoorNavigationMap> {
  Location _location = Location();

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(51.5074, -0.1278), // Replace with your initial coordinates
        zoom: 18.0,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
      ],
    );
  }
}
*/
class _IndoorNavigationMapState extends State<IndoorNavigationMap> {
  // Sample custom markers
  List<CustomMarker> markers = [
    CustomMarker(label: 'A', position: const Offset(50, 100)),
    CustomMarker(label: 'B', position: const Offset(150, 200)),
    CustomMarker(label: 'C', position: const Offset(250, 300)),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset('assets/B_building_F1.png', fit: BoxFit.cover),
        ...markers.map((marker) => _buildMarker(marker)),
      ],
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
