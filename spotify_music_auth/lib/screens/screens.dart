import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:spotify_music_auth/constants/constants.dart';
import 'package:spotify_music_auth/screens/activity.dart';
import 'package:spotify_music_auth/screens/upload.dart';
import 'package:spotify_music_auth/screens/home.dart';
import 'package:spotify_music_auth/screens/player.dart';
import 'package:spotify_music_auth/screens/profile.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentPage = 0;

  final List<Widget> pages = [
    const HomePage(),
    const Player(),
    const Upload(),
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
          BottomNavigationBarItem(
            icon: LineIcon(LineIcons.playCircleAlt),
            label: 'Play',
          ),
          BottomNavigationBarItem(
            icon: LineIcon(LineIcons.plusCircle),
            label: 'Add Posts',
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