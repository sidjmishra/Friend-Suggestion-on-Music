// ignore_for_file: avoid_print, unnecessary_null_comparison, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:music_recommend/models/user.dart' as prefix;
import 'package:music_recommend/pages/activity_feed.dart';
import 'package:music_recommend/pages/create_account.dart';
import 'package:music_recommend/pages/profile.dart';
import 'package:music_recommend/pages/search.dart';
import 'package:music_recommend/pages/timeline.dart';
import 'package:music_recommend/pages/upload.dart';

//Reference Now We Can Use The Methods Login/Logout etc.
//References Used To Access Firebase etc.
final GoogleSignIn googleSignIn = GoogleSignIn();
final Reference storageRef = FirebaseStorage.instance.ref();
final FirebaseAuth _auth = FirebaseAuth.instance;
//Path References In FireStore
final usersRef = FirebaseFirestore.instance.collection('users');
final postsRef = FirebaseFirestore.instance.collection('posts');
final commentsRef = FirebaseFirestore.instance.collection('comments');
final activityFeedRef = FirebaseFirestore.instance.collection('feed');
final followersRef = FirebaseFirestore.instance.collection('followers');
final followingRef = FirebaseFirestore.instance.collection('following');
final timelineRef = FirebaseFirestore.instance.collection('timeline');
final DateTime timestamp = DateTime.now();

//ownerid not ownerId

//Able To Pass User Data To All The Pages From Here
prefix.User? currentUser;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();

  ///Logout
  logout(BuildContext context) {
    googleSignIn.signOut().then((value) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: ((context) => const Home())));
    });
    print('Logout\n');
  }
}

class _HomeState extends State<Home> {
  //FireBaseMessaging Stuff
  // With The Key _scaffoldKey.currentState.showSnackbar();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool isAuth = false;
  //Make Sure To Dispose When Not On The HomePage
  late PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    //Widgets Initialized In InitState Must Be disposed
    pageController = PageController();

    ///Detects When User Signed In
    //account is a return type of googleSignInAccount
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account: account!);
    }, onError: (err) {
      print('Error Signing In: $err');
    });

    ///ReAuthenticate user when app is opened
    //App Doesn't Keep State
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account: account!);
      print('Signed In Silently\n');
    }).catchError((err) {
      print('Error Signing In: $err');
    });
  }

  handleSignIn({required GoogleSignInAccount account}) async {
    if (account != null) {
      //Await has to be used if you call an ASYNC FUNCTION
      await createUserInFirestore();
      print('Google Sign In Account Info => $account\n');
      setState(() {
        print('isAuth = true\n');
        isAuth = true;
      });
      configurePushNotifications();
    } else {
      setState(() {
        print('isAuth = false\n');
        isAuth = false;
      });
    }
  }

  configurePushNotifications() {
    //Get User
    final GoogleSignInAccount? user = googleSignIn.currentUser;
    //Get Notification Token And Associate It With The User Data
    _firebaseMessaging.getToken().then((token) {
      print("Firebase Messaging TOKEN:::: $token\n");
      //Associate It With The User Store It. Whenever
      // It Is Needed Get It
      usersRef.doc(user!.id).update({"androidNotificationToken": token});
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      print('onMessage: $message\n');
      final String? recipientId = message.senderId;
      final String? body = message.notification!.body;
      if (recipientId == user?.id) {
        print("Notification Shown");
        SnackBar snackbar = SnackBar(
            content: Text(
          body!,
          overflow: TextOverflow.ellipsis,
        ));
        _scaffoldKey.currentState!.showSnackBar(snackbar);
      }
      print('NOTIFICATION Not Shown');
    });
  }

  //Whenever This Is Called You Need To Use ASYNC ans AWAIT
  createUserInFirestore() async {
    // 1) Check if user exists in users collections in database
    // according to their ID
    //googleSignIn.currentUSer returns same info as account/GoogleSignIn
    final GoogleSignInAccount? user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.doc(user!.id).get();

    if (!doc.exists) {
      // 2) if the user doesn't exist, then we want to take them
      // to the create user account page
      //This userName Is Returned After The pushed page pops
      // back, it is in the POP constructor
      final username = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateAccount(),
          ));
      print('$username');
      // 3) get username from create account use
      // it to make new user document in users
      // collection with the user id as the document id
      usersRef.doc(user.id).set({
        'id': user.id,
        //If A User Backs Out It Will Create An Error == Null
        'username': username ?? 'John Doe',
        'photoUrl': user.photoUrl,
        'email': user.email,
        'displayName': user.displayName,
        'bio': " ",
        'timestamp': timestamp,
      });
      print(user.id);
      //If Document Does Not Exist All These Variables Are
      // Set In The Database. This Line Retrieves Those
      // Documents and Stores The in A User Object.

      //Make user their own follower(to include their
      // posts in their timeline)
      await followersRef
          .doc(user.id)
          .collection('userFollowers')
          .doc(user.id)
          .set({});

      doc = await usersRef.doc(user.id).get();
    }
    //DocumentSnapshot turned into user object.
    currentUser = prefix.User.fromDocument(doc);
    print(currentUser);
    print(currentUser!.username);
  }

  @override
  void dispose() {
    pageController.dispose();
    //THis Has To Be Last Or Ish Wont Work
    super.dispose();
  } //

  ///Login Called By UnAuth
  login2() {
    googleSignIn.signIn();
  }

  login() async {
    // hold the instance of the authenticated user
    User user;
    // flag to check whether we're signed in already
//    bool isSignedIn = await googleSignIn.isSignedIn();
//    if (isSignedIn) {
//      // if so, return the current user
//      user = await _auth.currentUser();
//    }
//    else {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    // get the credentials to (access / id token)
    // to sign in via Firebase Authentication
    final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
    user = (await _auth.signInWithCredential(credential)).user!;
    //}
    print('This Is Working $user');
    //return user;
  }

  ///Logout
  logout() async {
    await _auth.signOut();
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: const Duration(milliseconds: 300), curve: Curves.bounceInOut);
  }

  ///AuthScreen
  Widget buildAuthScreen() {
    return Scaffold(
      //Key For Messaging
      //Scaffold wraps all these pages
      //Snackbar Will Show Here Only
      key: _scaffoldKey,
      body: PageView(
        children: <Widget>[
          Timeline(currentUser: currentUser!),
          const ActivityFeed(),
          Upload(currentUser: currentUser!),
          const Search(),
          //currentUser?.id Null Aware Operator If Null
          // Don't Pass It
          Profile(profileId: currentUser!.id),
        ],
        //Controller To switch Between Pages
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_camera,
              size: 35.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
    );
  }

  ///Login Screen
  Scaffold buildUnAuthScreen() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Theme.of(context).accentColor.withOpacity(0.9),
                Theme.of(context).primaryColor.withOpacity(0.9),
              ]),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'FlutterShare',
              style: TextStyle(
                fontFamily: "Signatra",
                fontSize: orientation == Orientation.portrait ? 90.0 : 150.0,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () {
                login();
                print('Tapped');
              },
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  ///Uses isAuth State to Load Screens
  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
