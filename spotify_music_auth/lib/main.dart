import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:spotify_music_auth/services/auth.dart';
import 'package:spotify_music_auth/services/spotifyauth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Home());
}

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Center(
              child: Text(snapshot.error.toString()),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            theme: ThemeData(
              primarySwatch: Colors.indigo,
            ),
            debugShowCheckedModeBanner: false,
            home: AuthService().handleAuth(),
          );
        }
        return const CircularProgressIndicator(
          color: Colors.green,
        );
      },
    );
  }
}
