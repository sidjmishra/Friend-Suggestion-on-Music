// ignore_for_file: no_logic_in_create_state, avoid_print, deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:music_recommend/pages/home.dart';
import 'package:music_recommend/widgets/header.dart';
import 'package:music_recommend/widgets/progress.dart';
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
        stream: commentsRef
            .doc(postId)
            .collection('comments')
            .orderBy('timeStamp', descending: false)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }

          List<Comment> comments = [];
          snapshot.data.documents.forEach((doc) {
            comments.add(Comment.fromDocument(doc));
          });
          int count = snapshot.data.documents.length;
          print('There are $count posts');

//          final List<Text> comments = snapshot.data.documents
//              //get each doc and get username
//              .map((doc) => Text(doc['userId'].toString()))
//              .toList();
//          print(comments);
//          int count = snapshot.data.documents.length;
//          print(count);

          return ListView(
            children: comments,
            //children: children,
          );
        });
  }

  addComment() {
    commentsRef.doc(postId).collection('comments').add({
      'username': currentUser!.username,
      'comment': commentController.text,
      'timeStamp': timestamp,
      'avatarUrl': currentUser!.photoUrl,
      'userId': currentUser!.id,
    });
    bool isNotPostOwner = postOwnerId != currentUser!.id;
    if (isNotPostOwner) {
      //Add A Notification To Owners Activity Feed
      activityFeedRef.doc(postOwnerId).collection('feedItems').add({
        'type': 'comment',
        'commentData': commentController.text,
        //User Who Liked The Post
        'timestamp': timestamp,
        'postId': postId,
        'userId': currentUser!.id,
        'username': currentUser!.username,
        'userProfileImg': currentUser!.photoUrl,
        'mediaUrl': postMediaUrl,
      });
    }

    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Comments'),
      body: Column(
        children: <Widget>[
          Expanded(child: buildComments()),
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
      userId: doc['userId'],
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
          //Need To Enable Firestore.instance.settings(timestampsInSnapshotsEnabled: true).then()
          subtitle: Text(timeago.format(timestamp.toDate())),
        ),
        Divider(),
      ],
    );
  }
}
