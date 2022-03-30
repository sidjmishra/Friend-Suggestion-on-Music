import 'package:flutter/material.dart';
import 'package:spotify_music_auth/constants/constants.dart';

class Player extends StatefulWidget {
  const Player({Key? key}) : super(key: key);

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play-Connect'),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
      ),
      body: const Text("Player"),
    );
  }
}
