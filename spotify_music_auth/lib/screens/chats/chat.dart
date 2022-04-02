import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:spotify_music_auth/constants/constants.dart';
import 'package:spotify_music_auth/services/database.dart';

class Chat extends StatefulWidget {
  final String chatRoomId;
  final String chatName;
  const Chat({required this.chatRoomId, required this.chatName, Key? key})
      : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  // Stream<QuerySnapshot>? chats;
  TextEditingController messages = TextEditingController();

  Widget chatList(AsyncSnapshot snapshot) {
    return ListView.builder(
      itemCount: snapshot.data.docs.length,
      itemBuilder: (conext, index) {
        // return Text(snapshot.data.docs[index]["message"].toString());
        return MessageTile(
            message: snapshot.data.docs[index]["message"],
            sendByMe:
                Constants.userName == snapshot.data.docs[index]["sendBy"]);
      },
    );
  }

  // Widget chatMessages() {
  // return StreamBuilder<QuerySnapshot>(
  //   stream: chats,
  //   builder: (context, snapshot) {
  //     return snapshot.hasData
  //         ? ListView.builder(
  //             itemCount: snapshot.data!.docs.length,
  //             itemBuilder: (context, index) {
  //               return MessageTile(
  //                 message: snapshot.data!.docs[index]["message"],
  //                 sendByMe: Constants.userName ==
  //                     snapshot.data!.docs[index]["sendBy"],
  //               );
  //             })
  //         : Container();
  //   },
  // );
  // }

  addMessage() {
    if (messages.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": Constants.userName,
        "message": messages.text,
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      FirebaseFirestore.instance
          .collection('ChatRoom')
          .doc(widget.chatRoomId)
          .update({
        "timeStamp": DateTime.now().millisecondsSinceEpoch,
      });
      Database().addConversation(widget.chatRoomId, chatMessageMap);

      setState(() {
        messages.text = "";
      });
    }
  }

  @override
  void initState() {
    // Database().getConversation(widget.chatRoomId).then((value) {
    //   chats = value;
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatName.capitalize()),
        backgroundColor: kPrimaryColor,
      ),
      body: SizedBox(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('ChatRoom')
                    .doc(widget.chatRoomId)
                    .collection("chats")
                    .orderBy("time", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: kPrimaryColor,
                      ),
                    );
                  }
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  return ListView.builder(
                      reverse: true,
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        return MessageTile(
                          message: documents[index]["message"],
                          sendByMe:
                              Constants.userName == documents[index]["sendBy"],
                        );
                      });
                },
              ),
            ),
            // Expanded(
            //   child: FutureBuilder(
            //     future: Database().getConversation(widget.chatRoomId),
            //     builder: (context, snapshot) {
            //       if (!snapshot.hasData) {
            //         return const CircularProgressIndicator(
            //             color: kPrimaryColor);
            //       }
            //       AsyncSnapshot<Object?> querySnapshot = snapshot;
            //       return chatList(querySnapshot);
            //     },
            //   ),
            // ),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              // height: MediaQuery.of(context).size.height * (0.1),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 15.0),
                color: Colors.grey[100],
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        child: TextField(
                          controller: messages,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16.0),
                          decoration: InputDecoration(
                            hintText: "Type Message Here",
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(50.0)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        addMessage();
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(
                          color: kPrimaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: LineIcon(
                            LineIcons.paperPlane,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;

  const MessageTile({Key? key, required this.message, required this.sendByMe})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8, bottom: 8, left: sendByMe ? 0 : 24, right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: sendByMe
            ? const EdgeInsets.only(left: 30)
            : const EdgeInsets.only(right: 30),
        padding:
            const EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
          color: sendByMe ? kPrimaryColor : Colors.white,
          borderRadius: sendByMe
              ? const BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomLeft: Radius.circular(23))
              : const BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomRight: Radius.circular(23)),
        ),
        child: Text(message,
            textAlign: TextAlign.start,
            style: TextStyle(
                color: sendByMe ? Colors.white : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w300)),
      ),
    );
  }
}
