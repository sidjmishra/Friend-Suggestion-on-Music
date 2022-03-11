// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:spotify_music_auth/models/users.dart';

class Database {
  final db = FirebaseFirestore.instance.collection('Users');

  Future<bool> addUserToDatabase(PlayUser user, var _imageFile) async {
    String url = "";
    String fileName = _imageFile.path.toString();

    // await db.doc(user.uid).set({
    //   "uid": user.uid,
    //   "displayName": user.displayName,
    //   "email": user.email,
    //   "username": user.username,
    //   "timestamp": DateTime.now(),
    //   "photoUrl": url,
    //   "bio": ""
    // }).then((value) {
    //   print("User is added to db !");
    //   return true;
    // }).catchError((error) {
    //   // ignore: return_of_invalid_type_from_catch_error
    //   return Future.error("Some issues");
    // });

    Reference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('profilePictures/${user.displayName}.jpg');
    UploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);
    TaskSnapshot taskSnapshot =
        await uploadTask.whenComplete(() => print("Uplaoded"));
    taskSnapshot.ref.getDownloadURL().then((value) async {
      print("Done: $value");

      await db.doc(user.uid).set({
        "uid": user.uid,
        "displayName": user.displayName,
        "email": user.email,
        "username": user.username,
        "timestamp": DateTime.now(),
        "photoUrl": value,
        "bio": ""
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
