// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:music_recommend/pages/home.dart';
import 'package:music_recommend/widgets/header.dart';
import 'package:music_recommend/widgets/post.dart';
import 'package:music_recommend/widgets/progress.dart';

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
      future: postsRef.doc(userId).collection('userPosts').doc(postId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        Post post = Post.fromDocument(snapshot.data as DocumentSnapshot);
        return Center(
          child: Scaffold(
            appBar: header(context, titleText: post.description),
            body: ListView(
              children: <Widget>[
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
