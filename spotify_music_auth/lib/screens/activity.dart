import 'package:flutter/material.dart';
import 'package:spotify_music_auth/constants/constants.dart';

class Activity extends StatefulWidget {
  const Activity({Key? key}) : super(key: key);

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play-Connect'),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
      ),
      body: const Text("Activity"),
    );
  }
}
