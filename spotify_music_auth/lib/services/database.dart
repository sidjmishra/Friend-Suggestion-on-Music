import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotify_music_auth/models/users.dart';

class Database {
  final db = FirebaseFirestore.instance.collection('users');

  Future<bool> addUserToDatabase(PlayUser user) async {
    await db.doc(user.uid).set({
      "uid": user.uid,
      "displayName": user.displayName,
      "email": user.email,
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
