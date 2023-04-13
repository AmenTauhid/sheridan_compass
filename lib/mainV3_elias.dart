import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'src/locations.dart' as locations;

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

  Future<void> _onMapCreated(GoogleMapController controller) async {
    setState(() {
      _markers.clear();
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Sheridan Compass 🧭'),
          centerTitle: true,
          elevation: 2,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Locate',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(43.46843248599148, -79.70040205206587), // Oakville Campus coordinates
                  zoom: 17, // Adjust zoom level as needed
                ),
                markers: _markers.values.toSet(),
                mapType: MapType.satellite,
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Text(
                'S Compass',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Icon(Icons.explore),
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
              const Text('2023'),
              const SizedBox(height: 10),
            ],
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
              icon: Icon(Icons.bookmark),
              label: 'Saved Locations',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
