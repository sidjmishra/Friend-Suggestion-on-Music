// ignore_for_file: no_logic_in_create_state, avoid_print, deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spotify_music_auth/constants/constants.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  const Comments({
    Key? key,
    required this.postId,
    required this.postOwnerId,
    required this.postMediaUrl,
  }) : super(key: key);

  @override
  CommentsState createState() => CommentsState(
        postId: postId,
        postOwnerId: postOwnerId,
        postMediaUrl: postMediaUrl,
      );
}

class CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  CommentsState({
    required this.postId,
    required this.postOwnerId,
    required this.postMediaUrl,
  });

  buildComments() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Comments')
            .doc(postId)
            .collection('comments')
            .orderBy('timeStamp', descending: false)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<Comment> comments = [];
          snapshot.data.docs.forEach((doc) {
            comments.add(Comment.fromDocument(doc));
          });
          int count = snapshot.data.docs.length;
          print('There are $count posts');

          return ListView(
            children: comments,
            //children: children,
          );
        });
  }

  addComment() {
    FirebaseFirestore.instance
        .collection('Comments')
        .doc(postId)
        .collection('comments')
        .add({
      'username': Constants.userName,
      'comment': commentController.text,
      'timeStamp': DateTime.now(),
      'avatarUrl': Constants.photoUrl,
      'uid': Constants.uid,
    });

    bool isNotPostOwner = postOwnerId != Constants.uid;
    if (isNotPostOwner) {
      FirebaseFirestore.instance
          .collection("Activity Feed")
          .doc(postOwnerId)
          .update({
        "timeStamp": DateTime.now(),
      });
      FirebaseFirestore.instance
          .collection('Activity Feed')
          .doc(postOwnerId)
          .collection('feedItems')
          .add({
        'type': 'comment',
        'commentData': commentController.text,
        'timeStamp': DateTime.now(),
        'postId': postId,
        'uid': Constants.uid,
        'username': Constants.userName,
        'userProfileImg': Constants.photoUrl,
        'mediaUrl': postMediaUrl,
      });
    }

    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Comments",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: buildComments(),
          ),
          const Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Write A Comment...',
              ),
            ),
            trailing: OutlineButton(
              onPressed: addComment,
              borderSide: BorderSide.none,
              child: const Text('Post'),
            ),
          )
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  const Comment({
    Key? key,
    required this.username,
    required this.userId,
    required this.avatarUrl,
    required this.comment,
    required this.timestamp,
  }) : super(key: key);

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      userId: doc['uid'],
      comment: doc['comment'],
      timestamp: doc['timeStamp'],
      avatarUrl: doc['avatarUrl'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
        ),
        const Divider(),
      ],
    );
  }
}
