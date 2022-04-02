import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spotify_music_auth/components/post.dart';
import 'package:spotify_music_auth/components/postscreen.dart';
import 'package:spotify_music_auth/constants/constants.dart';

class PostTile extends StatelessWidget {
  final Post post;

  const PostTile({Key? key, required this.post}) : super(key: key);

  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: post.postId,
          userId: post.uid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context),
      child: CachedNetworkImage(
        imageUrl: post.mediaUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Padding(
          child: CircularProgressIndicator(
            color: kPrimaryColor,
          ),
          padding: EdgeInsets.all(20.0),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }
}
