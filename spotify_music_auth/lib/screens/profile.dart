import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:spotify_music_auth/constants/constants.dart';
import 'package:spotify_music_auth/services/auth.dart';
import 'package:spotify_music_auth/services/authenticate.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Play-Connect'),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: LineIcon(LineIcons.alternateSignOut, color: Colors.white),
            tooltip: "Logout",
            onPressed: () {
              AuthService().signOut().then((value) => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Authenticate())));
            },
          ),
        ],
      ),
      body: const Text("Profile"),
    );
  }
}
