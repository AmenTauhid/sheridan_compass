import 'dart:async';
import 'dart:math' as math;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
  double? _currentBearing;
  double _remainingDistance = 0;
  int _currentIndex = 0;
  String? _selectedStartingPoint;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSatelliteView = false;


  void _zoomIn() {
    final GoogleMapController? controller = _mapController;
    if (controller != null) {
      controller.animateCamera(CameraUpdate.zoomIn());
    }
  }

  void _zoomOut() {
    final GoogleMapController? controller = _mapController;
    if (controller != null) {
      controller.animateCamera(CameraUpdate.zoomOut());
    }
  }

  GoogleMapController? _mapController;

  Future<void> _onMapCreated(GoogleMapController controller) async {
    setState(() {
      _markers.clear();
    });
    _mapController = controller;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Prepare the arrow marker icon
  BitmapDescriptor? _arrowIcon;
  Future<void> _createArrowIcon() async {
    _arrowIcon = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(), 'assets/arrow.png');
  }

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
      if (_selectedBuilding != null) {
        _drawRoute(_userLocation!, _selectedBuilding!);
      }
    });
  }

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
      // _markers.add(Marker(
      //   markerId: const MarkerId("S_building"),
      //   position: _sBuilding,
      //   infoWindow: const InfoWindow(title: "S Building"),
      // ));
      if (destination != null)
      { // Check if destination is not null before adding the marker
        _markers.add(Marker(
          markerId: MarkerId(destinationBuildingId),
          position: destination,
          infoWindow: const InfoWindow(title: "Destination Building"),
        ));
      }
    });
  }
  Widget _buildDropdown() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          width: constraints.maxWidth,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            hint: const Text('  Select Destination'),
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
            ],
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedBuilding = newValue;
                });
                _updateMarkers(newValue);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildStartingPointDropdown() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          width: constraints.maxWidth,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            hint: const Text('  Select Starting Point'),
            value: _selectedStartingPoint,
            items: const [
              DropdownMenuItem<String>(
                value: 'current_location',
                child: Text('Current Location'),
              ),
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
            ],
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedStartingPoint = newValue;
                });
                _updateMarkers(newValue);}
            },
          ),
        );
      },
    );
  }

  LatLng _getBuildingCoordinates(String buildingId) {
    switch (buildingId) {
      case 'B_building':
        return const LatLng(43.468240, -79.700551);
      case 'C_building':
        return const LatLng(43.46835, -79.69906);
      case 'E_building':
        return const LatLng(43.468275, -79.699808);
      case 'J_building':
        return const LatLng(43.469594, -79.698922);
      case 'Residence_building':
        return const LatLng(43.46832, -79.69778);
      case 'G_building':
        return const LatLng(43.46698, -79.69984);
      case 'Child_care_center':
        return const LatLng(43.46753, -79.70167);
      case 'Athletic_center':
        return const LatLng(43.46769, -79.70306);
      default:
        throw Exception('Invalid building ID');
    }
  }

  Future<void> _drawRoute(LatLng userLocation, String destinationBuildingId) async {
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
      LatLng startingPoint = _selectedStartingPoint == 'current_location' ? userLocation : _getBuildingCoordinates(_selectedStartingPoint!);
      PolylineResult result = await _polylinePoints.getRouteBetweenCoordinates(
        // Add your Google Maps API key
        "AIzaSyBPB8AgsQbjJoS_-kIWlPbdI33wToci6aY",
        PointLatLng(startingPoint.latitude, startingPoint.longitude),
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

        // Update remaining distance
        _remainingDistance = 0;
        for (int i = 0; i < _polylineCoordinates.length - 1; i++) {
          _remainingDistance += _distanceBetweenPoints(
            _polylineCoordinates[i],
            _polylineCoordinates[i + 1],
          );
        }
        print("Remaining distance: ${_remainingDistance} meters");

        // Add travel history to Firebase
        await FirebaseFirestore.instance.collection('travel_history').add({
          'starting_point': _selectedStartingPoint,
          'destination': destinationBuildingId,
          'timestamp': Timestamp.now(),
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

  double _distanceBetweenPoints(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // Earth's radius in meters
    double lat1 = _degreeToRadian(point1.latitude);
    double lat2 = _degreeToRadian(point2.latitude);
    double dLat = _degreeToRadian(point2.latitude - point1.latitude);
    double dLng = _degreeToRadian(point2.longitude - point1.longitude);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreeToRadian(double degree) {
    return degree * pi / 180;
  }

  Widget _buildMapStyleButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1C355E),
        ),
        onPressed: () {
          setState(() {
            _isSatelliteView = !_isSatelliteView;
          });
          // Your existing onPressed code...
        },
        child: Text(_isSatelliteView ? 'Normal View' : 'Satellite View')
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
        // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),\
        rotation: currentLocation.heading!,
      ));
      _userLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);

      if (_selectedBuilding != null) {
        _drawRoute(_userLocation!, _selectedBuilding!);
      }
    });
  }
// Create a new function to fetch the travel history from Firebase
  Future<List<Map<String, dynamic>>> _fetchTravelHistory() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('travel_history').get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

// Create a new function to build the history list
  Widget _buildHistoryList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchTravelHistory(),
      builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text("From: ${snapshot.data![index]['starting_point']} To: ${snapshot.data![index]['destination']}"),
                subtitle: Text("Timestamp: ${snapshot.data![index]['timestamp'].toDate()}"),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1C355E),
          toolbarTextStyle: TextTheme(
            titleLarge: GoogleFonts.sourceSansPro(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).bodyMedium,
          titleTextStyle: TextTheme(
            titleLarge: GoogleFonts.sourceSansPro(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).titleLarge,
        ),
      ),
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Sheridan Compass'),
          centerTitle: true,
          elevation: 2,
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                _scaffoldKey.currentState!.openEndDrawer(); // Open the end drawer when the history button is pressed
              },
            ),
          ],
        ),
        endDrawer: Drawer(
          child: Column(
            children: [
              const SizedBox(height: 95),
              const Text(
                '🧭',
                style: TextStyle(
                  fontSize: 100,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'History',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
              Expanded(
                child: _buildHistoryList(),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: _sBuilding, zoom: 17, tilt: 45.0),
              mapType: _isSatelliteView ? MapType.satellite : MapType.normal,
              markers: _markers,
              polylines: _polylines,
              compassEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: _onMapCreated,
            ),
            Positioned(
              top: 10,
              left: 20,
              right: 20,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _buildStartingPointDropdown(),
              ),
            ),
            Positioned(
              top: 60,
              left: 20,
              right: 20,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _buildDropdown(),
              ),
            ),
            Positioned(
              left: 16, // Adjust position as needed
              bottom: 16, // Adjust position as needed
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    onPressed: _zoomIn,
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 6),
                  FloatingActionButton(
                    onPressed: _zoomOut,
                    child: const Icon(Icons.remove),
                  ),
                ],
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(height: 95),
                const Text(
                  '🧭',
                  style: TextStyle(
                    fontSize: 100,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Sheridan Compass',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'A Project By:\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('Ayman Tauhid,\nElias Alissandratos\nand Omar Al-Dulaimi'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isSatelliteView = !_isSatelliteView; // toggle the value
                    });
                  },
                  child: const Text('Switch View'),
                ),
                const Spacer(),
                const Text('Sheridan College'),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.save),
              label: 'Saved Trips',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}
