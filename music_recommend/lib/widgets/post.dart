import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:music_recommend/models/user.dart';
import 'package:music_recommend/pages/activity_feed.dart';
import 'package:music_recommend/pages/comments.dart';
import 'package:music_recommend/pages/home.dart';
import 'package:music_recommend/widgets/custom_image.dart';
import 'package:music_recommend/widgets/progress.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerid;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;

  // #2 All Post Stuff From Snapshot
  const Post({
    Key? key,
    required this.postId,
    required this.ownerid,
    required this.username,
    required this.location,
    required this.description,
    required this.mediaUrl,
    this.likes,
  }) : super(key: key);

  // #1 Document Snapshot Is Made Into Post
  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerid: doc['ownerid'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
    );
  }

  int getLikeCount(likes) {
    // if no likes, return 0
    if (likes == null) {
      return 0;
    }
    int count = 0;
    // if the key is explicitly set to true, add a like
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  // ignore: no_logic_in_create_state
  _PostState createState() => _PostState(
        postId: postId,
        ownerid: ownerid,
        username: username,
        location: location,
        description: description,
        mediaUrl: mediaUrl,
        likes: likes,
        likeCount: getLikeCount(likes),
      );
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser!.id;
  final String postId;
  final String ownerid;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  bool isLiked = false;
  bool showHeart = false;
  int likeCount;
  Map likes;

  _PostState({
    required this.postId,
    required this.ownerid,
    required this.username,
    required this.location,
    required this.description,
    required this.mediaUrl,
    required this.likes,
    required this.likeCount,
  });

  buildPostHeader() {
    return FutureBuilder(
        future: usersRef.doc(ownerid).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            //Stops Here With Return If No Data
            return circularProgress();
          }
          User user = User.fromDocument(snapshot.data as DocumentSnapshot);
          bool isPostOwner = currentUserId == ownerid;
          return Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                backgroundColor: Colors.grey,
              ),
              title: GestureDetector(
                onTap: () => showProfile(context, profileId: user.id),
                child: Text(
                  user.username,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              subtitle: Text(location),
              //See If You Are The Post Ower
              trailing: isPostOwner
                  ? IconButton(
                      //Passed In Context Since Modal Needs Context
                      onPressed: () => handleDeletePost(context),
                      icon: const Icon(
                        Icons.more_vert,
                      ),
                    )
                  : const Text(''),
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
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  deletePost();
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

  deletePost() async {
    //Delete Post
    postsRef
        .doc(ownerid)
        .collection('userPosts')
        .doc(postId)
//You Can Call Delete Here Yet You Should Make Sure It Exists First
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
//Delete Uploaded Image From Post
    storageRef.child('post_$postId.jpg').delete();
//Then Delete All Activity Feed Notifications
    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .doc(ownerid)
        .collection('feedItems')
        .where('postId', isEqualTo: postId)
        .get();
    for (var doc in activityFeedSnapshot.docs) {
      if (doc.exists) {
        doc.reference.delete();
      }
    }
//Then Delete All Comments
    QuerySnapshot commentsSnapshot =
        await commentsRef.doc(postId).collection('comments').get();
    for (var doc in commentsSnapshot.docs) {
      if (doc.exists) {
        doc.reference.delete();
      }
    }
  }

  handleLikePost() {
    //If current user liked this set this to true
    bool _isLiked = likes[currentUserId] == true;
    //If They Liked It Take Like Away
    if (_isLiked) {
      postsRef
          .doc(ownerid)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': false});
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
      //If They Didn't Like It Already Add Like
    } else if (!_isLiked) {
      postsRef
          .doc(ownerid)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': true});
      addLikeToActivityFeed();
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

  addLikeToActivityFeed() {
    //Don't add to feed if you like your own stuff
    //isNotPostOwner Only Exists Here
    bool isNotPostOwner = currentUserId != ownerid;
    //if (isNotPostOwner) {
    activityFeedRef
        //Send Notification To THe Owner Of The Post
        .doc(ownerid)
        .collection('feedItems')
        .doc(postId)
        .set({
      'type': 'like',
      //User Who Liked The Post
      'username': currentUser!.username,
      'userId': currentUser!.id,
      'userProfileImg': currentUser!.photoUrl,
      'postId': postId,
      'mediaUrl': mediaUrl,
      'timestamp': timestamp,
    });
    // }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerid;
    if (isNotPostOwner) {
      activityFeedRef.doc(ownerid).collection('feedItems').doc(postId).get()
          //Whatever Comes From Get Is Sent To Then And Named doc
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: [
          cachedNetworkImage(mediaUrl),
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
                left: 20.0,
              ),
            ),
            //Like Button
            GestureDetector(
              onTap: handleLikePost,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28.0,
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
              //Need context since It will be Shown
              // outside of post widget
              onTap: () => showComments(
                context,
                postId: postId,
                ownerid: ownerid,
                mediaUrl: mediaUrl,
              ),
              child: Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.blue[900],
              ),
            )
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                '$likeCount likes',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: Text(
                '$username ',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(description),
            )
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}

showComments(BuildContext context,
    {required String postId,
    required String ownerid,
    required String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postOwnerId: ownerid,
      postMediaUrl: mediaUrl,
    );
  }));
}
