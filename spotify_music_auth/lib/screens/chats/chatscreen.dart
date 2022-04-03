import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spotify_music_auth/constants/constants.dart';
import 'package:spotify_music_auth/screens/chats/chat.dart';
import 'package:spotify_music_auth/screens/chats/search.dart';

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
        title: Text(
          "Chats",
          style: GoogleFonts.openSans(),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ChatRoom')
            .where("users", arrayContains: Constants.userName)
            .orderBy("timeStamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text(
                "No Chats Found. Search For a User",
                style: GoogleFonts.openSans(),
              ),
            );
          }
          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ChatRoomList(
                      chatRoomId: documents[index]["chatRoomId"],
                      username:
                          documents[index]["users"][0] == Constants.userName
                              ? documents[index]["users"][1]
                              : documents[index]["users"][0],
                      uids: documents[index]["uids"][0] == Constants.uid
                          ? documents[index]["uids"][1]
                          : documents[index]["uids"][0]),
                  Divider(
                    color: Colors.grey[100],
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        tooltip: 'Search User',
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (constext) => const SearchChat()));
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}

class ChatRoomList extends StatelessWidget {
  final String username;
  final String uids;
  final String chatRoomId;
  const ChatRoomList(
      {required this.chatRoomId,
      required this.username,
      required this.uids,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Chat(
                      chatRoomId: chatRoomId,
                      chatName: username,
                    )));
      },
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .where(
                "uid",
                isEqualTo: uids,
              )
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text("");
            }
            return Container(
              width: MediaQuery.of(context).size.width * (1.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        NetworkImage(snapshot.data!.docs[0]["photoUrl"]),
                    radius: 20.0,
                  ),
                  const SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.data!.docs[0]["displayName"].toString(),
                        style: GoogleFonts.openSans(
                          fontSize: 16.0,
                        ),
                      ),
                      Text(
                        username.capitalize(),
                        style: GoogleFonts.openSans(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }
}
