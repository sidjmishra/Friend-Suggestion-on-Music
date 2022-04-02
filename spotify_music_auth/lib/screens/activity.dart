// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spotify_music_auth/components/postscreen.dart';
import 'package:spotify_music_auth/constants/constants.dart';
import 'package:timeago/timeago.dart' as timeago;

class Activity extends StatefulWidget {
  const Activity({Key? key}) : super(key: key);

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  getActivityFeed() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("Activity Feed")
        .doc(Constants.uid)
        .collection('feedItems')
        .orderBy('timeStamp', descending: true)
        .limit(50)
        .get();
    List<ActivityFeedItem> feedItems = [];
    for (var doc in snapshot.docs) {
      feedItems.add(ActivityFeedItem.fromDocument(doc));
    }

    for (var doc in snapshot.docs) {
      print('Activity Feed Item: ${doc.data}');
    }
    print('Activity Feed Items Length ${feedItems.length}');
    return feedItems;
  }

  Widget emptyActivityFeed() {
    return const Center(
      child: SizedBox(
        child: Text(
          'No Activity Just Yet',
          style: TextStyle(
            fontSize: 30,
            color: Colors.black87,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Activity Feed'),
        backgroundColor: kPrimaryColor,
      ),
      body: FutureBuilder<QuerySnapshot<Object?>>(
        future: FirebaseFirestore.instance
            .collection("Activity Feed")
            .doc(Constants.uid)
            .collection('feedItems')
            .orderBy('timeStamp', descending: true)
            .limit(20)
            .get(),
        builder: (BuildContext context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<Widget> feedItems = [];
          print(snapshot.data!.docs.length);
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            feedItems
                .add(ActivityFeedItem.fromDocument(snapshot.data!.docs[i]));
          }

          return Container(
            child: feedItems.isNotEmpty
                ? ListView(
                    children: feedItems,
                  )
                : emptyActivityFeed(),
          );
        },
      ),
    );
  }
}

Widget? mediaPreview;
String? activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String uid;
  final String type;
  final String mediaUrl;
  final String postId;
  final String photoUrl;
  final String commentData;
  final String ownerId;
  final Timestamp timeStamp;

  const ActivityFeedItem({
    Key? key,
    required this.username,
    required this.uid,
    required this.type,
    required this.mediaUrl,
    required this.postId,
    required this.photoUrl,
    required this.commentData,
    required this.ownerId,
    required this.timeStamp,
  }) : super(key: key);

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      username: doc['username'],
      uid: doc['uid'],
      type: doc['type'],
      mediaUrl: doc['mediaUrl'],
      postId: doc['postId'],
      photoUrl: doc['photoUrl'],
      commentData: doc['commentData'],
      ownerId: doc['ownerId'],
      timeStamp: doc['timeStamp'],
    );
  }

  showPost(context) {
    print('Activity Feed Post Id $postId');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: postId,
          userId: Constants.uid,
        ),
      ),
    );
  }

  configureMediaPreview(context) {
    if (type == 'like' || type == 'comment') {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(mediaUrl),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = const Text('');
    }
    if (type == 'like') {
      activityItemText = ' Liked Your Post';
    } else if (type == 'follow') {
      activityItemText = ' Is Following You';
    } else if (type == 'comment') {
      activityItemText = ' Replied: $commentData';
    } else {
      activityItemText = " Error: Unknown type '$type'";
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: uid),
            child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '$activityItemText',
                      )
                    ])),
          ),
          leading: GestureDetector(
            onTap: () => showProfile(context, profileId: uid),
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(photoUrl),
            ),
          ),
          subtitle: Text(
            timeago.format(
              timeStamp.toDate(),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}
