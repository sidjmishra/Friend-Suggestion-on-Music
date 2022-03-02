import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:music_recommend/models/user.dart';
import 'package:music_recommend/pages/home.dart';
import 'package:music_recommend/pages/search.dart';
import 'package:music_recommend/widgets/header.dart';
import 'package:music_recommend/widgets/post.dart';
import 'package:music_recommend/widgets/progress.dart';

final CollectionReference usersRef =
    FirebaseFirestore.instance.collection('users');

class Timeline extends StatefulWidget {
  final User currentUser;

  const Timeline({Key? key, required this.currentUser}) : super(key: key);

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  void initState() {
    super.initState();
    getFollowing();
  }

  //Used To Save A List To Use Elsewhere In Program Used With SetState
  List<String> followingList = [];
  List<Post> posts = [];

  List<dynamic> users = [];

  notFollowingMethod() {
    return StreamBuilder(
      stream:
          usersRef.orderBy('timestamp', descending: true).limit(30).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> userResults = [];
        //ForEach Loop Everything in it is done once
        snapshot.data!.documents.forEach((doc) {
          //Take snapshot and return 1 User Object
          User user = User.fromDocument(doc);
          //Check if your user profile comes up so You don't add yourself
          final bool isAuthUser = currentUser!.id == user.id;
          //Check you are not already following the person
          final bool isFollowingUser = followingList.contains(user.id);
          //Remove AuthUser from recommended list if true
          if (isAuthUser) {
            return;
          } else if (isFollowingUser) {
            return;
          } else {
            UserResult userResult = UserResult(user);
            userResults.add(userResult);
          }
        });
        return Container(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.person_add,
                      color: Theme.of(context).primaryColor,
                      size: 30.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'Users To Follow',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 30.0,
                      ),
                    ),
                  ],
                ),
              ),
              //Column(children: userResults)
              Expanded(
                child: ListView(
                  children: userResults,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(currentUser!.id)
        .collection('userFollowing')
        .get();
    //SetState Is Used To Save Ish To Defined Variables On Top
    setState(() {
      //Gets Document Id Field Of Each UserFollowing Document Which
      // Is A User Id
      followingList = snapshot.docs.map((doc) => doc.documentID).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        isAppTitle: true,
        titleText: 'Time Lizzo',
        removeBackButton: false,
        removeLogoutButton: false,
      ),
      //Refreshes Instantly Unlike A Future Builder
      body:
//      widget.currentUser.id == null
//          ? notFollowingMethod() :
          StreamBuilder<QuerySnapshot>(
        //initialData: null,
        stream: timelineRef
            .document(widget.currentUser.id)
            .collection('timelinePosts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
//          else if (snapshot == null) {
//            return circularProgress();
//          }
          List<Post> children = [];
          snapshot.data.documents.forEach((doc) {
            children.add(Post.fromDocument(doc));
          });

//          List<Post> children = snapshot.data.documents
//              //final List<Post> children = snapshot.data.documents
//              //get each doc and get username
//              .map((doc) => Post.fromDocument(doc))
//              .toList();
          //print('children.length ${children.length}');

          return Container(
            child: children.length > 0
                ? ListView(
                    children: children,
                  )
                : notFollowingMethod(),
          );
        },
      ),
    );
  }
}
