import 'package:flutter/material.dart';
import 'package:spotify_music_auth/services/spotifyauth.dart';

Future<void> main() async {
  runApp(const Home());
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SpotifyUser(),
    );
  }
}
