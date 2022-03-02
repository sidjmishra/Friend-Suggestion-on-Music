import 'package:flutter/material.dart';
import 'package:music_recommend/pages/post_screen.dart';
import 'package:music_recommend/widgets/custom_image.dart';
import 'package:music_recommend/widgets/post.dart';

class PostTile extends StatelessWidget {
  final Post post;

  const PostTile({Key? key, required this.post}) : super(key: key);

  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: post.postId,
          userId: post.ownerid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
