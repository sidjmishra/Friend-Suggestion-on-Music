import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:spotify_music_auth/services/auth.dart';

Future<void> main() async {
  Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Home());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
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
            title: "Play Connect",
            debugShowCheckedModeBanner: false,
            home: Center(
              child: Text(snapshot.error.toString()),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: "Play Connect",
            theme: ThemeData(
              primarySwatch: Colors.purple,
            ),
            debugShowCheckedModeBanner: false,
            home: AuthService().handleAuth(),
          );
        }
        return const CircularProgressIndicator(
          color: Colors.purple,
        );
      },
    );
  }
}
