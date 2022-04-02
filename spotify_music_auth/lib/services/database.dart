// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:spotify_music_auth/constants/helper.dart';
import 'package:spotify_music_auth/models/users.dart';

class Database {
  final db = FirebaseFirestore.instance.collection('Users');
  final room = FirebaseFirestore.instance.collection('ChatRoom');
  final userPost = FirebaseFirestore.instance.collection('User Posts');
  final posts = FirebaseFirestore.instance.collection('Posts');

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
