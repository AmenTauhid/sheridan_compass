import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Map<String, Marker> _markers = {};
  int _currentIndex = 0;
  String? _selectedBuilding;

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
                value: 'A_building',
                child: Text('  A Wing'),
              ),
              DropdownMenuItem<String>(
                value: 'B_building',
                child: Text('  B Wing'),
              ),
              DropdownMenuItem<String>(
                value: 'C_building',
                child: Text('  C Wing'),
              ),
            ],
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedBuilding = newValue;
                });
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          primaryColorDark: Colors.blue[900],
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Sheridan Compass'),
          centerTitle: true,
          elevation: 2,
        ),
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(43.46843248599148, -79.70040205206587), // Oakville Campus coordinates
                zoom: 17, // Adjust zoom level as needed
              ),
              markers: _markers.values.toSet(),
              mapType: MapType.satellite,
              zoomControlsEnabled: false, // Disable default zoom controls
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
            Positioned(
              right: 16, // Adjust position as needed
              bottom: 16, // Adjust position as needed
              child: ClipOval(
                child: ElevatedButton(
                  onPressed: () {
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(0), // Remove padding
                    minimumSize: const Size(100, 100), // Set minimum size
                    shape: const CircleBorder(),
                    primary: Colors.green,// Set circular shape
                  ),
                  child: const Text(
                    'Start Trip',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold, // Set font weight to bold
                      color: Colors.white, // Set font color to white
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: Container(
            color: Colors.white,
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
                  'Sheridan Compass',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('About'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Settings'),
                ),
                const Spacer(),
                const Text('Ayman, Elias, & Omar'),
                const Text('April, 2023'),
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

