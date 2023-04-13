import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';

void main() {
  runApp(const CampusMapPage());
}

class CampusMapPage extends StatefulWidget {
  const CampusMapPage({super.key});

  @override
  _CampusMapPageState createState() => _CampusMapPageState();
}

class _CampusMapPageState extends State<CampusMapPage> {
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final LatLng _sBuilding = const LatLng(43.468963, -79.699594);
  String? _selectedBuilding;
  final List<LatLng> _polylineCoordinates = [];
  final PolylinePoints _polylinePoints = PolylinePoints();
  final Location _location = Location();
  late StreamSubscription<LocationData> _locationSubscription;
  LatLng? _userLocation;

  void _initLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationSubscription = _location.onLocationChanged.listen((LocationData currentLocation) {
      _updateUserLocation(currentLocation);
      // Use the currentLocation to update the position of the user on the map and recalculate the route
    });
  }

  void _updateMarkers(String destinationBuildingId) {
    LatLng? destination; // Declare destination as nullable
    switch (destinationBuildingId) {
      case 'B_building':
        destination = const LatLng(43.468240, -79.700551);
        break;
      case 'J_building':
        destination = const LatLng(43.469594, -79.698922);
        break;
      case 'C_building':
        destination = const LatLng(43.46835, -79.69906);
        break;
      case 'E_building':
        destination = const LatLng(43.468275, -79.699808);
        break;
        // Add more buildings with their respective coordinates here
    }

    setState(() {
      _markers.clear();
      // _markers.add(Marker(
      //   markerId: const MarkerId("S_building"),
      //   position: _sBuilding,
      //   infoWindow: const InfoWindow(title: "S Building"),
      // ));
      if (destination != null) { // Check if destination is not null before adding the marker
        _markers.add(Marker(
          markerId: MarkerId(destinationBuildingId),
          position: destination,
          infoWindow: const InfoWindow(title: "Destination Building"),
        ));
      }
    });
  }

  Widget _buildDropdown() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
        ),
        child: DropdownButton<String>(
          underline: const SizedBox(), // Remove underline
          isExpanded: true,
          hint: const Text(
            'Select Destination Building',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          value: _selectedBuilding,
          items: const [
            DropdownMenuItem<String>(
              value: 'B_building',
              child: Text('B Building'),
            ),
            DropdownMenuItem<String>(
              value: 'C_building',
              child: Text('C Building'),
            ),
            DropdownMenuItem<String>(
              value: 'E_building',
              child: Text('E Building'),
            ),
            DropdownMenuItem<String>(
              value: 'J_building',
              child: Text('J Building'),
            ),
            // Add more buildings here
          ],
          onChanged: (String? newValue) {
            if (newValue != null && _userLocation != null) {
              setState(() {
                _selectedBuilding = newValue;
              });
              _updateMarkers(newValue);
              _drawRoute(_userLocation!, newValue);
            }
          },
        )
    );
  }

  Future<void> _drawRoute(LatLng userLocation, String destinationBuildingId) async {
    LatLng? destination;
    switch (destinationBuildingId) {
      case 'B_building':
        destination = const LatLng(43.468240, -79.700551);
        break;
      case 'C_building':
        destination = const LatLng(43.46835, -79.69906);
        break;
      case 'E_building':
        destination = const LatLng(43.468275, -79.699808);
        break;
      case 'J_building':
        destination = const LatLng(43.469594, -79.698922);
        break;
    // Add more buildings with their respective coordinates here
    }

    if (destination != null) {
      PolylineResult result = await _polylinePoints.getRouteBetweenCoordinates(
        // Add your Google Maps API key
        "AIzaSyBPB8AgsQbjJoS_-kIWlPbdI33wToci6aY",
        PointLatLng(userLocation.latitude, userLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude),
        travelMode: TravelMode.walking,
      );

      if (result.points.isNotEmpty) {
        _polylineCoordinates.clear();
        setState(() {
          for (var point in result.points) {
            _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
        });

        setState(() {
          Polyline polyline = Polyline(
            polylineId: const PolylineId("route"),
            color: Colors.red,
            points: _polylineCoordinates,
            width: 3,
          );
          _polylines.add(polyline);
        });
      } else {
        if (kDebugMode) {
          print("Error: No points received.");
        }
      }
    } else {
      if (kDebugMode) {
        print("Error: Destination not found.");
      }
    }
  }


  final bool _isSatelliteView = false;

  Widget _buildMapStyleButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1C355E),
      ),
      onPressed: () {
        // Your existing onPressed code...
      },
      child: Text(
        _isSatelliteView ? 'Normal View' : 'Satellite View',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _locationSubscription.cancel();
    super.dispose();
  }

  void _updateUserLocation(LocationData currentLocation) {
    setState(() {
      // Remove the existing user_location marker before adding a new one
      _markers.removeWhere((marker) => marker.markerId == const MarkerId("user_location"));
      _markers.add(Marker(
        markerId: const MarkerId("user_location"),
        position: LatLng(currentLocation.latitude!, currentLocation.longitude!),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
      _userLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1C355E), toolbarTextStyle: TextTheme(
            titleLarge: GoogleFonts.sourceSansPro(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).bodyMedium, titleTextStyle: TextTheme(
            titleLarge: GoogleFonts.sourceSansPro(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).titleLarge,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Sheridan Compass 🧭'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildDropdown(),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildMapStyleButton(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: _sBuilding, zoom: 17, tilt: 45.0),
                mapType: _isSatelliteView ? MapType.satellite : MapType.normal,
                markers: _markers,
                polylines: _polylines,
                onMapCreated: (GoogleMapController controller) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
