import 'package:flutter/material.dart';
import 'package:spotify_music_auth/constants/constants.dart';

class Explore extends StatefulWidget {
  const Explore({Key? key}) : super(key: key);

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play-Connect'),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
      ),
      body: const Text("Explore"),
    );
  }
}
