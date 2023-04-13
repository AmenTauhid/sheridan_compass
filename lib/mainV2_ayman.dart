import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

class Building {
  final String name;
  final LatLng coordinates;

  Building(this.name, this.coordinates);
}

List<Building> _campusBuildings = [
  Building('Building A', const LatLng(43.469030, -79.698356)),
  Building('Building B', const LatLng(43.468429, -79.699355)),
  Building('Building C', const LatLng(43.468122, -79.698150)),
  // Add more buildings and their coordinates here
];

class CampusMap extends StatefulWidget {
  const CampusMap({super.key});

  @override
  _CampusMapState createState() => _CampusMapState();
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class _CampusMapState extends State<CampusMap> {
  final LatLng _sheridanTrafalgarCampus = const LatLng(43.468642, -79.698942);

  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _createBuildingMarkers();
  }

  void _createBuildingMarkers() {
    for (var building in _campusBuildings) {
      _markers.add(Marker(
        markerId: MarkerId(building.name),
        position: building.coordinates,
        infoWindow: InfoWindow(title: building.name),
      ));
    }
  }

  final TextEditingController _searchController = TextEditingController();

  late List<Building> _filteredBuildings = _campusBuildings;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    // Add building markers
    for (final building in _campusBuildings) {
      _markers.add(
        Marker(
          markerId: MarkerId(building.name),
          position: building.coordinates,
          infoWindow: InfoWindow(title: building.name),
        ),
      );
    }

    // Add the starting point marker
    _markers.add(
      Marker(
        markerId: const MarkerId('starting_point'),
        position: _startingPoint,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Starting Point'),
      ),
    );

    setState(() {});
  }


  bool _isListExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                minHeight: 80.0,
                maxHeight: 120.0,
                child: Container(
                  color: const Color(0xFF00205B), // Sheridan College Bruins blue
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search buildings',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        suffixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filteredBuildings = _campusBuildings
                              .where((building) => building.name
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                  ),
                ),
              ),
              pinned: true,
            ),
          ];
        },

        body: Column(
          children: [
            ExpansionPanelList(
              elevation: 1,
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  _isListExpanded = !isExpanded;
                });
              },
              expandedHeaderPadding: const EdgeInsets.all(0),
              children: [
                ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return const ListTile(
                      title: Text('Building List'),
                    );
                  },
                  body: SizedBox(
                    height: 200, // Set a fixed height for the expanded list
                    child: ListView.builder(
                      itemCount: _filteredBuildings.length,
                      itemBuilder: (context, index) {
                        Building building = _filteredBuildings[index];
                        return ListTile(
                          title: Text(building.name),
                          onTap: () async {
                            _mapController.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: building.coordinates,
                                  zoom: 19.0,
                                ),
                              ),
                            );
                            Future<List<LatLng>> _getRoutePoints(LatLng start, LatLng end) async {
                              // This is a simple straight-line calculation and not a proper navigation route.
                              // Replace this with a more accurate navigation solution if needed.
                              return [start, end];
                            }
                            // Draw a polyline from the starting point to the destination building
                            List<LatLng> routePoints = await _getRoutePoints(_startingPoint, building.coordinates);
                            setState(() {
                              _polylines.add(
                                Polyline(
                                  polylineId: _routePolylineId,
                                  points: routePoints,
                                  color: Colors.blue,
                                  width: 5,
                                ),
                              );
                            });
                          },
                        );
                      },
                    ),
                  ),
                  isExpanded: _isListExpanded,
                ),
              ],
            ),
            Expanded(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _sheridanTrafalgarCampus,
                  zoom: 17.0,
                ),
                markers: _markers,
                polylines: _polylines,
              ),
            ),
          ],
        ),
      ),
    );
  }
  final LatLng _startingPoint = const LatLng(43.4693, -79.6984); // Example starting point within the campus
  final Set<Polyline> _polylines = <Polyline>{};
  final PolylineId _routePolylineId = const PolylineId('route');
}
