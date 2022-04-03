// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:spotify_music_auth/constants/constants.dart';
import 'package:spotify_music_auth/constants/helper.dart';
import 'package:spotify_music_auth/models/users.dart';

class Database {
  final db = FirebaseFirestore.instance.collection('Users');
  final room = FirebaseFirestore.instance.collection('ChatRoom');
  final userPost = FirebaseFirestore.instance.collection('User Posts');
  final posts = FirebaseFirestore.instance.collection('Posts');
  final followersRef = FirebaseFirestore.instance.collection('Followers');
  final followingRef = FirebaseFirestore.instance.collection('Following');
  final comments = FirebaseFirestore.instance.collection('Comments');
  final feed = FirebaseFirestore.instance.collection('Activity Feed');

  getUserByName(String username) async {
    return await db
        .where(
          "username",
          isGreaterThanOrEqualTo: username,
          isLessThan: username.substring(0, username.length - 1) +
              String.fromCharCode(username.codeUnitAt(username.length - 1) + 1),
        )
        .get();
  }

  getUserByUid(String uid) async {
    return db
        .where(
          "uid",
          isEqualTo: uid,
        )
        .snapshots();
  }

  createChatRoom(String chatRoomId, Map<String, dynamic> chatRoomMap) async {
    await room.doc(chatRoomId).set(chatRoomMap).catchError((error) {
      print(error.toString());
    });
  }

  getUserByEmail(String email) async {
    return await db.where("email", isEqualTo: email).get();
  }

  addConversation(String chatRoomId, Map<String, dynamic> chatMap) async {
    await room
        .doc(chatRoomId)
        .collection("chats")
        .add(chatMap)
        .catchError((error) {
      print(error.toString());
    });
  }

  getStreamConversation(String chatRoomId) async {
    return room.doc(chatRoomId).collection("chats").orderBy("time").snapshots();
  }

  getConversation(String chatRoomId) async {
    return room.doc(chatRoomId).collection("chats").get();
  }

  getChatRoom(String userName) async {
    room.where("users", arrayContains: userName).snapshots();
  }

  Future<bool> checkIfFollowing(String profileId, String currentUserId) async {
    DocumentSnapshot doc = await followersRef
        .doc(profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get();
    return doc.exists;
  }

  getFollowers(String profileId) async {
    QuerySnapshot snapshot =
        await followersRef.doc(profileId).collection('userFollowers').get();
    return snapshot.docs.length;
  }

  getFollowing(String profileId) async {
    QuerySnapshot snapshot =
        await followingRef.doc(profileId).collection('userFollowing').get();
    return snapshot.docs.length;
  }

  getProfilePosts(String profileId) async {
    QuerySnapshot snapshot = await userPost
        .doc(profileId)
        .collection('pictures')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot;
  }

  getCommentCount(String postId) async {
    QuerySnapshot snapshot =
        await comments.doc(postId).collection('comments').get();
    return snapshot.docs.length;
  }

  Future addPostToDatabase(String postId, String uid, String location,
      var imageFile, String username, String caption) async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref()
        .child('$username/post_$postId.jpg')
        .putFile(imageFile);
    TaskSnapshot storageSnap =
        await uploadTask.whenComplete(() => print("Completed"));
    await storageSnap.ref.getDownloadURL().then((value) async {
      print("Posted: $value");

      await userPost.doc(uid).set({
        "timeStamp": DateTime.now(),
        "uid": uid,
        "username": username,
      });

      await userPost.doc(uid).collection("pictures").doc(postId).set({
        "uid": uid,
        "username": username,
        "postId": postId,
        "caption": caption,
        "location": location,
        "mediaUrl": value,
        "timeStamp": DateTime.now(),
        "likes": {}
      });

      await posts.doc(postId).set({
        "uid": uid,
        "username": username,
        "postId": postId,
        "caption": caption,
        "location": location,
        "mediaUrl": value,
        "timeStamp": DateTime.now(),
        "likes": {}
      });
    });
  }

  deletePost(String uid, String postId, String username) async {
    userPost.doc(uid).collection('pictures').doc(postId).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    posts.doc(postId).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    FirebaseStorage.instance.ref().child('$username/post_$postId.jpg').delete();

    QuerySnapshot activityFeedSnapshot = await feed
        .doc(uid)
        .collection('feedItems')
        .where('postId', isEqualTo: postId)
        .get();
    for (var doc in activityFeedSnapshot.docs) {
      if (doc.exists) {
        doc.reference.delete();
      }
    }

    QuerySnapshot commentsSnapshot = (await comments
        .doc(uid)
        .collection('comments')
        .doc(postId)
        .get()) as QuerySnapshot<Object?>;
    for (var doc in commentsSnapshot.docs) {
      if (doc.exists) {
        doc.reference.delete();
      }
    }
  }

  addLikeToActivityFeed(String uid, String postId, String mediaUrl) {
    feed.doc(uid).set({
      'timeStamp': DateTime.now(),
    });
    feed.doc(uid).collection('feedItems').doc(postId).set({
      'type': 'like',
      'username': Constants.userName,
      'uid': Constants.uid,
      'photoUrl': Constants.photoUrl,
      'postId': postId,
      'mediaUrl': mediaUrl,
      'timeStamp': DateTime.now(),
      'commentData': '',
      'ownerId': uid,
    });
  }

  removeLikeFromActivityFeed(String currentUserId, String uid, String postId) {
    bool isNotPostOwner = currentUserId != uid;
    if (isNotPostOwner) {
      feed.doc(uid).collection('feedItems').doc(postId).get().then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  Future<bool> addUserToDatabase(PlayUser user, var _imageFile) async {
    String url = "";
    String fileName = _imageFile.path.toString();

    Reference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('profilePictures/${user.displayName}.jpg');
    UploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);
    TaskSnapshot taskSnapshot =
        await uploadTask.whenComplete(() => print("Uplaoded"));
    taskSnapshot.ref.getDownloadURL().then((value) async {
      print("Done: $value");

      HelperFunction.saveUserPhotoUrlSharedPreference(value);

      await db.doc(user.uid).set({
        "uid": user.uid,
        "displayName": user.displayName,
        "email": user.email,
        "username": user.username,
        "timestamp": DateTime.now(),
        "photoUrl": value,
        "bio": "",
      }).then((value) {
        print("User is added to db !");
        return true;
      }).catchError((error) {
        // ignore: return_of_invalid_type_from_catch_error
        return Future.error("Some issues");
      });
    });
    return false;
  }
}
