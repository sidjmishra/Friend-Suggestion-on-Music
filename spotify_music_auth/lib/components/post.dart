// ignore_for_file: no_logic_in_create_state

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spotify_music_auth/components/comments.dart';
import 'package:spotify_music_auth/constants/constants.dart';
import 'package:spotify_music_auth/models/users.dart';
import 'package:spotify_music_auth/services/database.dart';

class Post extends StatefulWidget {
  final String postId;
  final String uid;
  final String username;
  final String location;
  final String caption;
  final String mediaUrl;
  final dynamic likes;

  const Post({
    Key? key,
    required this.postId,
    required this.uid,
    required this.username,
    required this.location,
    required this.caption,
    required this.mediaUrl,
    this.likes,
  }) : super(key: key);

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      uid: doc['uid'],
      username: doc['username'],
      location: doc['location'],
      caption: doc['caption'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
    );
  }

  int getLikeCount(likes) {
    if (likes == null) {
      return 0;
    }
    int count = 0;
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        postId: postId,
        uid: uid,
        username: username,
        location: location,
        caption: caption,
        mediaUrl: mediaUrl,
        likes: likes,
        likeCount: getLikeCount(likes),
      );
}

class _PostState extends State<Post> {
  final String currentUserId = Constants.uid;
  final String postId;
  final String uid;
  final String username;
  final String location;
  final String caption;
  final String mediaUrl;
  bool isLiked = false;
  bool showHeart = false;
  int likeCount;
  int commentCount = 0;
  Map likes;

  _PostState({
    required this.postId,
    required this.uid,
    required this.username,
    required this.location,
    required this.caption,
    required this.mediaUrl,
    required this.likes,
    required this.likeCount,
  });

  buildPostHeader() {
    return FutureBuilder(
        future: FirebaseFirestore.instance.collection('Users').doc(uid).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          PlayUser user =
              PlayUser.fromDocument(snapshot.data as DocumentSnapshot);
          bool isPostOwner = currentUserId == uid;
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(Constants.photoUrl),
                      backgroundColor: Colors.grey,
                    ),
                    const SizedBox(width: 20.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              showProfile(context, profileId: user.uid),
                          child: Text(
                            Constants.userName,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          location,
                          style: const TextStyle(fontSize: 12.0),
                        ),
                      ],
                    ),
                  ],
                ),
                isPostOwner
                    ? IconButton(
                        onPressed: () => handleDeletePost(context),
                        icon: const Icon(
                          Icons.more_vert,
                        ),
                      )
                    : const Text(''),
              ],
            ),
          );
        });
  }

  handleDeletePost(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Remove The Post?'),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  Database().deletePost(uid, postId, username);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              )
            ],
          );
        });
  }

  handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;
    if (_isLiked) {
      FirebaseFirestore.instance
          .collection("User Posts")
          .doc(uid)
          .collection('pictures')
          .doc(postId)
          .update({'likes.$currentUserId': false});

      FirebaseFirestore.instance
          .collection('Posts')
          .doc(postId)
          .update({'likes.$currentUserId': false});

      Database()
          .removeLikeFromActivityFeed(currentUserId, Constants.uid, postId);
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      FirebaseFirestore.instance
          .collection("User Posts")
          .doc(uid)
          .collection('pictures')
          .doc(postId)
          .update({'likes.$currentUserId': true});

      FirebaseFirestore.instance
          .collection('Posts')
          .doc(postId)
          .update({'likes.$currentUserId': true});

      Database().addLikeToActivityFeed(Constants.uid, postId, mediaUrl);
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });

      Timer(const Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CachedNetworkImage(
            imageUrl: mediaUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Padding(
              child: CircularProgressIndicator(
                color: kPrimaryColor,
              ),
              padding: EdgeInsets.all(20.0),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          showHeart
              ? Icon(
                  Icons.favorite,
                  size: 100.0,
                  color: Colors.red.withOpacity(0.5),
                )
              : const Text(''),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(
                top: 40.0,
                left: 10.0,
              ),
            ),
            GestureDetector(
              onTap: handleLikePost,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 25.0,
                color: Colors.pink,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(
                top: 40.0,
                right: 20.0,
              ),
            ),
            GestureDetector(
              onTap: () => showComments(
                context,
                postId: postId,
                ownerid: uid,
                mediaUrl: mediaUrl,
              ),
              child: Icon(
                Icons.chat,
                size: 25.0,
                color: Colors.blue[900],
              ),
            )
          ],
        ),
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 10.0),
              child: Text(
                '$likeCount likes  $commentCount comments',
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 10.0),
              child: Text(
                '$username ',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(caption),
            )
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);
    Database().getCommentCount(postId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        children: [
          buildPostHeader(),
          buildPostImage(),
          buildPostFooter(),
        ],
      ),
    );
  }
}

showComments(
  BuildContext context, {
  required String postId,
  required String ownerid,
  required String mediaUrl,
}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postOwnerId: ownerid,
      postMediaUrl: mediaUrl,
    );
  }));
}
