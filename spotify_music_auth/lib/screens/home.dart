import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final bool connected;
  const HomePage({required this.connected, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play-Connect'),
        backgroundColor: Colors.grey[900],
      ),
      body: Center(
        child: connected
            ? const Text("Connected Successfully")
            : const Text("Please! Login to your Remote Spotify App"),
      ),
    );
  }
}
