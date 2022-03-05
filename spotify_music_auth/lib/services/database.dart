import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:spotify_music_auth/models/users.dart';

class Database {
  final db = FirebaseFirestore.instance.collection('users');

  Future<bool> addUserToDatabase(PlayUser user) async {
    String url = "";
    // String fileName = _imageFile!.path.toString();

    await db.doc(user.uid).set({
      "uid": user.uid,
      "displayName": user.displayName,
      "email": user.email,
      "username": user.username,
      "timestamp": DateTime.now(),
      "photoUrl": url,
    }).then((value) {
      print("User is added to db !");
      return true;
    }).catchError((error) {
      // ignore: return_of_invalid_type_from_catch_error
      return Future.error("Some issues");
    });

    // FirebaseApp secondaryApp =
    //     Firebase.app('gs://play-connect-40fa6.appspot.com');
    // Reference firebaseStorageRef =
    //     FirebaseStorage.instanceFor(app: secondaryApp)
    //         .ref()
    //         .child('profilePictures/$fileName');
    // UploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);
    // TaskSnapshot taskSnapshot =
    //     await uploadTask.whenComplete(() => print("Uplaoded"));
    // taskSnapshot.ref.getDownloadURL().then((value) {
    //   print("Done: $value");
    // });
    return false;
  }
}
