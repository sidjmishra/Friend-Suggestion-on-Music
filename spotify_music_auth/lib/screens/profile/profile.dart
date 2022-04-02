// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:spotify_music_auth/components/post.dart';
import 'package:spotify_music_auth/components/posttile.dart';
import 'package:spotify_music_auth/constants/constants.dart';
import 'package:spotify_music_auth/models/users.dart';
import 'package:spotify_music_auth/screens/profile/editprofile.dart';
import 'package:spotify_music_auth/services/auth.dart';
import 'package:spotify_music_auth/services/authenticate.dart';
import 'package:spotify_music_auth/services/database.dart';

class Profile extends StatefulWidget {
  final String profileId;
  const Profile({required this.profileId, Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = Constants.uid;
  bool isFollowing = false;
  String postOrientation = 'list';
  bool isLoading = false;
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  List<Post> posts = [];

  getStatus() {
    setState(() {
      Database()
          .checkIfFollowing(widget.profileId, currentUserId)
          .then((value) {
        isFollowing = value;
      });
      Database().getFollowers(widget.profileId).then((value) {
        followerCount = value;
      });
      Database().getFollowing(widget.profileId).then((value) {
        followingCount = value;
      });
    });
    print(isFollowing);
    print(followerCount);
    print(followingCount);
  }

  getPosts() async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.profileId)
        .collection('pictures')
        .orderBy('timeStamp', descending: true)
        .get();

    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  countColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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

  Container buildButton(String text, Function function) {
    return Container(
      width: MediaQuery.of(context).size.width * (0.5),
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
              color: isFollowing ? Colors.white : kPrimaryColor,
              border: Border.all(
                color: isFollowing ? Colors.grey : kPrimaryColor,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
          )),
    );
  }

  buildProfileButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return Container(
        width: MediaQuery.of(context).size.width * (0.5),
        padding: const EdgeInsets.only(top: 2.0),
        child: TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EditProfile(currentUserId: currentUserId)));
            },
            child: Container(
              width: 250.0,
              height: 27.0,
              child: Text(
                "Edit Profile",
                style: TextStyle(
                  color: isFollowing ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isFollowing ? Colors.white : kPrimaryColor,
                border: Border.all(
                  color: isFollowing ? Colors.grey : kPrimaryColor,
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),
            )),
      );
    } else if (isFollowing) {
      return Container(
        width: MediaQuery.of(context).size.width * (0.5),
        padding: const EdgeInsets.only(top: 2.0),
        child: TextButton(
            onPressed: () {
              setState(() {
                isFollowing = false;
              });
              FirebaseFirestore.instance
                  .collection('Followers')
                  .doc(widget.profileId)
                  .collection('userFollowers')
                  .doc(currentUserId)
                  .get()
                  .then((doc) {
                if (doc.exists) {
                  doc.reference.delete();
                }
              });
              FirebaseFirestore.instance
                  .collection('Following')
                  .doc(currentUserId)
                  .collection('userFollowing')
                  .doc(widget.profileId)
                  .get()
                  .then((doc) {
                if (doc.exists) {
                  doc.reference.delete();
                }
              });
              FirebaseFirestore.instance
                  .collection('Activity Feed')
                  .doc(widget.profileId)
                  .collection('feedItems')
                  .doc(currentUserId)
                  .get()
                  .then((doc) {
                if (doc.exists) {
                  doc.reference.delete();
                }
              });
            },
            child: Container(
              width: 250.0,
              height: 27.0,
              child: Text(
                "Unfollow",
                style: TextStyle(
                  color: isFollowing ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isFollowing ? Colors.white : kPrimaryColor,
                border: Border.all(
                  color: isFollowing ? Colors.grey : kPrimaryColor,
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),
            )),
      );
    } else if (!isFollowing) {
      return Container(
        width: MediaQuery.of(context).size.width * (0.5),
        padding: const EdgeInsets.only(top: 2.0),
        child: TextButton(
            onPressed: () {
              setState(() {
                isFollowing = true;
              });
              FirebaseFirestore.instance
                  .collection('Followers')
                  .doc(widget.profileId)
                  .collection('userFollowers')
                  .doc(currentUserId)
                  .set({});
              FirebaseFirestore.instance
                  .collection('Following')
                  .doc(currentUserId)
                  .collection('userFollowing')
                  .doc(widget.profileId)
                  .set({});

              FirebaseFirestore.instance
                  .collection('Activity Feed')
                  .doc(widget.profileId)
                  .set({
                'timeStamp': DateTime.now(),
              });
              FirebaseFirestore.instance
                  .collection('Activity Feed')
                  .doc(widget.profileId)
                  .collection('feedItems')
                  .doc(currentUserId)
                  .set({
                'type': 'follow',
                'ownerId': widget.profileId,
                'username': Constants.userName,
                'uid': currentUserId,
                'photoUrl': Constants.photoUrl,
                'timeStamp': DateTime.now(),
                'commentData': '',
                'postId': '',
                'mediaUrl': '',
              });
            },
            child: Container(
              width: 250.0,
              height: 27.0,
              child: Text(
                "Follow",
                style: TextStyle(
                  color: isFollowing ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isFollowing ? Colors.white : kPrimaryColor,
                border: Border.all(
                  color: isFollowing ? Colors.grey : kPrimaryColor,
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),
            )),
      );
    }
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    FirebaseFirestore.instance
        .collection("Followers")
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    FirebaseFirestore.instance
        .collection("Following")
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    FirebaseFirestore.instance
        .collection("Activity Feed")
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });

    FirebaseFirestore.instance
        .collection("Followers")
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .set({});

    FirebaseFirestore.instance
        .collection("Following")
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});

    FirebaseFirestore.instance
        .collection('Activity Feed')
        .doc(widget.profileId)
        .set({
      'timeStamp': DateTime.now(),
    });

    FirebaseFirestore.instance
        .collection("Activity Feed")
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .set({
      'type': 'follow',
      'ownerId': widget.profileId,
      'username': Constants.userName,
      'uid': currentUserId,
      'userProfileImg': Constants.photoUrl,
      'timeStamp': DateTime.now(),
      'commentData': '',
      'postId': '',
      'mediaUrl': '',
    });
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.profileId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        PlayUser user =
            PlayUser.fromDocument(snapshot.data as DocumentSnapshot);

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl!),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            countColumn('Posts', postCount),
                            countColumn('Followers', followerCount),
                            countColumn('Following', followingCount),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildProfileButton(),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),

              /// USERNAME
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  user.username!,
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
                ),
              ),

              /// BIO
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(top: 2.0),
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
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (posts.isEmpty) {
      return SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/no_content.svg', height: 260.0),
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
      for (var post in posts) {
        gridTiles.add(
          GridTile(
            child: PostTile(
              post: post,
            ),
          ),
        );
      }
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
      children: [
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
  void initState() {
    getPosts();
    getStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Play-Connect'),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: LineIcon(LineIcons.alternateSignOut, color: Colors.white),
            tooltip: "Logout",
            onPressed: () {
              AuthService().signOut().then((value) => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Authenticate())));
            },
          ),
        ],
      ),
      body: ListView(
        children: [
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
