import 'package:cloud_firestore/cloud_firestore.dart';

class PlayUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? username;
  final String? photoUrl;
  final String? bio;
  PlayUser({
    required this.uid,
    this.email,
    this.displayName,
    this.username,
    this.bio,
    this.photoUrl,
  });

  factory PlayUser.fromDocument(DocumentSnapshot doc) {
    return PlayUser(
      uid: doc['uid'],
      username: doc['username'],
      email: doc['email'],
      photoUrl: doc['photoUrl'],
      displayName: doc['displayName'],
      bio: doc['bio'],
    );
  }
}
