import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

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

void main() {
  runApp(const IndoorNavigationApp());
}

class IndoorNavigationMap extends StatefulWidget {
  const IndoorNavigationMap({Key? key}) : super(key: key);

  @override
  _IndoorNavigationMapState createState() => _IndoorNavigationMapState();
}

class _IndoorNavigationMapState extends State<IndoorNavigationMap> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Center(
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.width / 1.35,
            child: PhotoView(
              imageProvider: AssetImage('assets/B_building_F1.png'),
              backgroundDecoration: const BoxDecoration(color: Colors.white),
              minScale: PhotoViewComputedScale.contained,
              maxScale: 10.0,
              initialScale: PhotoViewComputedScale.contained * 2,
            ),
          ),
        ),
      ),
    );
  }
}