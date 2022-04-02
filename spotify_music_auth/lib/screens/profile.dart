import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:spotify_music_auth/constants/constants.dart';
import 'package:spotify_music_auth/services/auth.dart';
import 'package:spotify_music_auth/services/authenticate.dart';
import 'package:spotify_music_auth/services/database.dart';

class Profile extends StatefulWidget {
  final String profileId;
  const Profile({required this.profileId, Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = Constants.uid;
  bool isFollowing = false;
  String postOrientation = 'list';
  bool isLoading = false;
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  // List<Post> posts = [];

  getStatus() {
    setState(() {
      isFollowing =
          Database().checkIfFollowing(widget.profileId, currentUserId);
      followerCount = Database().getFollowers(widget.profileId);
      followingCount = Database().getFollowing(widget.profileId);
    });
  }

  getPosts() {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot snapshot = FirebaseFirestore.instance
        .collection('User Posts')
        .doc(widget.profileId)
        .collection('pictures')
        .orderBy('timestamp', descending: true)
        .get() as QuerySnapshot<Object?>;

    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      print(postCount);
      // posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  @override
  void initState() {
    // getPosts();
    super.initState();
  }

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
