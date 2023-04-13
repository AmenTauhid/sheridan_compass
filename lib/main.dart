import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  Set<Polyline> _polylines = {};
  late GoogleMapController _mapController;
  TextEditingController _searchController = TextEditingController();

  LatLng? _currentLocation;
  LatLng? _destination;

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    // Set initial camera position to Sheridan Trafalgar Campus
    List<geocoding.Location> locations =
    await geocoding.locationFromAddress("Sheridan Trafalgar Campus");
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
        _currentLocation = LatLng(location.latitude!, location.longitude!);
      });
    } else {
      // Handle case when location is not found
      print('Location not found');
    }
  }

  void _searchLocationByName(String locationName) async {
    List<geocoding.Location> locations =
    await geocoding.locationFromAddress(locationName);
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
        _destination = LatLng(location.latitude!, location.longitude!);
      });
    } else {
      // Handle case when location is not found
      print('Location not found');
    }
  }

  void _drawRoute(LatLng destination) async {
    // Clear existing polylines
    setState(() {
      _polylines.clear();
    });

    // Use Directions API to get the route
    String apiKey = "AIzaSyBPB8AgsQbjJoS_-kIWlPbdI33wToci6aY"; // Replace with your own Google Maps API key

    String baseUrl = "https://maps.googleapis.com/maps/api/directions/json?";
    String origin = "${_currentLocation!.latitude},${_currentLocation!.longitude}";
    String dest = "${_destination!.latitude},${_destination!.longitude}";
    String url = "$baseUrl" "origin=$origin" "&destination=$dest" "&key=$apiKey"; // Update URL construction
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Decode the response body
      var decodedData = json.decode(response.body);
      List<LatLng> routePoints = [];

      // Extract the route polyline points
      List steps = decodedData["routes"][0]["legs"][0]["steps"];
      for (var step in steps) {
        String points = step["polyline"]["points"];
        routePoints.addAll(decodePolyline(points));
      }

      // Draw the polyline on the map
      setState(() {
        Polyline polyline = Polyline(
          polylineId: PolylineId("route"),
          points: routePoints,
          color: Colors.blue,
          width: 4,
        );
        _polylines.add(polyline);
      });
    } else {
      // Handle error response
      print('Failed to fetch route');
    }
  }



  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0,
        len = encoded.length;
    int lat = 0,
        lng = 0;

    while (index < len) {
      int b,
          shift = 0,
          result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      LatLng point = LatLng(lat / 1E5, lng / 1E5);
      poly.add(point);
    }

    return poly;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Maps Demo')),
        body: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for location',
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
              ),
              onSubmitted: (value) {
                _searchLocationByName(value);
              },
            ),
            Expanded(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                polylines: _polylines,
                markers: Set<Marker>.of(_markers.values),
                initialCameraPosition: CameraPosition(
                  target: LatLng(43.5908, -79.6441),
                  // Initial camera position to Sheridan Trafalgar Campus
                  zoom: 17.0,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_currentLocation != null && _destination != null) {
                  _drawRoute(_destination!);
                } else {
                  print('Please select current location and destination');
                }
              },
              child: Text('Draw Route'),
            ),
          ],
        ),
      ),
    );
  }
}
