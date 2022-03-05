import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:spotify_music_auth/models/users.dart';

class Database {
  final db = FirebaseFirestore.instance.collection('users');

  Future uploadImageToFirebase(File _imageFile) async {
    String fileName = _imageFile.path.toString();
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('uploads/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);
    TaskSnapshot taskSnapshot =
        await uploadTask.whenComplete(() => print("Uplaoded"));
    taskSnapshot.ref.getDownloadURL().then(
          (value) => print("Done: $value"),
        );
  }

  Future<bool> addUserToDatabase(PlayUser user) async {
    await db.doc(user.uid).set({
      "uid": user.uid,
      "displayName": user.displayName,
      "email": user.email,
      "username": user.username,
      "timestamp": DateTime.now(),
    }).then((value) {
      print("User is added to db !");
      return true;
    }).catchError((error) {
      // ignore: return_of_invalid_type_from_catch_error
      return Future.error("Some issues");
    });
    return false;
  }
}
