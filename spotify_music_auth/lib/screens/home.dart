import 'package:flutter/material.dart';
import 'package:spotify_music_auth/constants/constants.dart';
import 'package:spotify_music_auth/services/auth.dart';
import 'package:spotify_music_auth/services/authenticate.dart';

class HomePage extends StatelessWidget {
  // final bool connected;
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play-Connect'),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () {
                AuthService().signOut().then((value) =>
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Authenticate())));
              }),
        ],
      ),
      body: const Center(
        child: Text("Please! Login to your Remote Spotify App"),
      ),
    );
  }
}
