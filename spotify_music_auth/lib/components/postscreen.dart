// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spotify_music_auth/components/post.dart';
import 'package:spotify_music_auth/constants/constants.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;

  const PostScreen({Key? key, required this.userId, required this.postId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(postId);
    print(userId);

    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection("User Posts")
          .doc(userId)
          .collection('pictures')
          .doc(postId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        Post post = Post.fromDocument(snapshot.data as DocumentSnapshot);
        return Center(
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                post.caption,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              backgroundColor: kPrimaryColor,
            ),
            body: ListView(
              children: [
                Container(
                  child: post,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
