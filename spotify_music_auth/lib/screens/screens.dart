import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:spotify_music_auth/constants/constants.dart';
import 'package:spotify_music_auth/screens/activity.dart';
import 'package:spotify_music_auth/screens/chats/chatscreen.dart';
import 'package:spotify_music_auth/screens/explore.dart';
import 'package:spotify_music_auth/screens/home.dart' as home;
import 'package:spotify_music_auth/screens/player.dart';
import 'package:spotify_music_auth/screens/profile.dart';
import 'package:spotify_music_auth/services/auth.dart';
import 'package:spotify_music_auth/services/authenticate.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPage = 0;

  final List<Widget> pages = [
    const home.HomePage(),
    const Explore(),
    const Player(),
    const Activity(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentPage],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        unselectedItemColor: Colors.grey,
        selectedItemColor: kPrimaryColor,
        onTap: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: LineIcon(LineIcons.playCircleAlt),
            label: 'Play',
          ),
          BottomNavigationBarItem(
            icon: LineIcon(LineIcons.bellAlt),
            label: 'Activity',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
