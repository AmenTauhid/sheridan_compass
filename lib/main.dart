import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class IndoorNavigationApp extends StatelessWidget {
const IndoorNavigationApp({Key? key}) : super(key: key);

@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'Indoor Navigation App',
home: const IndoorNavigationMap(),
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
final Location _location = Location();

// List of LatLng objects to represent the location of each marker
final List<LatLng> _markers = [
LatLng(43.468523, -79.700456), // Marker 1
LatLng(43.468923, -79.700256), // Marker 2
LatLng(43.468323, -79.700656), // Marker 3
];

// Sample custom markers
List<CustomMarker> markers = [
CustomMarker(label: 'A', position: const Offset(50, 100)),
CustomMarker(label: 'B', position: const Offset(150, 200)),
CustomMarker(label: 'C', position: const Offset(250, 300)),
];

@override
Widget build(BuildContext context) {
return Scaffold(
body: InteractiveViewer(
boundaryMargin: EdgeInsets.all(20),
minScale: 0.1,
maxScale: 10,
child: Stack(
children: [
Image.asset(
'assets/B_building_F1.png',
fit: BoxFit.cover,
width: MediaQuery.of(context).size.width,
height: MediaQuery.of(context).size.height,
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
