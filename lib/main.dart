import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

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

  void _updateMarkers(String destinationBuildingId) {
    LatLng? destination; // Declare destination as nullable
    switch (destinationBuildingId) {
      case 'B_building':
        destination = const LatLng(43.469596, -79.698068);
        break;
      case 'J_building':
        destination = const LatLng(43.46955, -79.69890);
        break;
      case 'C_building':
        destination = const LatLng(43.46835, -79.69906);
        break;
      case 'E_building':
        destination = const LatLng(43.46775, -79.69987);
        break;

      case 'Residence_building':
        destination = const LatLng(43.46832, -79.69778);
        break;
      case 'G_building':
        destination = const LatLng(43.46698, -79.69984);
        break;
      case 'Child_care_center':
        destination = const LatLng(43.46753, -79.70167);
        break;
      case 'Athletic_center':
        destination = const LatLng(43.46769, -79.70306);
        break;

    // Add more buildings with their respective coordinates here
    }

    setState(() {
      _markers.clear();
      _markers.add(Marker(
        markerId: const MarkerId("S_building"),
        position: _sBuilding,
        infoWindow: const InfoWindow(title: "S Building"),
      ));
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
    return DropdownButton<String>(
      hint: const Text('Select Destination Building'),
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
        DropdownMenuItem<String>(
          value: 'Residence_building',
          child: Text('Residence Building'),
        ),
        DropdownMenuItem<String>(
          value: 'G_building',
          child: Text('G Building'),
        ),
        DropdownMenuItem<String>(
          value: 'Child_care_center',
          child: Text('Child Care Center'),
        ),
        DropdownMenuItem<String>(
          value: 'Athletic_center',
          child: Text('Athletic Center'),
        ),

        // Add more buildings here
      ],
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedBuilding = newValue;
          });
          _updateMarkers(newValue);
          _drawRoute(newValue);
        }
      },
    );
  }

  Future<void> _drawRoute(String destinationBuildingId) async {
    LatLng? destination;
    switch (destinationBuildingId) {
      case 'B_building':
        destination = const LatLng(43.469596, -79.698068);
        break;
      case 'C_building':
        destination = const LatLng(43.46835, -79.69906);
        break;
      case 'E_building':
        destination = const LatLng(43.46775, -79.69987);
        break;
      case 'J_building':
        destination = const LatLng(43.46955, -79.69890);
        break;

      case 'Residence_building':
        destination = const LatLng(43.46832, -79.69778);
        break;
      case 'G_building':
        destination = const LatLng(43.46698, -79.69984);
        break;
      case 'Child_care_center':
        destination = const LatLng(43.46753, -79.70167);
        break;
      case 'Athletic_center':
        destination = const LatLng(43.46769, -79.70306);
        break;

    // Add more buildings with their respective coordinates here
    }

    if (destination != null) {
      PolylineResult result = await _polylinePoints.getRouteBetweenCoordinates(
        // Add your Google Maps API key
        "AIzaSyBPB8AgsQbjJoS_-kIWlPbdI33wToci6aY",
        PointLatLng(_sBuilding.latitude, _sBuilding.longitude),
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

  bool _isSatelliteView = false;

  Widget _buildMapStyleButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _isSatelliteView = !_isSatelliteView;
        });
      },
      child: Text(_isSatelliteView ? 'Normal View' : 'Satellite View'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Sheridan College Oakville Campus Navigation'),
        ),
        body: Column(
          children: [
            _buildDropdown(),
            _buildMapStyleButton(),
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
