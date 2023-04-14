import 'package:flutter/material.dart';

class StartTrip extends StatelessWidget {
  const StartTrip({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start Trip'),
      ),
      body: Center(
        child: Text(
          'Welcome to the Start Trip Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
