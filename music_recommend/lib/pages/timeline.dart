import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:music_recommend/widgets/header.dart';
import 'package:music_recommend/widgets/progress.dart';

final usersRef = FirebaseFirestore.instance.collection('users');

class Timeline extends StatefulWidget {
  const Timeline({Key? key}) : super(key: key);

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  void initState() {
    //createUser();
    deleteUser();
    super.initState();
  }

  createUser() {
    usersRef.doc("asdfasfd").set({
      "username": "Jeff",
      "postsCount": 0,
      "isAdmin": false,
    });
  }

  updateUser() async {
    final DocumentSnapshot doc =
        await usersRef.doc("34ZiYPSHk5uQkQxZBpBw").get();
    if (doc.exists) {
      doc.reference.update({
        "username": "John",
        "postsCount": 0,
        "isAdmin": false,
      });
    }
  }

  deleteUser() async {
    final DocumentSnapshot doc =
        await usersRef.doc("34ZiYPSHk5uQkQxZBpBw").get();
    if (doc.exists) {
      doc.reference.delete();
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true, titleText: ''),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          final List<Text> children = snapshot.data!.docs
              .map((doc) => Text(
                    doc['username'],
                  ))
              .toList();
          return SizedBox(
            child: ListView(
              children: children,
            ),
          );
        },
      ),
    );
  }
}
