import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sheridan Campus Navigation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CampusMap(),
    );
  }
}

class CampusMap extends StatefulWidget {
  const CampusMap({super.key});

  @override
  _CampusMapState createState() => _CampusMapState();
}

class _CampusMapState extends State<CampusMap> {
  final LatLng _sheridanTrafalgarCampus = const LatLng(43.468642, -79.698942);

  late GoogleMapController _mapController;
  late Location _location;
  LocationData? _currentLocation;

  @override
  void initState() {
    super.initState();
    _location = Location();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentLocation = await _location.getLocation();
      _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        zoom: 15.0,
      )));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text('Sheridan Campus Navigation'),
    ),
    body: GoogleMap(
    onMapCreated: _onMapCreated,
    initialCameraPosition: CameraPosition(
    target: _sheridanTrafalgarCampus,
    zoom: 15.0,
    ),
    myLocationEnabled: true,
    myLocationButtonEnabled: true,
    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        tooltip: 'Current Location',
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
