import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

void main() {
  runApp(const IndoorNavigationApp());
}

class IndoorNavigationApp extends StatelessWidget {
  const IndoorNavigationApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Indoor Navigation App',
      home: IndoorNavigationMap(),
    );
  }
}

class IndoorNavigationMap extends StatefulWidget {
  const IndoorNavigationMap({Key? key}) : super(key: key);

  @override
  _IndoorNavigationMapState createState() => _IndoorNavigationMapState();
}

class _IndoorNavigationMapState extends State<IndoorNavigationMap> {
  int _selectedIndex = 0;
  String _searchTerm = '';

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _performSearch(String query) {
    // Implement your search logic here
    print('Searching for $query');
    setState(() {
      _searchTerm = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: Center(
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.width / 1.35,
                child: PhotoView(
                  imageProvider: AssetImage('assets/B_building_F1.png'),
                  backgroundDecoration:
                  const BoxDecoration(color: Colors.white),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: 10.0,
                  initialScale: PhotoViewComputedScale.contained * 2,
                ),
              ),
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
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Location',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchTerm = value;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _performSearch(_searchTerm);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 7,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.blue,
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.black,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.location_history,
                  color: _selectedIndex == 0 ? Colors.white : Colors.black,
                ),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.save,
                  color: _selectedIndex == 1 ? Colors.white : Colors.black,
                ),
                label: 'Saved Locations',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.settings,
                  color: _selectedIndex == 2 ? Colors.white : Colors.black,
                ),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}