// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:music_recommend/pages/home.dart';
import 'package:music_recommend/pages/post_screen.dart';
import 'package:music_recommend/pages/profile.dart';
import 'package:music_recommend/widgets/header.dart';
import 'package:music_recommend/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  const ActivityFeed({Key? key}) : super(key: key);

  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .doc(currentUser!.id)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();
    List<ActivityFeedItem> feedItems = [];
    snapshot.docs.forEach((doc) {
      feedItems.add(ActivityFeedItem.fromDocument(doc));
    });
    //Print It To Check It Out
    //forEach Iterates Over Each Item
    snapshot.docs.forEach((doc) {
      print('Activity Feed Item: ${doc.data}');
    });
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
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: header(context, titleText: 'Activity Feed'),
      body: FutureBuilder<QuerySnapshot<Object?>>(
        future: activityFeedRef
            .doc(currentUser!.id)
            .collection('feedItems')
            .orderBy('timestamp', descending: true)
            .limit(20)
            .get(),
        builder: (BuildContext context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          //You Will Use ActivityFeedItem.fromDocument So You Need A
          // List Of ActivityFeedItem
          List<Widget> feedItems = [];
          //DATA latest data received by the asynchronous computation (Snapshot)
          //DOCUMENTS Gets a list of all the documents included in this snapshot
          //Each Document made into ActivityFeedItem and saved to list
          print(snapshot.data!.docs.length);
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            feedItems
                .add(ActivityFeedItem.fromDocument(snapshot.data!.docs[i]));
          }
          // snapshot.data!.docs.forEach((doc) {});

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

//Widget ??? Why
Widget? mediaPreview;
String? activityItemText;

//Model

//This is the feed items that is displayed and it also
// maps the document snapshot.
//The Build is how it is displayed. All You Have TO Do Is pAss It To THe ListView
class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String userId;
  final String type;
  final String mediaUrl;
  final String postId;
  final String userProfileImg;
  final String commentData;
  final Timestamp timestamp;

  const ActivityFeedItem({
    Key? key,
    required this.username,
    required this.userId,
    required this.type,
    required this.mediaUrl,
    required this.postId,
    required this.userProfileImg,
    required this.commentData,
    required this.timestamp,
  }) : super(key: key);

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      username: doc['username'],
      userId: doc['userId'],
      type: doc['type'],
      //He Didn't Use
      mediaUrl: doc['mediaUrl'],
      postId: doc['postId'],
      userProfileImg: doc['userProfileImg'],
      commentData: doc['commentData'],
      timestamp: doc['timestamp'],
    );
  }

  showPost(context) {
    print('Activity Feed Post Id $postId');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: postId,
          userId: currentUser!.id,
        ),
      ),
    );
  }

  //Passed In Context To Use Navigator
  configureMediaPreview(context) {
    if (type == 'like' || type == 'comment') {
      mediaPreview = GestureDetector(
        //Passed In Context To Use Navigator
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
            onTap: () => showProfile(context, profileId: userId),
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
            onTap: () => showProfile(context, profileId: userId),
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(userProfileImg),
            ),
          ),
          subtitle: Text(
            timeago.format(
              timestamp.toDate(),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}

showProfile(BuildContext context, {required String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Profile(
        profileId: profileId,
      ),
    ),
  );
}
