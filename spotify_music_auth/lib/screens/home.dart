// ignore_for_file: avoid_print, unused_field, prefer_final_fields
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:spotify_music_auth/components/post.dart';
import 'package:spotify_music_auth/constants/constants.dart';
import 'package:spotify_music_auth/constants/helper.dart';
import 'package:spotify_music_auth/screens/chats/chatscreen.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Post> posts = [];

  getUserInfo() async {
    HelperFunction.getUserUidSharedPreference().then((value) {
      setState(() {
        Constants.uid = value!.toString();
      });
      print(Constants.uid);
    });

    HelperFunction.getUserDisplaySharedPreference().then((value) {
      setState(() {
        Constants.displayName = value!.toString();
      });
      print(Constants.displayName);
    });

    HelperFunction.getUserNameSharedPreference().then((value) {
      setState(() {
        Constants.userName = value!.toString();
      });
      print(Constants.userName);
    });

    HelperFunction.getUserPhotoUrlSharedPreference().then((value) {
      setState(() {
        Constants.photoUrl = value.toString();
      });
      print(Constants.photoUrl);
    });
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Play-Connect',
          style: GoogleFonts.openSans(),
        ),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: LineIcon(LineIcons.rocketChat, color: Colors.white),
            tooltip: "Messages",
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()));
            },
          ),
        ],
      ),
      body: postList(),
    );
  }

  Widget postList() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Posts")
            .orderBy("timeStamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text(
                "No Posts Yet!",
                style: GoogleFonts.openSans(),
              ),
            );
          } else {
            posts = snapshot.data!.docs
                .map((doc) => Post.fromDocument(doc))
                .toList();
            return ListView(
              children: posts,
            );
          }
        });
  }
}
