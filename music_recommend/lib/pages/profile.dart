// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:music_recommend/models/user.dart';
import 'package:music_recommend/pages/edit_profile.dart';
import 'package:music_recommend/pages/home.dart';
import 'package:music_recommend/widgets/header.dart';
import 'package:music_recommend/widgets/post.dart';
import 'package:music_recommend/widgets/post_tile.dart';
import 'package:music_recommend/widgets/progress.dart';

class Profile extends StatefulWidget {
  final String profileId;

  const Profile({Key? key, required this.profileId}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  //Profile page could be for any profile
  // this is the current user
  //Same As (currentUser != null) ? currentUser.id : null
  final String currentUserId = currentUser!.id;
  bool isFollowing = false;
  String postOrientation = 'list';
  bool isLoading = false;
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    print('Profile Init');
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  //If Doc Exist You are Following if null doc.exists is false
  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .get();
    setState(() {
      followerCount = snapshot.docs.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.profileId)
        .collection('userFollowing')
        .get();
    setState(() {
      followingCount = snapshot.docs.length;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .doc(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      //Iterate over snapshot.documents with map
      //For each Doc deserialize post document
      // snapshot with Post.fromDocument pass in doc to it
      // In the end call to list to make it a list
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
      //Documents is a list of all the stuff in snapshot
      //map goes over each document and returns 1 doc each
      //each doc passed into factory and all are turned into a list
    });
  }

  buildCountColumn({required String label, required int count}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        )
      ],
    );
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUserId)));
  }

  Container buildButton({required String text, required Function function}) {
    return Container(
      padding: const EdgeInsets.only(top: 2.0),
      child: TextButton(
          onPressed: () {
            function;
          },
          child: Container(
            width: 250.0,
            height: 27.0,
            child: Text(
              text,
              style: TextStyle(
                color: isFollowing ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isFollowing ? Colors.white : Colors.blue,
              border: Border.all(
                color: isFollowing ? Colors.grey : Colors.blue,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
          )),
    );
  }

  buildProfileButton() {
    //Viewing own profile show edit profile
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(text: 'Edit Profile', function: editProfile);
    } else if (isFollowing) {
      return buildButton(
        text: 'Unfollow',
        function: handleUnfollowUser,
      );
    } else if (!isFollowing) {
      return buildButton(
        text: 'Follow',
        function: handleFollowUser,
      );
    }
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    //remove follower
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        //doc is a document snapshot
        .get()
        .then((doc) {
      if (doc.exists) {
        //reference is the reference that produced
        // the snapshot doc
        doc.reference.delete();
      }
    });
    //remove following
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        //reference is the reference that produced
        // the snapshot doc
        doc.reference.delete();
      }
    });
    //Delete activity feed item
    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        //reference is the reference that produced
        // the snapshot doc
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    //Make Auth User Follower Of That User
    // (Update Their Followers Collection)
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .set({});
    //Put that user on your following collection (Update
    //your following collection)
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});
    //add activity feed item for tht user to notify about
    // new follower (us)
    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .set({
      'type': 'follow',
      'ownerId': widget.profileId,
      'username': currentUser!.username,
      'userId': currentUserId,
      'userProfileImg': currentUser!.photoUrl,
      'timestamp': timestamp,
    });
  }

  buildProfileHeader() {
    //Resolve Future Needed To Get User Info Based
    // On Their ID
    //Resolves It Once Needs To Be Refreshed To See New data
    //Should Be A Stream Builder Here
    return FutureBuilder(
      future: usersRef.doc(widget.profileId).get(),
      //Resolve Value Available In Our Builder Function
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        //Deserialize
        User user = User.fromDocument(snapshot.data as DocumentSnapshot);
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn(label: 'posts', count: postCount),
                            buildCountColumn(
                                label: 'followers', count: followerCount),
                            buildCountColumn(
                                label: 'following', count: followingCount),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton(),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),

              ///USERNAME
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  user.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),

              ///DISPLAYNAME
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  user.displayName ?? 'My Name',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(top: 2.0),
                //child: Text(user.bio),
                child: Text(
                  user.bio ?? 'Work In Progress',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset('assets/images/no_content.svg', height: 260.0),
            const Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                'No Posts',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (postOrientation == 'grid') {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(
          GridTile(
            child: PostTile(
              post: post,
            ),
          ),
        );
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    } else if (postOrientation == 'list') {
      return Column(
        children: posts,
      );
    }
  }

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () => setPostOrientation('grid'),
          icon: const Icon(Icons.grid_on),
          color: postOrientation == 'grid'
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
        IconButton(
          onPressed: () => setPostOrientation('list'),
          icon: const Icon(Icons.list),
          color: postOrientation == 'list'
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Profile'),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          const Divider(),
          buildTogglePostOrientation(),
          const Divider(
            height: 0.0,
          ),
          buildProfilePosts(),
        ],
      ),
    );
  }
}
