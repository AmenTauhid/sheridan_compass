import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Map<String, Marker> _markers = {};
  late GoogleMapController _mapController;
  TextEditingController _searchController = TextEditingController();

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    // Set initial camera position to Sheridan Trafalgar Campus
    List<geocoding.Location> locations = await geocoding.locationFromAddress("Sheridan Trafalgar Campus");
    if (locations.isNotEmpty) {
      geocoding.Location location = locations.first;
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(location.latitude!, location.longitude!),
            zoom: 17.0,
          ),
        ),
      );
      setState(() {
        _markers.clear();
        final marker = Marker(
          markerId: MarkerId("Sheridan Trafalgar Campus"),
          position: LatLng(location.latitude!, location.longitude!),
          infoWindow: InfoWindow(
            title: "Sheridan Trafalgar Campus",
            snippet: '${location.latitude}, ${location.longitude}',
          ),
        );
        _markers["Sheridan Trafalgar Campus"] = marker;
      });
    } else {
      // Handle case when location is not found
      print('Location not found');
    }
  }

  void _searchLocationByName(String locationName) async {
    List<geocoding.Location> locations = await geocoding.locationFromAddress(locationName);
    if (locations.isNotEmpty) {
      geocoding.Location location = locations.first;
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(location.latitude!, location.longitude!),
            zoom: 17.0,
          ),
        ),
      );
      setState(() {
        _markers.clear();
        final marker = Marker(
          markerId: MarkerId(locationName),
          position: LatLng(location.latitude!, location.longitude!),
          infoWindow: InfoWindow(
            title: locationName,
            snippet: '${location.latitude}, ${location.longitude}',
          ),
        );
        _markers[locationName] = marker;
      });
    } else {
      // Handle case when location is not found
      print('Location not found');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green[700],
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Location Search'),
          elevation: 2,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  // Trigger search on text change
                  _searchLocationByName(value);
                },
                decoration: InputDecoration(
                  labelText: 'Search by Location Name',
                ),
              ),
            ),
            Expanded(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 17,
                ),
                mapType: MapType.satellite, // Use satellite map type
                tiltGesturesEnabled: true,
                myLocationEnabled: true,
                mapToolbarEnabled: true,
                buildingsEnabled: true,
                indoorViewEnabled: true,
                markers: _markers.values.toSet(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
