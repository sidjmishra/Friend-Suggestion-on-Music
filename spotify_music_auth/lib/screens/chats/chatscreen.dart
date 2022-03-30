import 'package:flutter/material.dart';
import 'package:spotify_music_auth/constants/constants.dart';
import 'package:spotify_music_auth/screens/chats/chatspage.dart';
import 'package:spotify_music_auth/screens/chats/userspage.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Chats"),
          backgroundColor: kPrimaryColor,
        ),
        body: Text(''));
  }
}
