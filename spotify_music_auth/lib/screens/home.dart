import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  // final bool connected;
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play-Connect'),
        backgroundColor: Colors.grey[900],
      ),
      body: const Center(
        child: Text("Please! Login to your Remote Spotify App"),
      ),
    );
  }
}
