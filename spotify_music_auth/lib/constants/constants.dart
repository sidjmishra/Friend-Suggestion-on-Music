import 'package:flutter/material.dart';
import 'package:spotify_music_auth/components/comments.dart';
import 'package:spotify_music_auth/screens/profile/editprofile.dart';
import 'package:spotify_music_auth/screens/profile/profile.dart';

const kPrimaryColor = Color(0xFF6F35A5);
const kPrimaryLightColor = Color(0xFFF1E6FF);

class Constants {
  static String uid = "";
  static String userName = "";
  static String displayName = "";
  static String photoUrl = "";
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

showProfile(BuildContext context, {required String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Profile(
        profileId: profileId,
      ),
    ),
  );
}

editProfile(BuildContext context, {required String currentUserId}) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditProfile(currentUserId: currentUserId)));
}

showComments(
  BuildContext context, {
  required String postId,
  required String ownerid,
  required String mediaUrl,
}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postOwnerId: ownerid,
      postMediaUrl: mediaUrl,
    );
  }));
}
